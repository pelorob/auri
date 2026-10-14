import 'dart:async';

import 'package:auri/app/providers.dart';
import 'package:auri/app/tema.dart';
import 'package:auri/data/database.dart';
import 'package:auri/data/repository.dart';
import 'package:auri/domain/modelli.dart';
import 'package:auri/features/calendario/appello_form.dart';
import 'package:auri/features/calendario/calendario_page.dart';
import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/esempio.dart';

/// Tutto letto dal database in memoria (non dagli elenchi fissi di esempio).
Widget conDb(Repository repo, Widget figlio, {bool? permesso, Future<bool> Function()? richiesta}) => ProviderScope(
  overrides: [
    repositoryProvider.overrideWithValue(repo),
    orologioProvider.overrideWithValue(() => ora),
    scadenzaFirmaProvider.overrideWith((ref) async => null),
    permessoNotificheProvider.overrideWith((ref) async => permesso),
    richiestaPermessoNotificheProvider.overrideWithValue(richiesta ?? () async => true),
  ],
  child: MaterialApp(
    theme: temaAuri(),
    home: Scaffold(body: figlio),
  ),
);

/// Lascia lavorare il database (fuori dal tempo finto) e ridisegna.
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

/// Un pulsante che apre il form come fa l'app (in un dialogo).
class ApriForm extends StatelessWidget {
  const ApriForm({super.key, this.appello, this.corso});
  final Appello? appello;
  final Corso? corso;
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () => mostraFormAppello(context, appello: appello, corsoIniziale: corso),
    child: const Text('apri'),
  );
}

