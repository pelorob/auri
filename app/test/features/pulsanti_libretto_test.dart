import 'dart:async';

import 'package:auri/app/providers.dart';
import 'package:auri/data/database.dart';
import 'package:auri/data/repository.dart';
import 'package:auri/features/libretto/libretto_page.dart';
import 'package:auri/features/libretto/voto_form.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/esempio.dart';

/// Registra le scritture senza toccare il database.
class RepoFinto extends Repository {
  RepoFinto(super.db);
  final esiti = <EsitiCompanion>[];
  final eliminati = <int>[];
  Completer<void>? attesa;

  @override
  Future<void> registraEsito(EsitiCompanion e) async {
    esiti.add(e);
    await attesa?.future;
  }

  @override
  Future<void> eliminaEsito(int corsoId) async => eliminati.add(corsoId);
}

void main() {
  late AuriDb db;
  late RepoFinto repo;
  setUp(() {
    db = AuriDb(NativeDatabase.memory());
    repo = RepoFinto(db);
  });
  tearDown(() => db.close());

  Future<void> apriLibretto(WidgetTester t) async {
    await schermoIpad(t);
    await t.pumpWidget(conDati(const LibrettoPage(), altri: [repositoryProvider.overrideWithValue(repo)]));
    await t.pump();
  }

  /// Apre il form toccando la riga del corso nel libretto.
  Future<void> apriVoto(WidgetTester t, String corso) async {
    await apriLibretto(t);
    await t.tap(find.text(corso));
    await t.pumpAndSettle();
  }

  String voto(WidgetTester t) => t.widget<Text>(find.byKey(const Key('voto'))).data!;
  SwitchListTile lode(WidgetTester t) => t.widget<SwitchListTile>(find.byType(SwitchListTile));

  group('libretto', () {
    testWidgets('toccare una riga apre il voto di quel corso da modificare', (t) async {
      await apriVoto(t, 'Programmazione');
      expect(find.byType(FormVoto), findsOneWidget);
      expect(voto(t), '29');
      expect(find.text('Togli il voto'), findsOneWidget);
      await t.tap(find.byTooltip('Alza'));
      await t.pump();
      await t.tap(find.text('Salva'));
      await t.pumpAndSettle();
      expect(repo.esiti.single.corsoId.value, 2);
      expect(repo.esiti.single.voto.value, 30);
      expect(find.byType(FormVoto), findsNothing);
    });

    testWidgets('"Registra voto" apre il form vuoto', (t) async {
      await apriLibretto(t);
      await t.tap(find.widgetWithText(FilledButton, 'Registra voto'));
      await t.pumpAndSettle();
      expect(find.byType(FormVoto), findsOneWidget);
      expect(find.text('Togli il voto'), findsNothing);
    });

    testWidgets('simulatore: scegliere un altro corso ricalcola la media', (t) async {
      await apriLibretto(t);
      expect(find.textContaining('27,60'), findsOneWidget); // Analisi, 12 CFU
      await t.tap(find.byType(DropdownButton<int>));
      await t.pumpAndSettle();
      await t.tap(find.text('Basi di Dati · 9 CFU').last);
      await t.pumpAndSettle();
      expect(find.textContaining('27,63'), findsOneWidget);
    });

    testWidgets('simulatore: "Abbassa il voto" porta 27 a 26', (t) async {
      await apriLibretto(t);
      await t.tap(find.bySemanticsLabel('Abbassa il voto'));
      await t.pump();
      expect(find.text('26'), findsNWidgets(2)); // Statistica e il voto ipotetico
      expect(find.textContaining('27,40'), findsOneWidget);
    });

    testWidgets('simulatore: il voto non scende sotto 18', (t) async {
      await apriLibretto(t);
      for (var i = 0; i < 12; i++) {
        await t.tap(find.bySemanticsLabel('Abbassa il voto'));
        await t.pump();
      }
      expect(find.text('18'), findsOneWidget);
    });

    testWidgets('obiettivi 100 e 105 cambiano la media necessaria', (t) async {
      await apriLibretto(t);
      await t.tap(find.text('100'));
      await t.pump();
      expect(find.text('27,10'), findsOneWidget);
      await t.tap(find.text('105'));
      await t.pump();
      expect(find.text('28,97'), findsOneWidget);
    });
  });

  group('form voto', () {
    testWidgets('"Abbassa" toglie un punto', (t) async {
      await apriVoto(t, 'Analisi Matematica I');
      expect(voto(t), '27');
      await t.tap(find.byTooltip('Abbassa'));
      await t.pump();
      expect(voto(t), '26');
    });

    testWidgets('la lode si accende solo a 30 e si spegne scendendo', (t) async {
      await apriVoto(t, 'Programmazione');
      expect(lode(t).onChanged, isNull);
      await t.tap(find.byTooltip('Alza'));
      await t.pump();
      expect(lode(t).onChanged, isNotNull);
      await t.tap(find.text('Lode'));
      await t.pump();
      expect(lode(t).value, isTrue);
      await t.tap(find.byTooltip('Abbassa'));
      await t.pump();
      expect(lode(t).value, isFalse);
      await t.tap(find.byTooltip('Alza'));
      await t.pump();
      await t.tap(find.text('Lode'));
      await t.pump();
      await t.tap(find.text('Salva'));
      await t.pumpAndSettle();
      expect(repo.esiti.single.voto.value, 30);
      expect(repo.esiti.single.lode.value, isTrue);
    });

    testWidgets('la data si sceglie dal calendario', (t) async {
      await apriVoto(t, 'Programmazione'); // 8 luglio 2026
      await t.tap(find.text('Data'));
      await t.pumpAndSettle();
      await t.tap(find.text('20'));
      await t.tap(find.text('OK'));
      await t.pumpAndSettle();
      await t.tap(find.text('Salva'));
      await t.pumpAndSettle();
      expect(repo.esiti.single.data.value, DateTime(2026, 7, 20));
    });

    testWidgets('"Togli il voto" chiede conferma: Annulla lo lascia', (t) async {
      await apriVoto(t, 'Programmazione');
      await t.tap(find.text('Togli il voto'));
      await t.pumpAndSettle();
      expect(find.text('Togliere il voto?'), findsOneWidget);
      expect(repo.eliminati, isEmpty);
      await t.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Annulla')));
      await t.pumpAndSettle();
      expect(repo.eliminati, isEmpty);
      expect(find.byType(FormVoto), findsOneWidget);
    });

    testWidgets('"Togli il voto" confermato lo cancella e chiude il form', (t) async {
      await apriVoto(t, 'Programmazione');
      await t.tap(find.text('Togli il voto'));
      await t.pumpAndSettle();
      await t.tap(find.text('Togli'));
      await t.pumpAndSettle();
      expect(repo.eliminati, [2]);
      expect(find.byType(FormVoto), findsNothing);
    });

    testWidgets('"Annulla" chiude senza salvare', (t) async {
      await apriVoto(t, 'Programmazione');
      await t.tap(find.byTooltip('Alza'));
      await t.tap(find.text('Annulla'));
      await t.pumpAndSettle();
      expect(find.byType(FormVoto), findsNothing);
      expect(repo.esiti, isEmpty);
    });

    testWidgets('due tocchi su "Salva" registrano il voto una volta sola', (t) async {
      repo.attesa = Completer();
      await apriVoto(t, 'Analisi Matematica I');
      await t.tap(find.text('Salva'));
      await t.pump();
      await t.tap(find.text('Salva'), warnIfMissed: false);
      await t.pump();
      repo.attesa!.complete();
      await t.pumpAndSettle();
      expect(repo.esiti, hasLength(1));
      expect(find.byType(FormVoto), findsNothing);
      expect(find.byType(LibrettoPage), findsOneWidget);
    });
  });
}
