import 'dart:io';

import 'package:auri/app/providers.dart';
import 'package:auri/app/shell.dart';
import 'package:auri/data/database.dart';
import 'package:auri/data/repository.dart';
import 'package:auri/domain/modelli.dart';
import 'package:auri/domain/ripasso.dart';
import 'package:auri/domain/slide.dart';
import 'package:auri/features/ripasso/ripasso_page.dart';
import 'package:auri/features/ripasso/sessione_ripasso_page.dart';
import 'package:auri/features/ripasso/simulazione_page.dart';
import 'package:auri/features/slide/documento_page.dart';
import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/esempio.dart';

void main() {
  late AuriDb db;
  late Repository repo;
  late int fisica;
  late List<CorsoConEsito> corsiDb;

  setUp(() async {
    db = AuriDb(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    repo = Repository(db);
    fisica = await repo.salvaCorso(CorsiCompanion.insert(nome: 'Fisica II', cfu: 9, valutazione: Valutazione.voto));
    await repo.salvaCarta(CarteCompanion.insert(corsoId: fisica, fronte: 'Unità della resistenza?', retro: 'ohm', origine: OrigineCarta.manuale));
    await repo.salvaCarta(
      CarteCompanion.insert(corsoId: fisica, fronte: 'Carta di domani', retro: 'x', origine: OrigineCarta.manuale, prossima: Value(DateTime(2026, 10, 20))),
    );
    corsiDb = await repo.guardaCorsi().first;
  });
  tearDown(() => db.close());

  Widget app(Widget w) => conDati(
    w,
    corsi: corsiDb,
    altri: [
      repositoryProvider.overrideWithValue(repo),
      carteProvider.overrideWith((ref) => repo.guardaCarte(null)),
      documentiProvider.overrideWith((ref) => repo.guardaDocumenti()),
      cartellaSlideProvider.overrideWithValue(() async => Directory.systemTemp),
      visualizzatorePdfProvider.overrideWithValue((percorso, pagina, documento, _) => Text('PDF pagina $pagina')),
    ],
  );

  Future<void> attendiDb(WidgetTester t) async {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
    await t.pump();
  }

  testWidgets('menu: Ripasso è attivo, solo Lezioni resta "presto"', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(app(const AuriShell()));
    await t.pump();
    expect(find.text('presto'), findsOneWidget);
    await t.tap(find.text('Ripasso'));
    await attendiDb(t);
    expect(find.text('Nuova carta'), findsOneWidget);
  });

  testWidgets('elenco: carte da ripassare oggi per corso', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(app(const RipassoPage()));
    await attendiDb(t);
    expect(find.text('Fisica II'), findsWidgets);
    expect(find.text('1 da ripassare · 2 carte'), findsOneWidget);
  });

  testWidgets('sessione: mostra risposta, "Giusta", poi fine', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(app(SessioneRipassoPage(corsoId: fisica)));
    await attendiDb(t);
    expect(find.text('Unità della resistenza?'), findsOneWidget);
    expect(find.text('Carta di domani'), findsNothing);
    expect(find.text('Prima volta'), findsOneWidget);
    await t.tap(find.text('Mostra risposta'));
    await t.pump();
    expect(find.text('ohm'), findsOneWidget);
    await t.runAsync(() async {
      await t.tap(find.text('Giusta'));
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    await t.pump();
    expect(find.textContaining('Hai ripassato 1 carta'), findsOneWidget);
    final c = (await t.runAsync(() => db.select(db.carte).get()))!.firstWhere((x) => x.fronte == 'Unità della resistenza?');
    expect(c.ripetizioni, 1);
  });

  testWidgets('documento: "Crea flashcard" crea le carte dal PDF', (t) async {
    await schermoIpad(t);
    final testi = [
      'Legge di Ohm\nLa resistenza elettrica e’ il rapporto tra tensione e corrente.\nSi definisce resistenza R = V / I.',
      'Legge di Ohm\nLe resistenze in serie si sommano.',
      'Potenza elettrica\nLa potenza e’ il prodotto di tensione e corrente.\nDefinizione: P = V * I.',
    ];
    final doc = (await t.runAsync(
      () => repo.salvaDocumento(
        DocumentiCompanion.insert(corsoId: fisica, titolo: 'Elettricità', nomeFile: 'a.pdf', numeroPagine: 3, importatoIl: DateTime(2026, 10, 13)),
        [for (var i = 0; i < 3; i++) (numero: i + 1, titolo: titoloPagina(testi[i]), testo: testi[i])],
      ),
    ))!;
    await t.pumpWidget(app(DocumentoPage(documentoId: doc)));
    await attendiDb(t);
    await t.runAsync(() async {
      await t.tap(find.text('Crea flashcard'));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await t.pump();
    expect(find.textContaining('flashcard create'), findsOneWidget);
    expect((await t.runAsync(() => db.select(db.carte).get()))!.length, greaterThan(2));
  });

  testWidgets('corso con slide: "Simulazione d esame" chiede quante domande e la apre', (t) async {
    await schermoIpad(t);
    await t.runAsync(
      () => repo.salvaDocumento(
        DocumentiCompanion.insert(corsoId: fisica, titolo: 'Elettricità', nomeFile: 'a.pdf', numeroPagine: 1, importatoIl: DateTime(2026, 10, 13)),
        [(numero: 1, titolo: 'T', testo: 'T uno')],
      ),
    );
    await t.pumpWidget(app(const RipassoPage()));
    await attendiDb(t);
    await t.tap(find.text("Simulazione d'esame"));
    await t.pumpAndSettle();
    await t.tap(find.text('20 domande'));
    await t.pumpAndSettle();
    expect(find.byType(SimulazionePage), findsOneWidget);
    await t.pumpWidget(const SizedBox());
  });
}
