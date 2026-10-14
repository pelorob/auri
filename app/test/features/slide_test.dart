import 'dart:io';

import 'package:auri/app/providers.dart';
import 'package:auri/app/shell.dart';
import 'package:auri/data/database.dart';
import 'package:auri/data/repository.dart';
import 'package:auri/domain/modelli.dart';
import 'package:auri/domain/slide.dart';
import 'package:auri/features/slide/documento_page.dart';
import 'package:auri/features/slide/slide_page.dart';
import 'package:auri/services/ocr.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/esempio.dart';

const testiOhm = [
  'Legge di Ohm\nLa resistenza elettrica e’ il rapporto tra tensione e corrente.\nSi definisce resistenza R = V / I.',
  'Legge di Ohm\nEsempi di circuiti in serie e in parallelo.\nLe resistenze in serie si sommano.',
  'Potenza elettrica\nLa potenza e’ il prodotto di tensione e corrente.\nDefinizione: P = V * I.',
];

void main() {
  test('estratto: le parti tra [ ] sono evidenziate', () {
    expect(segmentiEstratto('La [resistenza] elettrica e la [resistenza]'), [
      ('La ', false),
      ('resistenza', true),
      (' elettrica e la ', false),
      ('resistenza', true),
    ]);
    expect(segmentiEstratto('niente'), [('niente', false)]);
  });

  testWidgets('il menu ha la voce "Slide"', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(conDati(const AuriShell(), altri: [documentiProvider.overrideWith((ref) => Stream.value(const []))]));
    await t.pump();
    await t.tap(find.text('Slide'));
    await t.pump();
    expect(find.text('Importa PDF'), findsOneWidget);
  });

  group('con database', () {
    late AuriDb db;
    late Repository repo;
    late int docOhm;
    late int docVuoto;

    setUp(() async {
      db = AuriDb(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
      repo = Repository(db);
      final corso = await repo.salvaCorso(CorsiCompanion.insert(nome: 'Fisica II', cfu: 9, valutazione: Valutazione.voto));
      docOhm = await repo.salvaDocumento(
        DocumentiCompanion.insert(corsoId: corso, titolo: 'Elettricità', nomeFile: 'a.pdf', numeroPagine: 3, importatoIl: DateTime(2026, 10, 13)),
        [for (var i = 0; i < 3; i++) (numero: i + 1, titolo: titoloPagina(testiOhm[i]), testo: testiOhm[i])],
      );
      docVuoto = await repo.salvaDocumento(
        DocumentiCompanion.insert(corsoId: corso, titolo: 'Scansione', nomeFile: 'b.pdf', numeroPagine: 2, importatoIl: DateTime(2026, 10, 13)),
        [(numero: 1, titolo: '', testo: ''), (numero: 2, titolo: '', testo: '')],
      );
    });
    tearDown(() => db.close());

    Widget pagina(Widget w) => conDati(
      w,
      altri: [
        repositoryProvider.overrideWithValue(repo),
        documentiProvider.overrideWith((ref) => repo.guardaDocumenti()),
        visualizzatorePdfProvider.overrideWithValue((percorso, pagina, documento, _) => Text('PDF pagina $pagina')),
        cartellaSlideProvider.overrideWithValue(() async => Directory.systemTemp),
      ],
    );

    testWidgets('elenco raggruppato per corso', (t) async {
      await schermoIpad(t);
      await t.pumpWidget(pagina(const SlidePage()));
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await t.pump();
      expect(find.text('FISICA II'), findsOneWidget);
      expect(find.text('Elettricità'), findsOneWidget);
      expect(find.text('3 pagine'), findsOneWidget);
    });

    testWidgets('ricerca: risultati con pagina ed estratto', (t) async {
      await schermoIpad(t);
      await t.pumpWidget(pagina(const SlidePage()));
      await t.runAsync(() async {
        await t.enterText(find.byType(TextField), 'resistenze');
        await Future<void>.delayed(const Duration(milliseconds: 400));
      });
      await t.pump();
      expect(find.textContaining('Elettricità · pag. 1'), findsOneWidget);
      expect(find.textContaining('Elettricità · pag. 2'), findsOneWidget);
      // Aprendo un risultato la tastiera si chiude (al ritorno non deve coprire lo schermo).
      final campo = find.byType(EditableText, skipOffstage: false);
      expect(t.widget<EditableText>(campo).focusNode.hasFocus, isTrue);
      await t.tap(find.textContaining('Elettricità · pag. 1'));
      await t.pump();
      expect(t.widget<EditableText>(campo).focusNode.hasFocus, isFalse);
    });

    testWidgets('documento: indice, glossario, definizioni', (t) async {
      await schermoIpad(t);
      await t.pumpWidget(pagina(DocumentoPage(documentoId: docOhm)));
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
      await t.pump();
      expect(find.text('Legge di Ohm'), findsOneWidget);
      expect(find.text('Potenza elettrica'), findsOneWidget);
      await t.tap(find.text('Potenza elettrica'));
      await t.pump();
      expect(find.text('PDF pagina 3'), findsOneWidget);
      await t.tap(find.text('Glossario'));
      await t.pumpAndSettle();
      expect(find.text('tensione'), findsOneWidget);
      await t.tap(find.text('Definizioni'));
      await t.pumpAndSettle();
      expect(find.text('Si definisce resistenza R = V / I.'), findsOneWidget);
    });

    testWidgets('documento: scheda Riassunto e pulsante Scheda PDF', (t) async {
      await schermoIpad(t);
      await t.pumpWidget(pagina(DocumentoPage(documentoId: docOhm)));
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
      await t.pump();
      expect(find.text('Scheda PDF'), findsOneWidget);
      await t.tap(find.text('Riassunto'));
      await t.pumpAndSettle();
      expect(find.textContaining('tensione e corrente'), findsWidgets);
    });

    testWidgets('PDF scansionato: "Leggi il testo dalle immagini" lo rende leggibile', (t) async {
      await schermoIpad(t);
      await t.pumpWidget(
        conDati(
          DocumentoPage(documentoId: docVuoto),
          altri: [
            repositoryProvider.overrideWithValue(repo),
            documentiProvider.overrideWith((ref) => repo.guardaDocumenti()),
            visualizzatorePdfProvider.overrideWithValue((percorso, pagina, documento, _) => Text('PDF pagina $pagina')),
            cartellaSlideProvider.overrideWithValue(() async => Directory.systemTemp),
            letturaScansioniProvider.overrideWithValue(LetturaScansioni(repo, _OcrFinto(), (percorso, numero) async => Uint8List.fromList([numero]))),
          ],
        ),
      );
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
      await t.pump();
      await t.runAsync(() async {
        await t.tap(find.text('Leggi il testo dalle immagini'));
        await Future<void>.delayed(const Duration(milliseconds: 400));
      });
      for (var i = 0; i < 5; i++) {
        await t.pump();
        await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
      }
      await t.pump();
      expect(find.text('Circuiti RC'), findsOneWidget);
      expect(find.textContaining('contiene solo immagini'), findsNothing);
    });

    testWidgets('PDF con alcune pagine scansionate: si può leggere il testo di quelle', (t) async {
      await schermoIpad(t);
      final misto = (await t.runAsync(
        () => repo.salvaDocumento(
          DocumentiCompanion.insert(corsoId: 1, titolo: 'Misto', nomeFile: 'c.pdf', numeroPagine: 2, importatoIl: DateTime(2026, 10, 13)),
          [(numero: 1, titolo: titoloPagina(testiOhm[0]), testo: testiOhm[0]), (numero: 2, titolo: '', testo: '')],
        ),
      ))!;
      await t.pumpWidget(pagina(DocumentoPage(documentoId: misto)));
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
      await t.pump();
      expect(find.text('1 pagina è solo immagini: la ricerca non le trova.'), findsOneWidget);
      expect(find.text('Leggi il testo dalle immagini'), findsOneWidget);
    });

    testWidgets('PDF fatto solo di immagini: avviso', (t) async {
      await schermoIpad(t);
      await t.pumpWidget(pagina(DocumentoPage(documentoId: docVuoto)));
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
      await t.pump();
      expect(find.textContaining('contiene solo immagini'), findsOneWidget);
    });
  });
}

class _OcrFinto implements Ocr {
  @override
  Future<String> leggi(Uint8List png) async => png.first == 1 ? 'Circuiti RC\nIl condensatore si carica.' : '';
}
