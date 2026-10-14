import 'package:auri/app/providers.dart';
import 'package:auri/data/database.dart';
import 'package:auri/data/repository.dart';
import 'package:auri/domain/modelli.dart';
import 'package:auri/domain/ripasso.dart';
import 'package:auri/features/ripasso/cuffia_page.dart';
import 'package:auri/features/ripasso/orale_page.dart';
import 'package:auri/services/voce.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart' show SizedBox;
import 'package:flutter_test/flutter_test.dart';

import '../helpers/esempio.dart';

class VoceFinta implements Voce {
  final dette = <String>[];
  @override
  Future<void> parla(String testo) async => dette.add(testo);
  @override
  Future<void> ferma() async {}
}

class AscoltoFinto implements Ascolto {
  AscoltoFinto(this.risposta, {this.permesso = true});
  final String risposta;
  final bool permesso;
  @override
  Future<bool> prepara() async => permesso;
  @override
  Future<void> inizia(void Function(String) aggiornamento) async => aggiornamento(risposta);
  @override
  Future<String> fine() async => risposta;
  var annullato = false;
  @override
  Future<void> annulla() async => annullato = true;
}

void main() {
  late AuriDb db;
  late Repository repo;
  late int corso;

  setUp(() async {
    db = AuriDb(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    repo = Repository(db);
    corso = await repo.salvaCorso(CorsiCompanion.insert(nome: 'Fisica II', cfu: 9, valutazione: Valutazione.voto));
    await repo.salvaCarta(
      CarteCompanion.insert(
        corsoId: corso,
        fronte: 'tensione',
        retro: 'La tensione è la differenza di potenziale elettrico. (pag. 3)',
        origine: OrigineCarta.glossario,
      ),
    );
  });
  tearDown(() => db.close());

  Future<void> attendi(WidgetTester t) async {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await t.pump();
  }

  testWidgets('ripasso in cuffia: legge fronte e retro di ogni carta', (t) async {
    await schermoIpad(t);
    final voce = VoceFinta();
    await t.pumpWidget(
      conDati(
        CuffiaPage(corsoId: corso, pausa: Duration.zero),
        altri: [repositoryProvider.overrideWithValue(repo), voceProvider.overrideWithValue(voce)],
      ),
    );
    await attendi(t);
    await t.tap(find.text('Ascolta'));
    await t.pumpAndSettle();
    expect(voce.dette, ['tensione', 'La tensione è la differenza di potenziale elettrico.']);
    expect(find.text('Fine delle carte'), findsOneWidget);
  });

  testWidgets('esame orale: legge la domanda, ascolta, valuta', (t) async {
    await schermoIpad(t);
    final voce = VoceFinta();
    await t.pumpWidget(
      conDati(
        OralePage(corsoId: corso),
        altri: [
          repositoryProvider.overrideWithValue(repo),
          voceProvider.overrideWithValue(voce),
          ascoltoProvider.overrideWithValue(AscoltoFinto('la differenza di tensioni')),
        ],
      ),
    );
    await attendi(t);
    expect(voce.dette.first, "Che cos'è tensione?");
    await t.tap(find.text('Rispondi a voce'));
    await attendi(t);
    expect(find.text('la differenza di tensioni'), findsOneWidget);
    await t.tap(find.text('Ho finito'));
    await attendi(t);
    expect(find.text('Quasi'), findsOneWidget);
    expect(find.textContaining('potenziale'), findsWidgets);
  });

  testWidgets('esame orale senza permesso del microfono: messaggio', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(
      conDati(
        OralePage(corsoId: corso),
        altri: [
          repositoryProvider.overrideWithValue(repo),
          voceProvider.overrideWithValue(VoceFinta()),
          ascoltoProvider.overrideWithValue(AscoltoFinto('', permesso: false)),
        ],
      ),
    );
    await attendi(t);
    await t.tap(find.text('Rispondi a voce'));
    await attendi(t);
    expect(find.textContaining('microfono'), findsOneWidget);
  });

  testWidgets('ripasso in cuffia: pausa e ripresa subito non fanno partire due letture', (t) async {
    await schermoIpad(t);
    await t.runAsync(
      () => repo.salvaCarta(CarteCompanion.insert(corsoId: corso, fronte: 'corrente', retro: 'Flusso di cariche.', origine: OrigineCarta.manuale)),
    );
    final voce = VoceFinta();
    await t.pumpWidget(
      conDati(
        CuffiaPage(corsoId: corso),
        altri: [repositoryProvider.overrideWithValue(repo), voceProvider.overrideWithValue(voce)],
      ),
    );
    await attendi(t);
    await t.tap(find.text('Ascolta'));
    await t.pump(const Duration(seconds: 1));
    await t.tap(find.text('Pausa'));
    await t.pump();
    await t.tap(find.text('Ascolta'));
    for (var i = 0; i < 20; i++) {
      await t.pump(const Duration(seconds: 1));
    }
    // Ogni carta letta per intero una volta (la prima ripresa dal fronte), nessuna saltata.
    expect(voce.dette.where((x) => x.startsWith('Flusso')).length, 1);
    expect(voce.dette.where((x) => x.startsWith('La tensione')).length, 1);
    expect(find.text('Fine delle carte'), findsOneWidget);
  });

  testWidgets('esame orale: uscendo mentre ascolta, il microfono si spegne', (t) async {
    await schermoIpad(t);
    final ascolto = AscoltoFinto('la differenza');
    await t.pumpWidget(
      conDati(
        OralePage(corsoId: corso),
        altri: [repositoryProvider.overrideWithValue(repo), voceProvider.overrideWithValue(VoceFinta()), ascoltoProvider.overrideWithValue(ascolto)],
      ),
    );
    await attendi(t);
    await t.tap(find.text('Rispondi a voce'));
    await attendi(t);
    await t.pumpWidget(const SizedBox());
    expect(ascolto.annullato, isTrue);
  });
}
