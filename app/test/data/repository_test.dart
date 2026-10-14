import 'package:auri/data/database.dart';
import 'package:auri/data/repository.dart';
import 'package:auri/domain/modelli.dart';
import 'package:auri/domain/preferenze.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AuriDb db;
  late Repository repo;

  setUp(() {
    db = AuriDb(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    repo = Repository(db);
  });
  tearDown(() => db.close());

  Future<int> analisi() => repo.salvaCorso(CorsiCompanion.insert(nome: 'Analisi Matematica I', cfu: 12, valutazione: Valutazione.voto));

  test('corso senza esito è da sostenere, con esito è superato', () async {
    final id = await analisi();
    expect((await repo.guardaCorsi().first).single.superato, isFalse);
    await repo.registraEsito(EsitiCompanion.insert(corsoId: Value(id), voto: const Value(28), data: DateTime(2026, 10, 27)));
    final c = (await repo.guardaCorsi().first).single;
    expect(c.superato, isTrue);
    expect(c.esito!.voto, 28);
  });

  test('un solo esito per corso: il secondo sostituisce il primo', () async {
    final id = await analisi();
    await repo.registraEsito(EsitiCompanion.insert(corsoId: Value(id), voto: const Value(24), data: DateTime(2026, 10, 27)));
    await repo.registraEsito(EsitiCompanion.insert(corsoId: Value(id), voto: const Value(30), lode: const Value(true), data: DateTime(2026, 10, 28)));
    final esiti = await db.select(db.esiti).get();
    expect(esiti.length, 1);
    expect(esiti.single.voto, 30);
    expect(esiti.single.lode, isTrue);
  });

  test('eliminare un corso elimina appelli ed esito', () async {
    final id = await analisi();
    await repo.salvaAppello(AppelliCompanion.insert(corsoId: id, dataOra: DateTime(2026, 10, 27, 9), tipo: TipoAppello.scritto));
    await repo.registraEsito(EsitiCompanion.insert(corsoId: Value(id), voto: const Value(27), data: DateTime(2026, 10, 27)));
    await repo.eliminaCorso(id);
    expect(await db.select(db.appelli).get(), isEmpty);
    expect(await db.select(db.esiti).get(), isEmpty);
  });

  test('appelli ordinati per data con il loro corso, iscrizione modificabile', () async {
    final id = await analisi();
    final tardi = await repo.salvaAppello(AppelliCompanion.insert(corsoId: id, dataOra: DateTime(2026, 10, 30, 14, 30), tipo: TipoAppello.orale));
    await repo.salvaAppello(AppelliCompanion.insert(corsoId: id, dataOra: DateTime(2026, 10, 27, 9), tipo: TipoAppello.scritto, aula: const Value('Aula B2')));
    await repo.impostaIscritta(tardi, true);
    final a = await repo.guardaAppelli().first;
    expect(a.map((x) => x.appello.tipo), [TipoAppello.scritto, TipoAppello.orale]);
    expect(a.first.corso.nome, 'Analisi Matematica I');
    expect(a.last.appello.iscritta, isTrue);
    expect(a.first.appello.preavvisi, '7@9:00,1@9:00,0@7:30');
  });

  test('preferenze: predefinite, poi salvate', () async {
    expect((await repo.guardaPreferenze().first).cfuTotali, 180);
    await repo.salvaPreferenza(Preferenze.kCfuTotali, '120');
    await repo.salvaPreferenza(Preferenze.kCfuTotali, '150');
    expect((await repo.guardaPreferenze().first).cfuTotali, 150);
  });
}
