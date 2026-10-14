import 'dart:async';
import 'dart:io';

import 'package:auri/app/providers.dart';
import 'package:auri/data/database.dart';
import 'package:auri/data/repository.dart';
import 'package:auri/domain/modelli.dart';
import 'package:auri/domain/slide.dart';
import 'package:auri/features/slide/documento_page.dart';
import 'package:auri/features/slide/slide_page.dart';
import 'package:auri/services/importazione_slide.dart';
import 'package:auri/services/scheda_pdf.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../helpers/esempio.dart';

const _testi = [
  'Legge di Ohm\nLa resistenza elettrica e’ il rapporto tra tensione e corrente.\nSi definisce resistenza R = V / I.',
  'Potenza elettrica\nLa potenza e’ il prodotto di tensione e corrente.\nDefinizione: P = V * I.',
];

/// Importazione finta: registra la richiesta e risponde quando il test lo decide.
class _ImportazioneFinta extends ImportazioneSlide {
  _ImportazioneFinta(super.repo, super.cartella);
  final richieste = <(String, int)>[];
  final risposta = Completer<int>();

  @override
  Future<int> importa(File pdf, {required int corsoId, String? titolo, void Function(int fatte, int totali)? avanzamento}) {
    richieste.add((pdf.path, corsoId));
    return risposta.future;
  }
}

