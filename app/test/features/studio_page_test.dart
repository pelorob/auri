import 'dart:io';

import 'package:auri/app/providers.dart';
import 'package:auri/data/database.dart';
import 'package:auri/data/repository.dart';
import 'package:auri/domain/modelli.dart';
import 'package:auri/features/calendario/calendario_page.dart';
import 'package:auri/features/oggi/oggi_page.dart';
import 'package:auri/features/slide/documento_page.dart';
import 'package:auri/features/studio/studio_page.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:auri/features/studio/pomodoro.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/esempio.dart';

void main() {
  late AuriDb db;
  late Repository repo;
  late int analisi;
  late int doc;
  late List<CorsoConEsito> corsiDb;
  late List<AppelloConCorso> appelliDb;

  setUp(() async {
    db = AuriDb(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    repo = Repository(db);
    analisi = await repo.salvaCorso(CorsiCompanion.insert(nome: 'Analisi Matematica I', cfu: 12, valutazione: Valutazione.voto));
    await repo.salvaAppello(AppelliCompanion.insert(corsoId: analisi, dataOra: DateTime(2026, 10, 27, 9), tipo: TipoAppello.scritto));
    doc = await repo.salvaDocumento(
      DocumentiCompanion.insert(corsoId: analisi, titolo: 'Limiti', nomeFile: 'a.pdf', numeroPagine: 140, importatoIl: DateTime(2026, 10, 1)),
      [for (var i = 1; i <= 140; i++) (numero: i, titolo: 'Pagina $i', testo: 'Pagina $i\ntesto')],
    );
    await repo.salvaSessione(corsoId: analisi, inizio: DateTime(2026, 10, 12, 9), minuti: 50);
    corsiDb = await repo.guardaCorsi().first;
    appelliDb = await repo.guardaAppelli().first;
  });
  tearDown(() => db.close());

  Widget app(Widget w) => conDati(
    w,
    corsi: corsiDb,
    appelli: appelliDb,
    altri: [
      repositoryProvider.overrideWithValue(repo),
      documentiProvider.overrideWith((ref) => repo.guardaDocumenti()),
      sessioniProvider.overrideWith((ref) => repo.guardaSessioni()),
      pagineStudiateProvider.overrideWith((ref) => repo.guardaPagineStudiate()),
      revisioniProvider.overrideWith((ref) => repo.guardaRevisioni()),
      carteProvider.overrideWith((ref) => repo.guardaCarte(null)),
      simulazioniProvider.overrideWith((ref) => repo.guardaSimulazioni(null)),
      cartellaSlideProvider.overrideWithValue(() async => Directory.systemTemp),
      visualizzatorePdfProvider.overrideWithValue(
        (percorso, pagina, documento, cambiata) => TextButton(onPressed: () => cambiata(3), child: Text('PDF pagina $pagina')),
      ),
    ],
  );

  Future<void> attendi(WidgetTester t) async {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await t.pump();
    await t.pump();
  }

  testWidgets('Studio: Pomodoro che scorre, piano per l\'esame, minuti di studio', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(app(const StudioPage()));
    final contenitore = ProviderScope.containerOf(t.element(find.byType(StudioPage)));
    // Spegne il timer anche se il test fallisce (se la pagina è già stata smontata non serve).
    addTearDown(() {
      try {
        contenitore.read(pomodoroProvider.notifier).ferma();
      } on StateError catch (_) {}
    });
    await attendi(t);
    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('Oggi: 10 pagine'), findsOneWidget);
    expect(find.textContaining('50 min'), findsWidgets);
    await t.tap(find.text('Inizia'));
    await t.pump(const Duration(seconds: 1));
    await t.pump(const Duration(seconds: 1));
    expect(find.text('24:58'), findsOneWidget);
    await t.tap(find.text('Ferma'));
    await t.pump();
    expect(find.text('25:00'), findsOneWidget);
  });

  testWidgets('Home: barra del piano di ripasso sotto il prossimo esame', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(app(const OggiPage()));
    await attendi(t);
    expect(find.textContaining('Piano di ripasso 0%'), findsOneWidget);
    expect(find.textContaining('oggi 10 pagine'), findsOneWidget);
  });

  testWidgets('Calendario: giorni di ripasso colorati fino al giorno prima dell\'esame', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(app(const CalendarioPage()));
    await attendi(t);
    expect(find.byKey(const ValueKey('ripasso-2026-10-20')), findsOneWidget);
    expect(find.byKey(const ValueKey('ripasso-2026-10-27')), findsNothing);
  });

  testWidgets('Documento: "Ho studiato questa pagina"', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(app(DocumentoPage(documentoId: doc)));
    await attendi(t);
    await t.runAsync(() async {
      await t.tap(find.text('Ho studiato questa pagina'));
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    await t.pump();
    final p = (await t.runAsync(() => db.select(db.pagineStudiate).get()))!;
    expect(p.single.pagina, 1);
  });

  testWidgets('Documento: dopo aver scorso il PDF, "Ho studiato" segna la pagina visibile', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(app(DocumentoPage(documentoId: doc)));
    await attendi(t);
    await t.tap(find.text('PDF pagina 1')); // simula lo scorrimento fino a pagina 3
    await t.pump();
    expect(find.text('pagina 3'), findsOneWidget);
    await t.runAsync(() async {
      await t.tap(find.text('Ho studiato questa pagina'));
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    await t.pump();
    final p = (await t.runAsync(() => db.select(db.pagineStudiate).get()))!;
    expect(p.single.pagina, 3);
  });
}
