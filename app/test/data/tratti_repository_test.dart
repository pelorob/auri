import 'package:auri/data/database.dart';
import 'package:auri/data/repository.dart';
import 'package:auri/domain/modelli.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AuriDb db;
  late Repository repo;
  late int doc;

  setUp(() async {
    db = AuriDb(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    repo = Repository(db);
    final corso = await repo.salvaCorso(CorsiCompanion.insert(nome: 'Fisica II', cfu: 9, valutazione: Valutazione.voto));
    doc = await repo.salvaDocumento(
      DocumentiCompanion.insert(corsoId: corso, titolo: 'Scansione', nomeFile: 's.pdf', numeroPagine: 2, importatoIl: DateTime(2026, 10, 14)),
      [(numero: 1, titolo: '', testo: ''), (numero: 2, titolo: '', testo: '')],
    );
  });
  tearDown(() => db.close());

  test('tratti: salva, leggi per pagina, elimina', () async {
    final id = await repo.salvaTratto(documentoId: doc, pagina: 1, colore: 0xFF5B3DE6, spessore: 2, evidenziatore: false, punti: '0.1,0.1;0.2,0.2');
    await repo.salvaTratto(documentoId: doc, pagina: 2, colore: 0xFFD6F35B, spessore: 12, evidenziatore: true, punti: '0.3,0.3;0.4,0.4');
    final tutti = await repo.guardaTratti(doc).first;
    expect(tutti.length, 2);
    expect(tutti.where((x) => x.pagina == 1).single.punti, '0.1,0.1;0.2,0.2');
    await repo.eliminaTratto(id);
    expect((await repo.guardaTratti(doc).first).single.pagina, 2);
  });

  test('eliminare il documento toglie i tratti', () async {
    await repo.salvaTratto(documentoId: doc, pagina: 1, colore: 0, spessore: 2, evidenziatore: false, punti: '0,0');
    await repo.eliminaDocumento(doc);
    expect(await db.select(db.tratti).get(), isEmpty);
  });

  test('testo letto con l\'OCR: aggiorna pagina, titolo e ricerca', () async {
    expect(await repo.cerca('condensatore'), isEmpty);
    await repo.aggiornaTestoPagina(doc, 1, 'Circuiti RC\nIl condensatore si carica.');
    final p = (await repo.pagineDi(doc)).first;
    expect(p.titolo, 'Circuiti RC');
    expect((await repo.cerca('condensatore')).single.pagina, 1);
  });
}
