import 'package:auri/app/providers.dart';
import 'package:auri/data/database.dart';
import 'package:auri/data/repository.dart';
import 'package:auri/domain/modelli.dart';
import 'package:auri/features/slide/annotazioni.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/esempio.dart';

void main() {
  late AuriDb db;
  late Repository repo;
  late int doc;

  setUp(() async {
    db = AuriDb(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    repo = Repository(db);
    final corso = await repo.salvaCorso(CorsiCompanion.insert(nome: 'Fisica II', cfu: 9, valutazione: Valutazione.voto));
    doc = await repo.salvaDocumento(
      DocumentiCompanion.insert(corsoId: corso, titolo: 'A', nomeFile: 'a.pdf', numeroPagine: 1, importatoIl: DateTime(2026, 10, 14)),
      [(numero: 1, titolo: 'T', testo: 'T')],
    );
  });
  tearDown(() => db.close());

  Widget strato(Strumento s, {bool conDito = false}) => conDati(
    Center(
      child: SizedBox(width: 400, height: 600, child: StratoAnnotazioni(documentoId: doc, pagina: 1)),
    ),
    altri: [
      repositoryProvider.overrideWithValue(repo),
      strumentoProvider.overrideWith(() => StrumentoController(StatoStrumento(strumento: s, conDito: conDito))),
    ],
  );

  Future<void> trascina(WidgetTester t, PointerDeviceKind tipo) async {
    final centro = t.getCenter(find.byType(StratoAnnotazioni));
    final g = await t.startGesture(centro, kind: tipo);
    for (var i = 1; i <= 10; i++) {
      await g.moveBy(const Offset(10, 5));
    }
    await t.runAsync(() async {
      await g.up();
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    await t.pump();
  }

  testWidgets('con la Pencil si disegna e il tratto viene salvato in coordinate 0–1', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(strato(Strumento.penna));
    await trascina(t, PointerDeviceKind.stylus);
    final tratti = (await t.runAsync(() => db.select(db.tratti).get()))!;
    expect(tratti.length, 1);
    expect(tratti.single.pagina, 1);
    expect(tratti.single.evidenziatore, isFalse);
    final xs = tratti.single.punti.split(';').map((p) => double.parse(p.split(',')[0]));
    expect(xs.every((x) => x >= 0 && x <= 1), isTrue);
  });

  testWidgets('col dito non si disegna (serve a scorrere), a meno di "Disegna col dito"', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(strato(Strumento.penna));
    await trascina(t, PointerDeviceKind.touch);
    expect((await t.runAsync(() => db.select(db.tratti).get()))!, isEmpty);

    await t.pumpWidget(const SizedBox()); // nuovo contenitore dei provider con il nuovo strumento
    await t.pumpWidget(strato(Strumento.evidenziatore, conDito: true));
    await trascina(t, PointerDeviceKind.touch);
    final tratti = (await t.runAsync(() => db.select(db.tratti).get()))!;
    expect(tratti.single.evidenziatore, isTrue);
  });

  testWidgets('gomma: toccando un tratto lo cancella', (t) async {
    await schermoIpad(t);
    await t.runAsync(() => repo.salvaTratto(documentoId: doc, pagina: 1, colore: 0xFF5B3DE6, spessore: 3, evidenziatore: false, punti: '0.1,0.5;0.9,0.5'));
    await t.pumpWidget(strato(Strumento.gomma));
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await t.pump();
    final centro = t.getCenter(find.byType(StratoAnnotazioni));
    final g = await t.startGesture(centro, kind: PointerDeviceKind.stylus);
    await g.moveBy(const Offset(2, 0));
    await t.runAsync(() async {
      await g.up();
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    expect((await t.runAsync(() => db.select(db.tratti).get()))!, isEmpty);
  });

  testWidgets('strumento "nessuno": il livello non intercetta nulla', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(strato(Strumento.nessuno));
    await trascina(t, PointerDeviceKind.stylus);
    expect((await t.runAsync(() => db.select(db.tratti).get()))!, isEmpty);
  });

  test('il contenitore dei provider espone lo strumento scelto', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(strumentoProvider.notifier).scegli(Strumento.gomma);
    expect(c.read(strumentoProvider).strumento, Strumento.gomma);
  });
}