void main() {
  test('nome del file della scheda: niente caratteri non ammessi', () {
    expect(nomeFileScheda('Elettricità'), 'Scheda Elettricità.pdf');
    expect(nomeFileScheda('Fisica/Elettricità: parte 1?'), 'Scheda Fisica-Elettricità- parte 1-.pdf');
    expect(nomeFileScheda(r'a\b*c"d<e>f|g'), 'Scheda a-b-c-d-e-f-g.pdf');
    expect(nomeFileScheda('  '), 'Scheda documento.pdf');
  });

  late AuriDb db;
  late Repository repo;
  late Directory cartella;
  late int corsoId;
  late int docOhm;

  setUp(() async {
    db = AuriDb(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    repo = Repository(db);
    cartella = await Directory.systemTemp.createTemp('auri_pulsanti');
    corsoId = await repo.salvaCorso(CorsiCompanion.insert(nome: 'Fisica II', cfu: 9, valutazione: Valutazione.voto));
    docOhm = await repo.salvaDocumento(
      DocumentiCompanion.insert(corsoId: corsoId, titolo: 'Elettricità', nomeFile: 'a.pdf', numeroPagine: 2, importatoIl: DateTime(2026, 10, 13)),
      [for (var i = 0; i < 2; i++) (numero: i + 1, titolo: titoloPagina(_testi[i]), testo: _testi[i])],
    );
  });
  tearDown(() async {
    await db.close();
    await cartella.delete(recursive: true);
  });

  List<Override> base() => [
    repositoryProvider.overrideWithValue(repo),
    documentiProvider.overrideWith((ref) => repo.guardaDocumenti()),
    visualizzatorePdfProvider.overrideWithValue((percorso, pagina, documento, _) => Text('PDF pagina $pagina')),
    cartellaSlideProvider.overrideWithValue(() async => cartella),
  ];

  Future<void> attendi(WidgetTester t, [int ms = 200]) async {
    await t.runAsync(() => Future<void>.delayed(Duration(milliseconds: ms)));
    await t.pump();
  }

  group('elenco delle slide', () {
    testWidgets('toccando un documento si apre la sua pagina', (t) async {
      await schermoIpad(t);
      await t.pumpWidget(conDati(const SlidePage(), altri: base()));
      await attendi(t);
      await t.tap(find.text('Elettricità'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 500));
      expect(find.byType(DocumentoPage), findsOneWidget);
      expect(t.widget<DocumentoPage>(find.byType(DocumentoPage)).documentoId, docOhm);
    });

    testWidgets('Elimina e conferma: il PDF viene tolto', (t) async {
      await schermoIpad(t);
      final file = File(p.join(cartella.path, 'a.pdf'))..writeAsStringSync('x');
      await t.pumpWidget(conDati(const SlidePage(), altri: base()));
      await attendi(t);
      await t.tap(find.byTooltip('Elimina'));
      await t.pumpAndSettle();
      expect(find.text('Eliminare "Elettricità"?'), findsOneWidget);
      await t.tap(find.widgetWithText(FilledButton, 'Elimina'));
      await t.pumpAndSettle();
      await attendi(t);
      expect((await t.runAsync(() => repo.documento(docOhm))), isNull);
      expect(file.existsSync(), isFalse);
      expect(find.text('Elettricità'), findsNothing);
    });

    testWidgets('Elimina e Annulla: il PDF resta', (t) async {
      await schermoIpad(t);
      final file = File(p.join(cartella.path, 'a.pdf'))..writeAsStringSync('x');
      await t.pumpWidget(conDati(const SlidePage(), altri: base()));
      await attendi(t);
      await t.tap(find.byTooltip('Elimina'));
      await t.pumpAndSettle();
      await t.tap(find.text('Annulla'));
      await t.pumpAndSettle();
      await attendi(t);
      expect((await t.runAsync(() => repo.documento(docOhm))), isNotNull);
      expect(file.existsSync(), isTrue);
      expect(find.text('Elettricità'), findsOneWidget);
    });
  });

  group('Importa PDF', () {
    late _ImportazioneFinta finta;
    setUp(() => finta = _ImportazioneFinta(repo, () async => cartella));

    List<Override> conScelta(String? percorso) => [
      ...base(),
      importazioneProvider.overrideWithValue(finta),
      sceltaPdfProvider.overrideWithValue(() async => percorso),
    ];

    testWidgets('si sceglie il file e il corso, poi si apre il documento importato', (t) async {
      await schermoIpad(t);
      await t.pumpWidget(conDati(const SlidePage(), altri: conScelta('/tmp/lezione.pdf')));
      await attendi(t);
      await t.tap(find.text('Importa PDF'));
      await t.pumpAndSettle();
      expect(find.text('Di quale corso sono queste slide?'), findsOneWidget);
      await t.tap(find.text('Programmazione'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 300));
      expect(finta.richieste, [('/tmp/lezione.pdf', 2)]);
      expect(find.text('Sto leggendo il PDF…'), findsOneWidget);
      // La risposta arriva fuori dal tempo finto del test.
      await t.runAsync(() async => finta.risposta.complete(docOhm));
      await attendi(t);
      await t.pump();
      await t.pump(const Duration(milliseconds: 500));
      expect(find.text('Sto leggendo il PDF…'), findsNothing);
      expect(t.widget<DocumentoPage>(find.byType(DocumentoPage)).documentoId, docOhm);
    });

    testWidgets('chiudendo il selettore dei file non succede nulla', (t) async {
      await schermoIpad(t);
      await t.pumpWidget(conDati(const SlidePage(), altri: conScelta(null)));
      await attendi(t);
      await t.tap(find.text('Importa PDF'));
      await t.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
      expect(finta.richieste, isEmpty);
    });

    testWidgets('senza corsi: avviso di crearne uno', (t) async {
      await schermoIpad(t);
      await t.pumpWidget(conDati(const SlidePage(), corsi: const [], altri: conScelta('/tmp/lezione.pdf')));
      await attendi(t);
      await t.tap(find.text('Importa PDF'));
      await t.pump();
      await t.pump();
      expect(find.text('Prima crea un corso a cui collegare le slide.'), findsOneWidget);
      expect(finta.richieste, isEmpty);
    });

    testWidgets('se la pagina viene chiusa durante l\'importazione: dialogo tolto, nessun errore', (t) async {
      await schermoIpad(t);
      final mostra = ValueNotifier(true);
      await t.pumpWidget(
        conDati(
          ValueListenableBuilder<bool>(valueListenable: mostra, builder: (_, v, _) => v ? const SlidePage() : const Text('altrove')),
          altri: conScelta('/tmp/lezione.pdf'),
        ),
      );
      await attendi(t);
      await t.tap(find.text('Importa PDF'));
      await t.pumpAndSettle();
      await t.tap(find.text('Programmazione'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 300));
      mostra.value = false;
      await t.pump();
      expect(find.byType(SlidePage), findsNothing);
      // La risposta arriva fuori dal tempo finto del test.
      await t.runAsync(() async => finta.risposta.complete(docOhm));
      await attendi(t);
      await t.pump();
      await t.pump(const Duration(milliseconds: 500));
      expect(t.takeException(), isNull);
      expect(find.text('Sto leggendo il PDF…'), findsNothing);
      expect(find.textContaining('Importazione non riuscita'), findsNothing);
      expect(find.byType(DocumentoPage), findsNothing);
      expect(find.text('altrove'), findsOneWidget);
    });
  });

  group('pagina del documento', () {
    testWidgets('"Ho studiato questa pagina": togliendo la spunta si cancella', (t) async {
      await schermoIpad(t);
      await t.runAsync(() => repo.segnaStudiata(docOhm, 1, true, ora));
      await t.pumpWidget(conDati(DocumentoPage(documentoId: docOhm), altri: base()));
      await attendi(t);
      await attendi(t); // la spunta arriva dal database dopo che la pagina è pronta
      final casella = find.widgetWithText(CheckboxListTile, 'Ho studiato questa pagina');
      expect(t.widget<CheckboxListTile>(casella).value, isTrue);
      await t.tap(casella);
      await attendi(t);
      expect((await t.runAsync(() => db.select(db.pagineStudiate).get()))!, isEmpty);
      expect(t.widget<CheckboxListTile>(casella).value, isFalse);
      // E rimettendola si registra di nuovo.
      await t.tap(casella);
      await attendi(t);
      expect((await t.runAsync(() => db.select(db.pagineStudiate).get()))!.single.pagina, 1);
    });

    Future<void> apriScheda(WidgetTester t, int documento, Future<void> Function(File, Rect) condividi) async {
      await schermoIpad(t);
      await t.pumpWidget(
        conDati(
          DocumentoPage(documentoId: documento),
          altri: [...base(), cartellaSchedaProvider.overrideWithValue(() async => cartella), condivisioneSchedaProvider.overrideWithValue(condividi)],
        ),
      );
      await attendi(t);
      await t.tap(find.text('Scheda PDF'));
      await t.pump();
    }

    testWidgets('Scheda PDF: crea il file e lo condivide, anche con "/" nel titolo', (t) async {
      final slash = await repo.salvaDocumento(
        DocumentiCompanion.insert(corsoId: corsoId, titolo: 'Fisica/Ohm', nomeFile: 'b.pdf', numeroPagine: 1, importatoIl: DateTime(2026, 10, 13)),
        [(numero: 1, titolo: titoloPagina(_testi[0]), testo: _testi[0])],
      );
      final condivisi = <File>[];
      final attesa = Completer<void>();
      await apriScheda(t, slash, (file, _) {
        condivisi.add(file);
        return attesa.future;
      });
      // Mentre la crea: indicatore e pulsante disattivato.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(t.widget<TextButton>(find.ancestor(of: find.text('Scheda PDF'), matching: find.byWidgetPredicate((w) => w is TextButton))).onPressed, isNull);
      for (var i = 0; i < 20 && condivisi.isEmpty; i++) {
        await attendi(t, 100);
      }
      expect(condivisi, hasLength(1));
      final file = condivisi.single;
      expect(p.basename(file.path), 'Scheda Fisica-Ohm.pdf');
      expect(p.dirname(file.path), cartella.path);
      expect(String.fromCharCodes(file.readAsBytesSync().take(4)), '%PDF');
      attesa.complete();
      await attendi(t);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining('Non sono riuscita'), findsNothing);
    });

    testWidgets('Scheda PDF: se qualcosa va storto, avviso e pulsante di nuovo attivo', (t) async {
      await apriScheda(t, docOhm, (_, _) async => throw const FileSystemException('disco pieno'));
      for (var i = 0; i < 20 && find.byType(SnackBar).evaluate().isEmpty; i++) {
        await attendi(t, 100);
      }
      expect(find.text('Non sono riuscita a creare la scheda: riprova.'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(t.widget<TextButton>(find.ancestor(of: find.text('Scheda PDF'), matching: find.byWidgetPredicate((w) => w is TextButton))).onPressed, isNotNull);
    });
  });
}
