import 'dart:async';
import 'dart:io';

import 'package:auri/app/providers.dart';
import 'package:auri/app/tema.dart';
import 'package:auri/data/database.dart';
import 'package:auri/data/repository.dart';
import 'package:auri/domain/modelli.dart';
import 'package:auri/features/corsi/corsi_page.dart';
import 'package:auri/features/corsi/corso_form.dart';
import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/esempio.dart';

Widget conDb(Repository repo, Directory cartella, Widget figlio) => ProviderScope(
  overrides: [
    repositoryProvider.overrideWithValue(repo),
    orologioProvider.overrideWithValue(() => ora),
    cartellaSlideProvider.overrideWithValue(() async => cartella),
  ],
  child: MaterialApp(
    theme: temaAuri(),
    home: Scaffold(body: figlio),
  ),
);

Future<void> attendi(WidgetTester t) async {
  await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
  await t.pumpAndSettle();
}

Future<void> tocca(WidgetTester t, Finder f) async {
  await t.runAsync(() async {
    await t.tap(f);
    await Future<void>.delayed(const Duration(milliseconds: 150));
  });
  await t.pumpAndSettle();
}

/// Il salvataggio resta in corso finché il test non apre il cancello.
class RepoLento extends Repository {
  RepoLento(super.db);
  final cancello = Completer<void>();
  @override
  Future<int> salvaCorso(CorsiCompanion c) async {
    await cancello.future;
    return super.salvaCorso(c);
  }
}

class ApriForm extends StatelessWidget {
  const ApriForm({super.key, this.corso});
  final Corso? corso;
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () => mostraFormCorso(context, corso: corso),
    child: const Text('apri'),
  );
}

