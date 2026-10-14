import 'dart:io';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/apertura.dart';
import '../data/database.dart';
import '../data/repository.dart';
import '../domain/libretto.dart';
import '../domain/modelli.dart';
import '../domain/preferenze.dart';
import '../domain/studio.dart';
import '../features/slide/visualizzatore_pdf.dart';
import '../services/backup.dart';
import '../services/importazione_slide.dart';
import '../services/notifiche.dart';
import '../services/ocr.dart';
import '../services/scadenza_firma.dart';
import '../services/touch_id.dart';
import '../services/voce.dart';

typedef AperturaDb = ({Future<AuriDb> Function() apri, Future<File> Function() file});

final aperturaDbProvider = Provider<AperturaDb>((ref) => (apri: apriDatabase, file: fileDatabase));

class DbNotifier extends AsyncNotifier<AuriDb> {
  @override
  Future<AuriDb> build() => ref.watch(aperturaDbProvider).apri();

  /// Sostituisce i dati con un backup. Se il file non è valido non tocca nulla;
  /// in ogni caso alla fine c'è un database aperto.
  Future<void> ripristina(File backup) async {
    verificaBackup(backup);
    final apertura = ref.read(aperturaDbProvider);
    final vecchio = state.requireValue;
    state = const AsyncLoading();
    try {
      await vecchio.close();
      await sostituisciDatabase(backup: backup, destinazione: await apertura.file());
    } finally {
      state = await AsyncValue.guard(apertura.apri);
    }
  }
}

final dbProvider = AsyncNotifierProvider<DbNotifier, AuriDb>(DbNotifier.new);

final repositoryProvider = Provider<Repository>((ref) => Repository(ref.watch(dbProvider).requireValue));

final corsiProvider = StreamProvider<List<CorsoConEsito>>((ref) => ref.watch(repositoryProvider).guardaCorsi());

final appelliProvider = StreamProvider<List<AppelloConCorso>>((ref) => ref.watch(repositoryProvider).guardaAppelli());

final preferenzeProvider = StreamProvider<Preferenze>((ref) => ref.watch(repositoryProvider).guardaPreferenze());

final orologioProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final scadenzaFirmaProvider = FutureProvider<DateTime?>((ref) => const ScadenzaFirmaService().leggi());

final riepilogoProvider = Provider<Riepilogo>((ref) {
  final corsi = ref.watch(corsiProvider).value ?? const [];
  final pref = ref.watch(preferenzeProvider).value ?? Preferenze.predefinite;
  return calcolaRiepilogo([
    for (final c in corsi)
      VoceLibretto(cfu: c.corso.cfu, superato: c.superato, aVoto: c.corso.valutazione == Valutazione.voto, voto: c.esito?.voto, lode: c.esito?.lode ?? false),
  ], valoreLode: pref.valoreLode);
});

enum Sezione { oggi, corsi, calendario, libretto, slide, ripasso, studio, impostazioni }

class SezioneCorrente extends Notifier<Sezione> {
  @override
  Sezione build() => Sezione.oggi;
  void vai(Sezione s) => state = s;
}

final sezioneProvider = NotifierProvider<SezioneCorrente, Sezione>(SezioneCorrente.new);

final notificheProvider = Provider<NotificheService>((ref) => NotificheService());

final touchIdProvider = Provider<TouchIdService>((ref) => TouchIdService());

final touchIdDisponibileProvider = FutureProvider<bool>((ref) => ref.watch(touchIdProvider).disponibile());

/// Chiede il permesso delle notifiche la prima volta che serve.
final richiestaPermessoNotificheProvider = Provider<Future<bool> Function()>(
  (ref) => () async {
    final ok = await ref.read(notificheProvider).chiediPermesso();
    ref.invalidate(permessoNotificheProvider);
    return ok;
  },
);

/// null = sconosciuto (es. Windows), false = negato.
final permessoNotificheProvider = FutureProvider<bool?>((ref) => ref.watch(notificheProvider).permessoConcesso());

final documentiProvider = StreamProvider<List<DocumentoConCorso>>((ref) => ref.watch(repositoryProvider).guardaDocumenti());

/// Cartella dove l'app tiene le copie dei PDF.
final cartellaSlideProvider = Provider<Future<Directory> Function()>(
  (ref) => () async {
    final dir = Directory(p.join((await getApplicationDocumentsDirectory()).path, 'slide'));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  },
);

final importazioneProvider = Provider<ImportazioneSlide>((ref) => ImportazioneSlide(ref.watch(repositoryProvider), ref.watch(cartellaSlideProvider)));

/// Costruisce il visualizzatore PDF (sostituibile nei test, dove il widget nativo non gira).
final visualizzatorePdfProvider = Provider<Widget Function(String percorso, int pagina, int documentoId, ValueChanged<int> paginaCambiata)>(
  (ref) =>
      (percorso, pagina, documentoId, paginaCambiata) =>
          VisualizzatorePdf(percorso: percorso, pagina: pagina, documentoId: documentoId, paginaCambiata: paginaCambiata),
);

/// Carte attive di tutti i corsi.
final carteProvider = StreamProvider<List<Carta>>((ref) => ref.watch(repositoryProvider).guardaCarte(null));

/// Generatore casuale per i quiz (fisso nei test).
final casoProvider = Provider<Random Function()>((ref) => Random.new);

final voceProvider = Provider<Voce>((ref) => VoceTts());

final ascoltoProvider = Provider<Ascolto>((ref) => AscoltoStt());

final sessioniProvider = StreamProvider<List<Sessione>>((ref) => ref.watch(repositoryProvider).guardaSessioni());

final pagineStudiateProvider = StreamProvider<List<PaginaStudiata>>((ref) => ref.watch(repositoryProvider).guardaPagineStudiate());

final revisioniProvider = StreamProvider<List<Revisione>>((ref) => ref.watch(repositoryProvider).guardaRevisioni());

final simulazioniProvider = StreamProvider<List<Simulazione>>((ref) => ref.watch(repositoryProvider).guardaSimulazioni(null));

/// Piano di studio per ogni corso che ha slide e un prossimo appello.
final pianiProvider = Provider<Map<int, ({PianoStudio piano, DateTime esame})>>((ref) {
  final ora = ref.watch(orologioProvider)();
  final documenti = ref.watch(documentiProvider).value ?? const [];
  final studiate = ref.watch(pagineStudiateProvider).value ?? const [];
  final appelli = ref.watch(appelliProvider).value ?? const [];
  final out = <int, ({PianoStudio piano, DateTime esame})>{};
  for (final corsoId in {for (final d in documenti) d.corso.id}) {
    final prossimo = appelli.where((a) => a.corso.id == corsoId && a.appello.dataOra.isAfter(ora)).firstOrNull;
    if (prossimo == null) continue;
    final docs = {for (final d in documenti.where((d) => d.corso.id == corsoId)) d.documento.id: d.documento.numeroPagine};
    final totale = docs.values.fold(0, (a, b) => a + b);
    final fatte = studiate.where((p) => docs.containsKey(p.documentoId)).length;
    out[corsoId] = (piano: pianoStudio(totalePagine: totale, fatte: fatte, oggi: ora, esame: prossimo.appello.dataOra), esame: prossimo.appello.dataOra);
  }
  return out;
});

/// Lettura del testo dalle slide scansionate (Apple Vision sull'iPad).
final letturaScansioniProvider = Provider<LetturaScansioni>((ref) => LetturaScansioni(ref.watch(repositoryProvider), const OcrVision()));
