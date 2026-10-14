import 'package:auri/data/database.dart';
import 'package:auri/data/repository.dart';
import 'package:auri/domain/modelli.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

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

  test('materiale del corso: testo per pagina di ogni documento', () async {
    final d = await repo.salvaDocumento(
      DocumentiCompanion.insert(corsoId: corso, titolo: 'A', nomeFile: 'a.pdf', numeroPagine: 2, importatoIl: DateTime(2026, 10, 13)),
      [(numero: 1, titolo: 'T1', testo: 'uno'), (numero: 2, titolo: 'T2', testo: 'due')],
    );
    final m = await repo.materialeCorso(corso);
    expect(m.single.documentoId, d);
    expect(m.single.testoPerPagina, {1: 'uno', 2: 'due'});
  });

  test('simulazioni salvate e lette in ordine di data', () async {
    await repo.salvaSimulazione(corsoId: corso, data: DateTime(2026, 10, 12), domande: 10, giuste: 6, voto: 18);
    await repo.salvaSimulazione(corsoId: corso, data: DateTime(2026, 10, 13), domande: 10, giuste: 9, voto: 27);
    final s = await repo.guardaSimulazioni(corso).first;
    expect(s.map((x) => x.voto), [18, 27]);
    await repo.eliminaCorso(corso);
    expect(await repo.guardaSimulazioni(null).first, isEmpty);
  });
}