void main() {
  late AuriDb db;
  late Repository repo;
  late Directory cartella;
  setUp(() async {
    db = AuriDb(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    repo = Repository(db);
    cartella = await Directory.systemTemp.createTemp('auri_corsi');
    await repo.salvaCorso(CorsiCompanion.insert(nome: 'Programmazione', cfu: 9, valutazione: Valutazione.voto));
    await repo.registraEsito(EsitiCompanion.insert(corsoId: const Value(1), voto: const Value(29), data: DateTime(2026, 7, 8)));
  });
  tearDown(() async {
    await db.close();
    await cartella.delete(recursive: true);
  });

  Future<List<Corso>> corsi(WidgetTester t) async => (await t.runAsync(() => db.select(db.corsi).get()))!;

  group('dettaglio', () {
    Future<void> apriDettaglio(WidgetTester t) async {
      await schermoIpad(t);
      await t.pumpWidget(conDb(repo, cartella, const CorsiPage()));
      await attendi(t);
      await t.tap(find.text('Programmazione'));
      await t.pumpAndSettle();
      await t.tap(find.widgetWithText(TextButton, 'Elimina'));
      await t.pumpAndSettle();
    }

    testWidgets('Elimina: la conferma avvisa anche di slide e flashcard', (t) async {
      await apriDettaglio(t);
      expect(find.text('Eliminare il corso?'), findsOneWidget);
      expect(find.textContaining('PDF delle slide'), findsOneWidget);
      expect(find.textContaining('flashcard'), findsOneWidget);
    });

    testWidgets('Elimina e conferma: il corso sparisce', (t) async {
      await apriDettaglio(t);
      await tocca(t, find.widgetWithText(FilledButton, 'Elimina'));
      expect(await corsi(t), isEmpty);
      expect(find.text('Eliminare il corso?'), findsNothing);
      expect(find.text('Aggiungi il tuo primo corso'), findsOneWidget);
    });

    testWidgets('Elimina e poi Annulla: il corso resta e il dettaglio è ancora aperto', (t) async {
      await apriDettaglio(t);
      await tocca(t, find.text('Annulla'));
      expect(await corsi(t), hasLength(1));
      expect(find.text('Eliminare il corso?'), findsNothing);
      expect(find.text('Nuovo appello'), findsOneWidget);
    });

    Future<void> dettaglioEsempio(WidgetTester t, String nome) async {
      await schermoIpad(t);
      await t.pumpWidget(conDati(const CorsiPage()));
      await t.pump();
      await t.tap(find.text(nome));
      await t.pumpAndSettle();
    }

    testWidgets('Nuovo appello: apre il form con il corso già scelto', (t) async {
      await dettaglioEsempio(t, 'Basi di Dati');
      await t.tap(find.text('Nuovo appello'));
      await t.pumpAndSettle();
      expect(find.text('Nuovo appello'), findsOneWidget);
      expect(find.text('Salva'), findsOneWidget);
      expect(find.descendant(of: find.byType(DropdownButtonFormField<int>), matching: find.text('Basi di Dati')), findsOneWidget);
    });

    testWidgets('Registra voto: apre il form del voto sul corso', (t) async {
      await dettaglioEsempio(t, 'Basi di Dati');
      await t.tap(find.text('Registra voto'));
      await t.pumpAndSettle();
      expect(find.text('Registra voto'), findsOneWidget);
      expect(find.descendant(of: find.byType(DropdownButtonFormField<int>), matching: find.text('Basi di Dati')), findsOneWidget);
    });

    testWidgets('Modifica voto su un corso superato: il form mostra il suo voto', (t) async {
      await dettaglioEsempio(t, 'Programmazione');
      await t.tap(find.text('Modifica voto'));
      await t.pumpAndSettle();
      expect(find.text('Registra voto'), findsOneWidget);
      expect(t.widget<Text>(find.byKey(const Key('voto'))).data, '29');
    });

    testWidgets('Modifica: apre il form del corso compilato', (t) async {
      await dettaglioEsempio(t, 'Basi di Dati');
      await t.tap(find.text('Modifica'));
      await t.pumpAndSettle();
      expect(find.text('Modifica corso'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Basi di Dati'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '9'), findsOneWidget);
    });
  });

  group('form', () {
    testWidgets('anno, semestre, docente e colore scelti vengono salvati', (t) async {
      await schermoIpad(t);
      await t.pumpWidget(conDb(repo, cartella, const FormCorso()));
      await attendi(t);
      await t.enterText(find.byKey(const Key('nome')), 'Basi di Dati');
      await t.enterText(find.byKey(const Key('cfu')), '6');
      await t.tap(find.byType(DropdownButtonFormField<int>));
      await t.pumpAndSettle();
      await t.tap(find.text('3° anno').last);
      await t.pumpAndSettle();
      await t.tap(find.byType(DropdownButtonFormField<int?>));
      await t.pumpAndSettle();
      await t.tap(find.text('2°').last);
      await t.pumpAndSettle();
      await t.enterText(find.widgetWithText(TextFormField, 'Docente (facoltativo)'), 'Rossi');
      await t.tap(find.bySemanticsLabel('Colore #E0457B'));
      await t.pump();
      await t.tap(find.text('Idoneità'));
      await t.pump();
      await tocca(t, find.text('Salva'));
      final c = (await corsi(t)).last;
      expect(c.nome, 'Basi di Dati');
      expect(c.cfu, 6);
      expect(c.anno, 3);
      expect(c.semestre, 2);
      expect(c.docente, 'Rossi');
      expect(c.colore, '#E0457B');
      expect(c.valutazione, Valutazione.idoneita);
    });

    testWidgets('doppio tocco su Salva: un solo corso', (t) async {
      await schermoIpad(t);
      final lento = RepoLento(db);
      await t.pumpWidget(conDb(lento, cartella, const FormCorso()));
      await attendi(t);
      await t.enterText(find.byKey(const Key('nome')), 'Basi di Dati');
      await t.enterText(find.byKey(const Key('cfu')), '6');
      // Due tocchi prima che il database risponda.
      await t.tap(find.text('Salva'));
      await t.pump();
      await t.tap(find.text('Salva'), warnIfMissed: false);
      await t.pump();
      await t.runAsync(() async {
        lento.cancello.complete();
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await t.pumpAndSettle();
      expect((await corsi(t)).where((c) => c.nome == 'Basi di Dati'), hasLength(1));
    });

    testWidgets('da voto a idoneità e poi Annulla: niente cambia', (t) async {
      await schermoIpad(t);
      final corso = (await corsi(t)).single;
      await t.pumpWidget(conDb(repo, cartella, FormCorso(corso: corso)));
      await attendi(t);
      await t.tap(find.text('Idoneità'));
      await t.pump();
      await tocca(t, find.text('Salva'));
      expect(find.textContaining('Il voto registrato verrà tolto'), findsOneWidget);
      await tocca(t, find.descendant(of: find.byType(AlertDialog), matching: find.text('Annulla')));
      expect(find.textContaining('Il voto registrato verrà tolto'), findsNothing);
      expect(find.text('Modifica corso'), findsOneWidget);
      expect((await corsi(t)).single.valutazione, Valutazione.voto);
      expect(await t.runAsync(() => db.select(db.esiti).get()), hasLength(1));
    });

    testWidgets('Annulla chiude senza salvare', (t) async {
      await schermoIpad(t);
      await t.pumpWidget(conDb(repo, cartella, const ApriForm()));
      await attendi(t);
      await t.tap(find.text('apri'));
      await t.pumpAndSettle();
      await t.enterText(find.byKey(const Key('nome')), 'Basi di Dati');
      await t.enterText(find.byKey(const Key('cfu')), '6');
      await tocca(t, find.text('Annulla'));
      expect(find.text('Nuovo corso'), findsNothing);
      expect(await corsi(t), hasLength(1));
    });
  });
}
