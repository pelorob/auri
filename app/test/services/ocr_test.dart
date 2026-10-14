import 'package:auri/data/database.dart';
import 'package:auri/data/repository.dart';
import 'package:auri/domain/modelli.dart';
import 'package:auri/services/ocr.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class OcrFinto implements Ocr {
  final lette = <int>[];
  @override
  Future<String> leggi(Uint8List immagine) async {
    lette.add(immagine.first);
    return immagine.first == 1 ? 'Circuiti RC\nIl condensatore si carica lentamente.' : '';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AuriDb db;
  late Repository repo;
  late int doc;

  setUp(() async {
    db = AuriDb(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    repo = Repository(db);
    final corso = await repo.salvaCorso(CorsiCompanion.insert(nome: 'Fisica II', cfu: 9, valutazione: Valutazione.voto));
    doc = await repo.salvaDocumento(
      DocumentiCompanion.insert(corsoId: corso, titolo: 'Scansione', nomeFile: 's.pdf', numeroPagine: 3, importatoIl: DateTime(2026, 10, 14)),
      [(numero: 1, titolo: '', testo: ''), (numero: 2, titolo: '', testo: ''), (numero: 3, titolo: 'Già', testo: 'Già\ntesto presente')],
    );
  });
  tearDown(() => db.close());

  test('legge solo le pagine senza testo e aggiorna testo, titolo e ricerca', () async {
    final ocr = OcrFinto();
    final lettura = LetturaScansioni(repo, ocr, (percorso, numero) async => Uint8List.fromList([numero]));
    final avanzamenti = <String>[];
    final trovate = await lettura.leggiDocumento(doc, 'x.pdf', avanzamento: (f, t) => avanzamenti.add('$f/$t'));
    expect(ocr.lette, [1, 2]);
    expect(trovate, 1);
    expect(avanzamenti, ['1/2', '2/2']);
    final pagine = await repo.pagineDi(doc);
    expect(pagine[0].titolo, 'Circuiti RC');
    expect(pagine[2].testo, 'Già\ntesto presente');
    expect((await repo.cerca('condensatore')).single.pagina, 1);
  });

  test('OCR di sistema non disponibile (es. sul PC): errore chiaro', () async {
    expect(() => const OcrVision().leggi(Uint8List(1)), throwsA(isA<OcrNonDisponibile>()));
  });

  test('OCR di sistema: passa l\'immagine al canale e restituisce il testo', () async {
    const canale = MethodChannel('auri/ocr');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(canale, (call) async {
      expect(call.method, 'leggi');
      return 'riga 1\nriga 2';
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(canale, null));
    expect(await const OcrVision().leggi(Uint8List.fromList([1, 2, 3])), 'riga 1\nriga 2');
  });
}
