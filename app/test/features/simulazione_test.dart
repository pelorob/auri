import 'dart:math';

import 'package:auri/app/providers.dart';
import 'package:auri/data/database.dart';
import 'package:auri/data/repository.dart';
import 'package:auri/domain/modelli.dart';
import 'package:auri/domain/quiz.dart';
import 'package:auri/domain/slide.dart';
import 'package:auri/features/ripasso/simulazione_page.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/esempio.dart';

const testi = [
  'Legge di Ohm\nLa resistenza elettrica e’ il rapporto tra tensione e corrente.\nSi definisce resistenza R = V / I.',
  'Legge di Ohm\nLa corrente elettrica scorre nei circuiti in serie.\nLe resistenze in serie si sommano.',
  'Potenza elettrica\nLa potenza e’ il prodotto di tensione e corrente.\nDefinizione: P = V * I.',
  'Circuiti\nIl condensatore è un componente che accumula carica nei circuiti.\nLa tensione ai capi del condensatore cresce.',
];

void main() {
  late AuriDb db;
  late Repository repo;
  late int corso;

  setUp(() async {
    db = AuriDb(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    repo = Repository(db);
    corso = await repo.salvaCorso(CorsiCompanion.insert(nome: 'Fisica II', cfu: 9, valutazione: Valutazione.voto));
  });
  tearDown(() => db.close());

  Future<void> conPdf() => repo.salvaDocumento(
    DocumentiCompanion.insert(corsoId: corso, titolo: 'Elettricità', nomeFile: 'a.pdf', numeroPagine: 4, importatoIl: DateTime(2026, 10, 13)),
    [for (var i = 0; i < 4; i++) (numero: i + 1, titolo: titoloPagina(testi[i]), testo: testi[i])],
  );

  Widget app(Widget w) => conDati(w, altri: [repositoryProvider.overrideWithValue(repo), casoProvider.overrideWithValue(() => Random(42))]);

  Future<void> attendi(WidgetTester t) async {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
    await t.pump();
  }

  testWidgets('tutte giuste: voto 30, simulazione salvata', (t) async {
    await schermoIpad(t);
    await t.runAsync(conPdf);
    final attese = generaQuiz(
      [
        MaterialeDocumento(documentoId: 1, testoPerPagina: {for (var i = 0; i < 4; i++) i + 1: testi[i]}),
      ],
      quante: 5,
      caso: Random(42),
    );
    await t.pumpWidget(app(SimulazionePage(corsoId: corso, quante: 5)));
    await attendi(t);
    expect(find.text('DOMANDA 1 DI 5'), findsOneWidget);
    for (final d in attese) {
      await t.tap(find.widgetWithText(FilledButton, d.opzioni[d.giusta]).first);
      await t.pump();
    }
    await attendi(t);
    expect(find.text('30'), findsOneWidget);
    expect(find.text('Superato'), findsOneWidget);
    final s = (await t.runAsync(() => db.select(db.simulazioni).get()))!;
    expect(s.single.voto, 30);
    expect(s.single.giuste, 5);
    await t.pumpWidget(const SizedBox());
  });

  testWidgets('tutte sbagliate: non superato, errori con la pagina', (t) async {
    await schermoIpad(t);
    await t.runAsync(conPdf);
    final attese = generaQuiz(
      [
        MaterialeDocumento(documentoId: 1, testoPerPagina: {for (var i = 0; i < 4; i++) i + 1: testi[i]}),
      ],
      quante: 3,
      caso: Random(42),
    );
    await t.pumpWidget(app(SimulazionePage(corsoId: corso, quante: 3)));
    await attendi(t);
    for (final d in attese) {
      await t.tap(find.widgetWithText(FilledButton, d.opzioni[(d.giusta + 1) % d.opzioni.length]).first);
      await t.pump();
    }
    await attendi(t);
    expect(find.text('Non superato'), findsOneWidget);
    expect(find.textContaining('pag. '), findsWidgets);
    await t.pumpWidget(const SizedBox());
  });

  testWidgets('"Domanda sbagliata" durante il quiz: non conta e non torna più', (t) async {
    await schermoIpad(t);
    await t.runAsync(conPdf);
    await t.pumpWidget(app(SimulazionePage(corsoId: corso, quante: 3)));
    await attendi(t);
    expect(find.text('DOMANDA 1 DI 3'), findsOneWidget);
    await t.runAsync(() async {
      await t.tap(find.text('Domanda sbagliata, non mostrarla più'));
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    await t.pump();
    expect(find.text('DOMANDA 1 DI 2'), findsOneWidget);
    final escluse = (await t.runAsync(() => repo.domandeEscluse()))!;
    expect(escluse.single.$2, contains('____'));
    await t.pumpWidget(const SizedBox());
  });

  testWidgets('"Domanda sbagliata" nei risultati: segnata come esclusa', (t) async {
    await schermoIpad(t);
    await t.runAsync(conPdf);
    final attese = generaQuiz(
      [
        MaterialeDocumento(documentoId: 1, testoPerPagina: {for (var i = 0; i < 4; i++) i + 1: testi[i]}),
      ],
      quante: 2,
      caso: Random(42),
    );
    await t.pumpWidget(app(SimulazionePage(corsoId: corso, quante: 2)));
    await attendi(t);
    for (final d in attese) {
      await t.tap(find.widgetWithText(FilledButton, d.opzioni[(d.giusta + 1) % d.opzioni.length]).first);
      await t.pump();
    }
    await attendi(t);
    await t.runAsync(() async {
      await t.tap(find.text('Domanda sbagliata, non mostrarla più').first);
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    await t.pump();
    expect(find.text('Non la vedrai più'), findsOneWidget);
    expect((await t.runAsync(() => repo.domandeEscluse()))!.length, 1);
    await t.pumpWidget(const SizedBox());
  });

  testWidgets('poco materiale: messaggio chiaro', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(app(SimulazionePage(corsoId: corso, quante: 10)));
    await attendi(t);
    expect(find.text('Importa più slide per generare un quiz.'), findsOneWidget);
    await t.pumpWidget(const SizedBox());
  });
}
