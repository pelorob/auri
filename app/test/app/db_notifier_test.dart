import 'dart:io';

import 'package:auri/app/providers.dart';
import 'package:auri/data/database.dart';
import 'package:auri/domain/modelli.dart';
import 'package:auri/services/backup.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tmp;
  late File dest;
  late ProviderContainer c;

  Future<void> scriviCorso(File f, String nome) async {
    final db = AuriDb(NativeDatabase(f));
    await db.into(db.corsi).insert(CorsiCompanion.insert(nome: nome, cfu: 6, valutazione: Valutazione.voto));
    await db.close();
  }

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('auri_db');
    dest = File(p.join(tmp.path, 'auri.sqlite'));
    await scriviCorso(dest, 'Vecchio');
    c = ProviderContainer(overrides: [aperturaDbProvider.overrideWithValue((apri: () async => AuriDb(NativeDatabase(dest)), file: () async => dest))]);
  });
  tearDown(() async {
    await c.read(dbProvider).value?.close();
    c.dispose();
    await tmp.delete(recursive: true);
  });

  Future<List<String>> nomi() async {
    final db = await c.read(dbProvider.future);
    return [for (final r in await db.select(db.corsi).get()) r.nome];
  }

  test('ripristino valido: riapre il database con i dati del backup', () async {
    expect(await nomi(), ['Vecchio']);
    final backup = File(p.join(tmp.path, 'b.auri'));
    await scriviCorso(backup, 'Nuovo');
    await c.read(dbProvider.notifier).ripristina(backup);
    expect(await nomi(), ['Nuovo']);
  });

  test('ripristino non valido: errore e database attuale ancora usabile', () async {
    expect(await nomi(), ['Vecchio']);
    final brutto = File(p.join(tmp.path, 'foto.auri'))..writeAsStringSync('ciao');
    await expectLater(c.read(dbProvider.notifier).ripristina(brutto), throwsA(isA<BackupNonValido>()));
    expect(await nomi(), ['Vecchio']);
  });
}