void main() {
  late AuriDb db;
  late Repository repo;
  late Corso analisi;
  setUp(() async {
    db = AuriDb(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    repo = Repository(db);
    await repo.salvaCorso(CorsiCompanion.insert(nome: 'Analisi Matematica I', cfu: 12, valutazione: Valutazione.voto));
    analisi = (await db.select(db.corsi).get()).single;
  });
  tearDown(() => db.close());

  Future<Appello> nuovoAppello(WidgetTester t, {bool iscritta = false}) async => (await t.runAsync(() async {
    await repo.salvaAppello(
      AppelliCompanion.insert(
        corsoId: analisi.id,
        dataOra: DateTime(2026, 10, 27, 9),
        tipo: TipoAppello.scritto,
        aula: const Value('Aula B2'),
        iscritta: Value(iscritta),
        preavvisi: const Value('7@9:00,1@9:00,0@7:30'),
      ),
    );
    return (await db.select(db.appelli).get()).single;
  }))!;

  Future<List<Appello>> appelli(WidgetTester t) async => (await t.runAsync(() => db.select(db.appelli).get()))!;

  group('pagina', () {
    testWidgets('mese precedente: settembre', (t) async {
      await schermoIpad(t);
      await t.pumpWidget(conDati(const CalendarioPage()));
      await t.pump();
      await t.tap(find.byTooltip('Mese precedente'));
      await t.pump();
      expect(find.text('Settembre 2026'), findsOneWidget);
      await t.tap(find.byTooltip('Mese precedente'));
      await t.pump();
      expect(find.text('Agosto 2026'), findsOneWidget);
    });

    testWidgets('notifiche disattivate: "Apri impostazioni" apre le impostazioni dell\'app', (t) async {
      await schermoIpad(t);
      final aperti = <Object?>[];
      const canale = MethodChannel('plugins.flutter.io/url_launcher');
      t.binding.defaultBinaryMessenger.setMockMethodCallHandler(canale, (c) async {
        aperti.add((c.arguments as Map)['url']);
        return true;
      });
      addTearDown(() => t.binding.defaultBinaryMessenger.setMockMethodCallHandler(canale, null));
      await t.pumpWidget(conDati(const CalendarioPage(), altri: [permessoNotificheProvider.overrideWith((ref) async => false)]));
      await t.pumpAndSettle();
      expect(find.textContaining('Le notifiche sono disattivate'), findsOneWidget);
      await t.tap(find.text('Apri impostazioni'));
      await t.pumpAndSettle();
      expect(aperti, ['app-settings:']);
    });

    testWidgets('toccare il giorno dell\'esame apre il suo appello', (t) async {
      await schermoIpad(t);
      await t.pumpWidget(conDati(const CalendarioPage()));
      await t.pump();
      await t.tap(find.text('Analisi Matematica I · scritto'));
      await t.pumpAndSettle();
      expect(find.text('Modifica appello'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Aula B2'), findsOneWidget);
    });

    testWidgets('due esami lo stesso giorno: si sceglie quale aprire', (t) async {
      await schermoIpad(t);
      final secondo = AppelloConCorso(
        Appello(id: 3, corsoId: 9, dataOra: DateTime(2026, 10, 27, 14), tipo: TipoAppello.orale, aula: 'Aula C', iscritta: false, preavvisi: ''),
        corsiEsempio[8].corso,
      );
      await t.pumpWidget(conDati(const CalendarioPage(), appelli: [appelliEsempio[0], secondo, appelliEsempio[1]]));
      await t.pump();
      await t.tap(find.text('Analisi Matematica I · scritto'));
      await t.pumpAndSettle();
      expect(find.text('Quale appello?'), findsOneWidget);
      await t.tap(find.widgetWithText(ListTile, 'Basi di Dati'));
      await t.pumpAndSettle();
      expect(find.text('Quale appello?'), findsNothing);
      expect(find.text('Modifica appello'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Aula C'), findsOneWidget);
    });

    testWidgets('un solo esame nel giorno: niente scelta, apre subito', (t) async {
      await schermoIpad(t);
      await t.pumpWidget(conDati(const CalendarioPage()));
      await t.pump();
      await t.tap(find.text('Analisi Matematica I · scritto'));
      await t.pumpAndSettle();
      expect(find.text('Quale appello?'), findsNothing);
      expect(find.text('Modifica appello'), findsOneWidget);
    });

    testWidgets('toccare la scheda dell\'appello lo apre in modifica', (t) async {
      await schermoIpad(t);
      await t.pumpWidget(conDati(const CalendarioPage()));
      await t.pump();
      await t.tap(find.textContaining('Lab 3'));
      await t.pumpAndSettle();
      expect(find.text('Modifica appello'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Lab 3'), findsOneWidget);
    });

    testWidgets('Iscritta / Non iscritta: si salva nel database', (t) async {
      await schermoIpad(t);
      await nuovoAppello(t);
      await t.pumpWidget(conDb(repo, const CalendarioPage()));
      await attendi(t);
      await tocca(t, find.text('Non iscritta'));
      expect((await appelli(t)).single.iscritta, isTrue);
      expect(find.text('Iscritta'), findsOneWidget);
      await tocca(t, find.text('Iscritta'));
      expect((await appelli(t)).single.iscritta, isFalse);
      expect(find.text('Non iscritta'), findsOneWidget);
    });
  });

  group('form', () {
    testWidgets('tipo, aula, note e avvisi scelti vengono salvati', (t) async {
      await schermoIpad(t);
      await t.pumpWidget(conDb(repo, FormAppello(corsoIniziale: analisi)));
      await attendi(t);
      await t.tap(find.text('Orale'));
      await t.enterText(find.widgetWithText(TextField, 'Aula (facoltativa)'), 'Aula Magna');
      await t.enterText(find.widgetWithText(TextField, 'Note (facoltative)'), 'portare il libretto');
      // Predefiniti: tutti e tre attivi. Tolgo "7 giorni prima" e "La mattina".
      await t.tap(find.text('7 giorni prima'));
      await t.tap(find.text('La mattina'));
      await t.pump();
      await tocca(t, find.text('Salva'));
      final a = (await appelli(t)).single;
      expect(a.tipo, TipoAppello.orale);
      expect(a.aula, 'Aula Magna');
      expect(a.note, 'portare il libretto');
      expect(a.preavvisi, '1@9:00');
    });

    testWidgets('tipo Altro e Scritto', (t) async {
      await schermoIpad(t);
      await t.pumpWidget(conDb(repo, FormAppello(corsoIniziale: analisi)));
      await attendi(t);
      await t.tap(find.text('Altro'));
      await t.pump();
      await tocca(t, find.text('Salva'));
      expect((await appelli(t)).single.tipo, TipoAppello.altro);
      final a = (await appelli(t)).single;
      await t.pumpWidget(conDb(repo, FormAppello(key: const Key('2'), appello: a)));
      await attendi(t);
      await t.tap(find.text('Scritto'));
      await t.pump();
      await tocca(t, find.text('Salva'));
      expect((await appelli(t)).single.tipo, TipoAppello.scritto);
    });

    testWidgets('doppio tocco su Salva: un solo appello', (t) async {
      await schermoIpad(t);
      // Il salvataggio resta in corso finché il permesso non risponde.
      final permesso = Completer<bool>();
      await t.pumpWidget(conDb(repo, FormAppello(corsoIniziale: analisi), richiesta: () => permesso.future));
      await attendi(t);
      await t.tap(find.text('Salva'));
      await t.pump();
      await t.tap(find.text('Salva'), warnIfMissed: false);
      await t.pump();
      await t.runAsync(() async {
        permesso.complete(true);
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await t.pumpAndSettle();
      expect(await appelli(t), hasLength(1));
    });

    testWidgets('senza corso: "Scegli il corso" e nulla salvato', (t) async {
      await schermoIpad(t);
      await t.pumpWidget(conDb(repo, const FormAppello()));
      await attendi(t);
      await tocca(t, find.text('Salva'));
      expect(find.text('Scegli il corso'), findsOneWidget);
      expect(await appelli(t), isEmpty);
    });

    testWidgets('scegliendo il corso dal menu si può salvare', (t) async {
      await schermoIpad(t);
      await t.pumpWidget(conDb(repo, const FormAppello()));
      await attendi(t);
      await t.tap(find.byType(DropdownButtonFormField<int>));
      await t.pumpAndSettle();
      await t.tap(find.text('Analisi Matematica I').last);
      await t.pumpAndSettle();
      await tocca(t, find.text('Salva'));
      expect((await appelli(t)).single.corsoId, analisi.id);
    });

    testWidgets('Elimina con conferma: l\'appello sparisce', (t) async {
      await schermoIpad(t);
      final a = await nuovoAppello(t);
      await t.pumpWidget(conDb(repo, ApriForm(appello: a)));
      await attendi(t);
      await t.tap(find.text('apri'));
      await t.pumpAndSettle();
      await t.tap(find.text('Elimina'));
      await t.pumpAndSettle();
      expect(find.text('Eliminare l\'appello?'), findsOneWidget);
      await tocca(t, find.widgetWithText(FilledButton, 'Elimina'));
      expect(await appelli(t), isEmpty);
      expect(find.text('Modifica appello'), findsNothing);
    });

    testWidgets('Elimina e poi Annulla: l\'appello resta e il form è ancora aperto', (t) async {
      await schermoIpad(t);
      final a = await nuovoAppello(t);
      await t.pumpWidget(conDb(repo, ApriForm(appello: a)));
      await attendi(t);
      await t.tap(find.text('apri'));
      await t.pumpAndSettle();
      await t.tap(find.text('Elimina'));
      await t.pumpAndSettle();
      await tocca(t, find.descendant(of: find.byType(AlertDialog), matching: find.text('Annulla')));
      expect(await appelli(t), hasLength(1));
      expect(find.text('Eliminare l\'appello?'), findsNothing);
      expect(find.text('Modifica appello'), findsOneWidget);
    });

    testWidgets('Annulla chiude senza salvare', (t) async {
      await schermoIpad(t);
      await t.pumpWidget(conDb(repo, ApriForm(corso: analisi)));
      await attendi(t);
      await t.tap(find.text('apri'));
      await t.pumpAndSettle();
      await t.enterText(find.widgetWithText(TextField, 'Aula (facoltativa)'), 'Aula Magna');
      await tocca(t, find.text('Annulla'));
      expect(find.text('Nuovo appello'), findsNothing);
      expect(await appelli(t), isEmpty);
    });

    testWidgets('Salva nel dialogo: salva e chiude', (t) async {
      await schermoIpad(t);
      await t.pumpWidget(conDb(repo, ApriForm(corso: analisi)));
      await attendi(t);
      await t.tap(find.text('apri'));
      await t.pumpAndSettle();
      await tocca(t, find.text('Salva'));
      expect(find.text('Nuovo appello'), findsNothing);
      expect(await appelli(t), hasLength(1));
    });

    testWidgets('giorno e ora scelti dai selettori vengono salvati', (t) async {
      await schermoIpad(t);
      final a = await nuovoAppello(t);
      await t.pumpWidget(conDb(repo, FormAppello(appello: a)));
      await attendi(t);
      await t.tap(find.text('Giorno'));
      await t.pumpAndSettle();
      await t.tap(find.text('20'));
      await t.tap(find.text('OK'));
      await t.pumpAndSettle();
      await t.tap(find.text('Ora'));
      await t.pumpAndSettle();
      // Passo all'inserimento da tastiera: più affidabile del quadrante.
      await t.tap(find.byIcon(Icons.keyboard_outlined));
      await t.pumpAndSettle();
      final campi = find.descendant(of: find.byType(TimePickerDialog), matching: find.byType(TextField));
      await t.enterText(campi.at(0), '2');
      await t.enterText(campi.at(1), '30');
      await t.pump();
      await t.tap(find.text('OK'));
      await t.pumpAndSettle();
      await tocca(t, find.text('Salva'));
      final dopo = (await appelli(t)).single.dataOra;
      expect(DateTime(dopo.year, dopo.month, dopo.day), DateTime(2026, 10, 20));
      expect(dopo.minute, 30);
      expect(dopo.hour, 2);
    });
  });
}
