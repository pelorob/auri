import 'dart:async';
import 'dart:io';

import 'package:auri/app/blocco.dart';
import 'package:auri/app/blocco_page.dart';
import 'package:auri/app/providers.dart';
import 'package:auri/app/serializzatore.dart';
import 'package:auri/app/shell.dart';
import 'package:auri/data/database.dart';
import 'package:auri/data/repository.dart';
import 'package:auri/domain/modelli.dart';
import 'package:auri/domain/preferenze.dart';
import 'package:auri/features/corsi/corsi_page.dart';
import 'package:auri/features/corsi/corso_form.dart';
import 'package:auri/features/impostazioni/backup_azioni.dart';
import 'package:auri/features/impostazioni/impostazioni_page.dart';
import 'package:auri/features/oggi/oggi_page.dart';
import 'package:auri/services/backup.dart';
import 'package:auri/services/touch_id.dart';
import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:sqlite3/sqlite3.dart';

import 'helpers/esempio.dart';

class TouchIdPresente extends TouchIdService {
  @override
  Future<bool> disponibile() async => true;
  @override
  Future<bool> autentica() async => false;
}

void main() {
  testWidgets('il giorno dell\'esame la Home scrive "Oggi", non "0 giorni"', (t) async {
    await schermoIpad(t);
    final oggi = AppelloConCorso(
      Appello(id: 9, corsoId: 8, dataOra: DateTime(2026, 10, 13, 14), tipo: TipoAppello.scritto, iscritta: true, preavvisi: ''),
      corsiEsempio[7].corso,
    );
    await t.pumpWidget(conDati(const OggiPage(), appelli: [oggi]));
    await t.pump();
    expect(find.text('Oggi'), findsOneWidget);
    expect(find.text('in bocca al lupo!'), findsOneWidget);
    expect(find.text('0 g'), findsNothing);
    expect(find.text('oggi'), findsOneWidget);
  });

  testWidgets('in verticale c\'è il pulsante "Blocca app" quando il blocco è attivo', (t) async {
    t.view.physicalSize = const Size(820, 1180);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(conDati(const AuriShell(), preferenze: const Preferenze(primoAvvioFatto: true, bloccoAttivo: true)));
    await t.pump();
    expect(find.byTooltip('Blocca app'), findsOneWidget);
  });

  testWidgets('la copertura nasconde i dati quando l\'app va in background', (t) async {
    await t.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          builder: (c, child) => StratoBlocco(child: child!),
          home: const Text('Voti segreti'),
        ),
      ),
    );
    final c = ProviderScope.containerOf(t.element(find.text('Voti segreti')));
    c.read(coperturaProvider.notifier).copri();
    await t.pump();
    expect(find.byKey(const Key('copertura')), findsOneWidget);
    expect(find.text('Voti segreti').hitTestable(), findsNothing);
    c.read(coperturaProvider.notifier).scopri();
    await t.pump();
    expect(find.byKey(const Key('copertura')), findsNothing);
  });

  test('le riprogrammazioni vengono eseguite una alla volta, in ordine', () async {
    final s = Serializzatore();
    final log = <String>[];
    final a = s.esegui(() async {
      log.add('a-inizio');
      await Future<void>.delayed(const Duration(milliseconds: 30));
      log.add('a-fine');
    });
    final b = s.esegui(() async => log.add('b'));
    await Future.wait([a, b]);
    expect(log, ['a-inizio', 'a-fine', 'b']);
  });

  test('un errore in una esecuzione non blocca le successive', () async {
    final s = Serializzatore();
    final log = <String>[];
    unawaited(s.esegui(() async => throw StateError('x')).catchError((_) {}));
    await s.esegui(() async => log.add('dopo'));
    expect(log, ['dopo']);
  });

  test('backup di una versione futura dello schema: rifiutato', () async {
    final tmp = await Directory.systemTemp.createTemp('auri_v');
    addTearDown(() => tmp.delete(recursive: true));
    final f = File(p.join(tmp.path, 'futuro.auri'));
    sqlite3.open(f.path)
      ..execute('CREATE TABLE corsi (id INTEGER); CREATE TABLE esiti (id INTEGER); CREATE TABLE appelli (id INTEGER); CREATE TABLE impostazioni (id INTEGER);')
      ..execute('PRAGMA user_version = 99')
      ..close();
    expect(() => verificaBackup(f), throwsA(isA<BackupNonValido>()));
  });

  test('il backup conta come fatto solo se la condivisione è riuscita', () {
    expect(esportazioneRiuscita(ShareResultStatus.success), isTrue);
    expect(esportazioneRiuscita(ShareResultStatus.dismissed), isFalse);
    expect(esportazioneRiuscita(ShareResultStatus.unavailable), isFalse);
  });

  group('con database', () {
    late AuriDb db;
    late Repository repo;
    setUp(() async {
      db = AuriDb(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
      repo = Repository(db);
      await repo.salvaCorso(CorsiCompanion.insert(nome: 'Programmazione', cfu: 9, valutazione: Valutazione.voto));
      await repo.registraEsito(EsitiCompanion.insert(corsoId: const Value(1), voto: const Value(29), data: DateTime(2026, 7, 8)));
    });
    tearDown(() => db.close());

    testWidgets('il nome del corso di laurea si salva anche senza premere Invio', (t) async {
      await schermoIpad(t);
      await t.pumpWidget(conDati(const ImpostazioniPage(), altri: [repositoryProvider.overrideWithValue(repo)]));
      await t.pumpAndSettle();
      await t.runAsync(() async {
        await t.enterText(find.widgetWithText(TextFormField, 'Nome del corso di laurea'), 'Ingegneria');
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      final pref = await t.runAsync(() => repo.guardaPreferenze().first);
      expect(pref!.nomeCorsoDiLaurea, 'Ingegneria');
    });

    testWidgets('passare da voto a idoneità con un voto registrato: chiede conferma e toglie il voto', (t) async {
      await schermoIpad(t);
      final corso = (await t.runAsync(() => db.select(db.corsi).get()))!.single;
      await t.pumpWidget(conDati(FormCorso(corso: corso), altri: [repositoryProvider.overrideWithValue(repo)]));
      await t.pump();
      await t.tap(find.text('Idoneità'));
      await t.pump();
      await t.tap(find.text('Salva'));
      await t.pumpAndSettle();
      expect(find.textContaining('Il voto registrato verrà tolto'), findsOneWidget);
      await t.runAsync(() async {
        await t.tap(find.text('Continua'));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await t.pump();
      final esiti = await t.runAsync(() => db.select(db.esiti).get());
      final dopo = await t.runAsync(() => db.select(db.corsi).get());
      expect(esiti, isEmpty);
      expect(dopo!.single.valutazione, Valutazione.idoneita);
    });
  });

  testWidgets('il dettaglio del corso elenca i suoi appelli', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(conDati(const CorsiPage()));
    await t.pump();
    await t.tap(find.text('Analisi Matematica I'));
    await t.pumpAndSettle();
    expect(find.text('Scritto · 27 ottobre · 9:00'), findsOneWidget);
  });

  testWidgets('impostazioni con Touch ID e blocco attivi: nessun errore di disegno', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(
      conDati(
        const ImpostazioniPage(),
        preferenze: const Preferenze(primoAvvioFatto: true, bloccoAttivo: true),
        altri: [touchIdDisponibileProvider.overrideWith((ref) async => true), touchIdProvider.overrideWithValue(TouchIdPresente())],
      ),
    );
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(find.text('Richiedi lo sblocco dopo'), findsOneWidget);
  });

  test('bloccoProvider resta invariato da copri/scopri', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(coperturaProvider.notifier).copri();
    expect(c.read(bloccoProvider), isFalse);
  });
}
