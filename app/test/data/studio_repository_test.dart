import 'package:auri/data/database.dart';
import 'package:auri/data/repository.dart';
import 'package:auri/domain/modelli.dart';
import 'package:auri/domain/ripasso.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AuriDb db;
  late Repository repo;
  late int corso;
  late int doc;

  setUp(() async {
    db = AuriDb(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    repo = Repository(db);
    corso = await repo.salvaCorso(CorsiCompanion.insert(nome: 'Fisica II', cfu: 9, valutazione: Valutazione.voto));
    doc = await repo.salvaDocumento(
      DocumentiCompanion.insert(corsoId: corso, titolo: 'A', nomeFile: 'a.pdf', numeroPagine: 3, importatoIl: DateTime(2026, 10, 13)),
      [(numero: 1, titolo: 'T', testo: 'a'), (numero: 2, titolo: 'T', testo: 'b'), (numero: 3, titolo: 'T', testo: 'c')],
    );
  });
  tearDown(() => db.close());

  test('sessioni di studio salvate e lette', () async {
    await repo.salvaSessione(corsoId: corso, inizio: DateTime(2026, 10, 13, 9), minuti: 25);
    final s = await repo.guardaSessioni().first;
    expect(s.single.minuti, 25);
    expect(s.single.corsoId, corso);
  });

  test('pagine studiate: segna, togli, conta per corso', () async {
    await repo.segnaStudiata(doc, 1, true, DateTime(2026, 10, 13));
    await repo.segnaStudiata(doc, 2, true, DateTime(2026, 10, 13));
    await repo.segnaStudiata(doc, 2, true, DateTime(2026, 10, 14)); // doppia: conta una volta
    await repo.segnaStudiata(doc, 1, false, DateTime(2026, 10, 14));
    final p = await repo.guardaPagineStudiate().first;
    expect(p.map((x) => x.pagina), [2]);
  });

  test('pagine totali per corso', () async {
    expect(await repo.pagineTotaliPerCorso(), {corso: 3});
  });

  test('revisioni con la carta', () async {
    await repo.salvaCarta(CarteCompanion.insert(corsoId: corso, fronte: 'f', retro: 'r', origine: OrigineCarta.manuale));
    final c = (await repo.guardaCarte(corso).first).single;
    await repo.rispondi(c, Risposta.nonLaSapevo, DateTime(2026, 10, 13));
    final r = await repo.guardaRevisioni().first;
    expect(r.single.cartaId, c.id);
    expect(r.single.risposta, Risposta.nonLaSapevo);
  });

  test('eliminare il documento toglie le sue pagine studiate', () async {
    await repo.segnaStudiata(doc, 1, true, DateTime(2026, 10, 13));
    await repo.eliminaDocumento(doc);
    expect(await repo.guardaPagineStudiate().first, isEmpty);
  });
}
