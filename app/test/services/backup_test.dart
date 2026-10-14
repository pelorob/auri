import 'dart:io';

import 'package:auri/data/database.dart';
import 'package:auri/domain/modelli.dart';
import 'package:auri/services/backup.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

void main() {
  late Directory tmp;
  setUp(() async => tmp = await Directory.systemTemp.createTemp('auri_test'));
  tearDown(() async => tmp.delete(recursive: true));

  Future<File> dbConUnCorso(String nome) async {
    final f = File(p.join(tmp.path, nome));
    final db = AuriDb(NativeDatabase(f));
    await db.into(db.corsi).insert(CorsiCompanion.insert(nome: 'Analisi', cfu: 12, valutazione: Valutazione.voto));
    await db.close();
    return f;
  }

  test('crea una copia valida con i dati', () async {
    final f = await dbConUnCorso('auri.sqlite');
    final db = AuriDb(NativeDatabase(f));
    final copia = await creaCopiaBackup(db, tmp, DateTime(2026, 10, 13));
    await db.close();
    expect(p.basename(copia.path), 'auri-backup-2026-10-13.auri');
    verificaBackup(copia);
    final letto = AuriDb(NativeDatabase(copia));
    expect((await letto.select(letto.corsi).get()).single.nome, 'Analisi');
    await letto.close();
  });

  test('rifiuta un file che non è un database', () async {
    final f = File(p.join(tmp.path, 'foto.auri'))..writeAsBytesSync(List.filled(4096, 7));
    expect(() => verificaBackup(f), throwsA(isA<BackupNonValido>()));
  });

  test('rifiuta un database SQLite che non è di auri', () async {
    final f = File(p.join(tmp.path, 'altro.auri'));
    sqlite3.open(f.path)
      ..execute('CREATE TABLE x (a INTEGER)')
      ..close();
    expect(() => verificaBackup(f), throwsA(isA<BackupNonValido>()));
  });

  test('con un backup non valido la destinazione resta intatta', () async {
    final dest = await dbConUnCorso('auri.sqlite');
    final prima = dest.readAsBytesSync();
    final brutto = File(p.join(tmp.path, 'brutto.auri'))..writeAsStringSync('ciao');
    await expectLater(sostituisciDatabase(backup: brutto, destinazione: dest), throwsA(isA<BackupNonValido>()));
    expect(dest.readAsBytesSync(), prima);
  });

  test('se la copia fallisce la destinazione resta intatta', () async {
    final dest = await dbConUnCorso('auri.sqlite');
    final prima = dest.readAsBytesSync();
    Directory('${dest.path}.tmp').createSync(); // la copia temporanea non può essere scritta
    final buono = await dbConUnCorso('buono.sqlite');
    await expectLater(sostituisciDatabase(backup: buono, destinazione: dest), throwsA(isA<FileSystemException>()));
    expect(dest.readAsBytesSync(), prima);
  });

  test('con un backup valido la destinazione viene sostituita', () async {
    final dest = File(p.join(tmp.path, 'vuoto.sqlite'));
    final db = AuriDb(NativeDatabase(dest));
    await db.select(db.corsi).get();
    await db.close();
    final buono = await dbConUnCorso('buono.sqlite');
    await sostituisciDatabase(backup: buono, destinazione: dest);
    final letto = AuriDb(NativeDatabase(dest));
    expect((await letto.select(letto.corsi).get()).length, 1);
    await letto.close();
  });
}
