import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import '../data/database.dart';
import '../domain/avvisi.dart';

class BackupNonValido implements Exception {
  const BackupNonValido(this.motivo);
  final String motivo;
  @override
  String toString() => motivo;
}

Future<File> creaCopiaBackup(AuriDb db, Directory cartella, DateTime ora) async {
  final f = File(p.join(cartella.path, nomeFileBackup(ora)));
  if (f.existsSync()) f.deleteSync();
  await db.customStatement('VACUUM INTO ?', [f.path]);
  return f;
}

/// Controlla, in sola lettura, che il file sia un backup integro di auri.
void verificaBackup(File f) {
  Database? d;
  try {
    d = sqlite3.open(f.path, mode: OpenMode.readOnly);
    final integro = d.select('PRAGMA integrity_check').first.values.first;
    if (integro != 'ok') throw const BackupNonValido('Il file di backup è danneggiato.');
    final versione = d.select('PRAGMA user_version').first.values.first as int;
    final tabelle = d.select("SELECT name FROM sqlite_master WHERE type='table'").map((r) => r['name']).toSet();
    if (versione > kVersioneSchema) throw const BackupNonValido('Questo backup viene da una versione più recente di auri.');
    if (versione < 1 || !tabelle.containsAll(['corsi', 'esiti', 'appelli', 'impostazioni'])) {
      throw const BackupNonValido('Questo file non è un backup di auri.');
    }
  } on BackupNonValido {
    rethrow;
  } catch (_) {
    throw const BackupNonValido('Questo file non è un backup di auri.');
  } finally {
    d?.close();
  }
}

/// Va chiamata con il database dell'app CHIUSO.
Future<void> sostituisciDatabase({required File backup, required File destinazione}) async {
  verificaBackup(backup);
  // Copia accanto, verifica, poi rinomina: se qualcosa va storto l'originale resta intatto.
  final temporaneo = File('${destinazione.path}.tmp');
  try {
    await backup.copy(temporaneo.path);
    verificaBackup(temporaneo);
  } catch (_) {
    if (temporaneo.existsSync()) temporaneo.deleteSync();
    rethrow;
  }
  for (final suffisso in ['-wal', '-shm', '-journal']) {
    final extra = File('${destinazione.path}$suffisso');
    if (extra.existsSync()) extra.deleteSync();
  }
  await temporaneo.rename(destinazione.path);
}
