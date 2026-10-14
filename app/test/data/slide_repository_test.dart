import 'dart:io';

import 'package:auri/data/database.dart';
import 'package:auri/data/repository.dart';
import 'package:auri/domain/modelli.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

void main() {
  late AuriDb db;
  late Repository repo;
  late int corsoId;

  setUp(() async {
    db = AuriDb(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    repo = Repository(db);
    corsoId = await repo.salvaCorso(CorsiCompanion.insert(nome: 'Fisica II', cfu: 9, valutazione: Valutazione.voto));
  });
  tearDown(() => db.close());

  Future<int> ohm() => repo.salvaDocumento(
    DocumentiCompanion.insert(corsoId: corsoId, titolo: 'Elettricità', nomeFile: '1.pdf', numeroPagine: 3, importatoIl: DateTime(2026, 10, 13)),
    [
      (numero: 1, titolo: 'Legge di Ohm', testo: 'Legge di Ohm\nLa resistenza elettrica è il rapporto tra tensione e corrente.'),
      (numero: 2, titolo: 'Legge di Ohm', testo: 'Legge di Ohm\nLe resistenze in serie si sommano.'),
      (numero: 3, titolo: 'Potenza elettrica', testo: 'Potenza elettrica\nDefinizione: P = V * I.'),
    ],
  );

  test('cerca per radice: "resistenze" trova le pagine 1 e 2, con estratto evidenziato', () async {
    await ohm();
    final r = await repo.cerca('resistenze');
    expect(r.map((x) => x.pagina).toList()..sort(), [1, 2]);
    expect(r.first.documento.titolo, 'Elettricità');
    expect(r.first.corso.nome, 'Fisica II');
    expect(r.every((x) => x.estratto.contains('[')), isTrue);
  });

  test('più parole: tutte devono comparire', () async {
    await ohm();
    expect((await repo.cerca('potenza elettrica')).map((x) => x.pagina), [3]);
    expect(await repo.cerca('potenza serie'), isEmpty);
  });

  test('query vuota o con soli simboli: nessun risultato, nessun errore', () async {
    await ohm();
    expect(await repo.cerca(''), isEmpty);
    expect(await repo.cerca('"*-()'), isEmpty);
  });

  test('testo letto con l\'OCR: titolo dal testo solo se la pagina non ne aveva', () async {
    final id = await repo.salvaDocumento(
      DocumentiCompanion.insert(corsoId: corsoId, titolo: 'Scansione', nomeFile: '2.pdf', numeroPagine: 2, importatoIl: DateTime(2026, 10, 13)),
      [(numero: 1, titolo: 'Capitolo 1 (segnalibro)', testo: ''), (numero: 2, titolo: '', testo: '')],
    );
    await repo.aggiornaTestoPagina(id, 1, 'Circuiti RC\nIl condensatore si carica.');
    await repo.aggiornaTestoPagina(id, 2, 'Induttanza\nLa bobina si oppone.');
    final pagine = await repo.pagineDi(id);
    expect(pagine.map((x) => x.titolo), ['Capitolo 1 (segnalibro)', 'Induttanza']);
    expect(pagine.first.testo, contains('condensatore'));
    expect((await repo.cerca('condensatore')).single.pagina, 1);
  });

  test('pagine del documento in ordine', () async {
    final id = await ohm();
    expect((await repo.pagineDi(id)).map((x) => x.numero), [1, 2, 3]);
  });

  test('eliminare il documento toglie anche pagine e ricerca', () async {
    final id = await ohm();
    await repo.eliminaDocumento(id);
    expect(await repo.cerca('resistenze'), isEmpty);
    expect(await db.select(db.pagine).get(), isEmpty);
  });

  test('eliminare il corso toglie documenti, pagine e ricerca', () async {
    await ohm();
    await repo.eliminaCorso(corsoId);
    expect(await db.select(db.documenti).get(), isEmpty);
    expect(await db.select(db.pagine).get(), isEmpty);
    expect(await repo.cerca('resistenze'), isEmpty);
  });

  test('elenco documenti con il loro corso', () async {
    await ohm();
    final d = await repo.guardaDocumenti().first;
    expect(d.single.documento.numeroPagine, 3);
    expect(d.single.corso.nome, 'Fisica II');
  });

  test('migrazione: un database della versione 1 si apre e guadagna le nuove tabelle', () async {
    final tmp = await Directory.systemTemp.createTemp('auri_mig');
    final f = File(p.join(tmp.path, 'v1.sqlite'));
    // Schema della versione 1 com'era nella fase 1.
    final v1 = sqlite3.open(f.path);
    v1.execute('''
      CREATE TABLE corsi (id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT NOT NULL, cfu INTEGER NOT NULL, anno INTEGER NOT NULL DEFAULT 1,
        semestre INTEGER NULL, docente TEXT NULL, colore TEXT NOT NULL DEFAULT '#5B3DE6', valutazione INTEGER NOT NULL);
      CREATE TABLE esiti (corso_id INTEGER NOT NULL REFERENCES corsi (id) ON DELETE CASCADE, voto INTEGER NULL,
        lode INTEGER NOT NULL DEFAULT 0, data INTEGER NOT NULL, PRIMARY KEY (corso_id));
      CREATE TABLE appelli (id INTEGER PRIMARY KEY AUTOINCREMENT, corso_id INTEGER NOT NULL REFERENCES corsi (id) ON DELETE CASCADE,
        data_ora INTEGER NOT NULL, tipo INTEGER NOT NULL, aula TEXT NULL, iscritta INTEGER NOT NULL DEFAULT 0,
        preavvisi TEXT NOT NULL DEFAULT '7@9:00,1@9:00,0@7:30', note TEXT NULL);
      CREATE TABLE impostazioni (chiave TEXT NOT NULL, valore TEXT NOT NULL, PRIMARY KEY (chiave));
      INSERT INTO corsi (nome, cfu, valutazione) VALUES ('Vecchio corso', 6, 0);
      PRAGMA user_version = 1;
    ''');
    v1.close();
    final aperto = AuriDb(NativeDatabase(f));
    expect((await aperto.select(aperto.corsi).get()).single.nome, 'Vecchio corso');
    expect(await aperto.select(aperto.documenti).get(), isEmpty);
    expect(await aperto.select(aperto.tratti).get(), isEmpty);
    expect(await aperto.select(aperto.domandeEscluse).get(), isEmpty);
    final r = Repository(aperto);
    expect(await r.cerca('qualcosa'), isEmpty);
    await aperto.close();
    await tmp.delete(recursive: true);
  });
}
