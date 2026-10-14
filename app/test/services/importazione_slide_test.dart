@Tags(['pdfium'])
library;

import 'dart:io';

import 'package:auri/data/database.dart';
import 'package:auri/data/repository.dart';
import 'package:auri/domain/modelli.dart';
import 'package:auri/services/importazione_slide.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late AuriDb db;
  late Repository repo;
  late Directory cartella;
  late ImportazioneSlide imp;
  late int corsoId;

  setUp(() async {
    db = AuriDb(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    repo = Repository(db);
    cartella = await Directory.systemTemp.createTemp('auri_slide');
    imp = ImportazioneSlide(repo, () async => cartella);
    corsoId = await repo.salvaCorso(CorsiCompanion.insert(nome: 'Fisica II', cfu: 9, valutazione: Valutazione.voto));
  });
  tearDown(() async {
    await db.close();
    await cartella.delete(recursive: true);
  });

  test('eliminare il corso cancella anche i file PDF dei suoi documenti', () async {
    final id = await imp.importa(File('test/fixtures/ohm.pdf'), corsoId: corsoId);
    final file = File(p.join(cartella.path, (await repo.documento(id))!.nomeFile));
    expect(file.existsSync(), isTrue);
    await imp.eliminaCorso(corsoId);
    expect(file.existsSync(), isFalse);
    expect(await repo.documento(id), isNull);
  });

  test('importa il PDF: pagine, titoli, file copiato, avanzamento', () async {
    final avanzamenti = <String>[];
    final id = await imp.importa(File('test/fixtures/ohm.pdf'), corsoId: corsoId, avanzamento: (f, t) => avanzamenti.add('$f/$t'));
    final doc = (await repo.documento(id))!;
    expect(doc.titolo, 'ohm');
    expect(doc.numeroPagine, 3);
    final pagine = await repo.pagineDi(id);
    expect(pagine.map((x) => x.titolo), ['Legge di Ohm', 'Legge di Ohm', 'Potenza elettrica']);
    expect(pagine.first.testo, contains('Si definisce resistenza'));
    expect(File(p.join(cartella.path, doc.nomeFile)).existsSync(), isTrue);
    expect(avanzamenti, ['1/3', '2/3', '3/3']);
    expect((await repo.cerca('resistenze')).length, 2);
  });

  test('titolo scelto dall\'utente', () async {
    final id = await imp.importa(File('test/fixtures/ohm.pdf'), corsoId: corsoId, titolo: 'Lezione 3');
    expect((await repo.documento(id))!.titolo, 'Lezione 3');
  });

  test('file che non è un PDF: errore, niente salvato, niente copiato', () async {
    final finto = File(p.join(cartella.path, 'foto.pdf'))..writeAsStringSync('non sono un pdf');
    await expectLater(imp.importa(finto, corsoId: corsoId), throwsA(isA<PdfNonLeggibile>()));
    expect(await db.select(db.documenti).get(), isEmpty);
    expect(cartella.listSync().map((e) => p.basename(e.path)), ['foto.pdf']);
  });

  test('eliminare il documento toglie anche il file', () async {
    final id = await imp.importa(File('test/fixtures/ohm.pdf'), corsoId: corsoId);
    final file = File(p.join(cartella.path, (await repo.documento(id))!.nomeFile));
    await imp.elimina(id);
    expect(file.existsSync(), isFalse);
    expect(await repo.documento(id), isNull);
  });
}
