import 'package:auri/data/database.dart';
import 'package:auri/data/repository.dart';
import 'package:auri/domain/modelli.dart';
import 'package:auri/domain/ripasso.dart';
import 'package:auri/domain/slide.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

const testiOhm = [
  'Legge di Ohm\nLa resistenza elettrica e’ il rapporto tra tensione e corrente.\nSi definisce resistenza R = V / I.',
  'Legge di Ohm\nEsempi di circuiti in serie e in parallelo.\nLe resistenze in serie si sommano.',
  'Potenza elettrica\nLa potenza e’ il prodotto di tensione e corrente.\nDefinizione: P = V * I.',
];

void main() {
  late AuriDb db;
  late Repository repo;
  late int corso;
  late int doc;
  final ora = DateTime(2026, 10, 13, 10);

  setUp(() async {
    db = AuriDb(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    repo = Repository(db);
    corso = await repo.salvaCorso(CorsiCompanion.insert(nome: 'Fisica II', cfu: 9, valutazione: Valutazione.voto));
    doc = await repo.salvaDocumento(DocumentiCompanion.insert(corsoId: corso, titolo: 'Elettricità', nomeFile: 'a.pdf', numeroPagine: 3, importatoIl: ora), [
      for (var i = 0; i < 3; i++) (numero: i + 1, titolo: titoloPagina(testiOhm[i]), testo: testiOhm[i]),
    ]);
  });
  tearDown(() => db.close());

  test('genera le carte da un documento, senza doppioni alla seconda volta', () async {
    final n = await repo.generaCarte(doc);
    expect(n, greaterThan(2));
    expect(await repo.generaCarte(doc), 0);
    final carte = await repo.guardaCarte(corso).first;
    expect(carte.length, n);
    expect(carte.every((c) => c.documentoId == doc && c.prossima == null), isTrue);
  });

  test('carta scritta a mano', () async {
    await repo.salvaCarta(CarteCompanion.insert(corsoId: corso, fronte: 'Unità di misura della resistenza?', retro: 'ohm', origine: OrigineCarta.manuale));
    expect((await repo.guardaCarte(corso).first).single.origine, OrigineCarta.manuale);
  });

  test('rispondere aggiorna lo stato SM-2 e registra la revisione', () async {
    await repo.generaCarte(doc);
    final c = (await repo.guardaCarte(corso).first).first;
    await repo.rispondi(c, Risposta.giusta, ora);
    final dopo = (await repo.guardaCarte(corso).first).firstWhere((x) => x.id == c.id);
    expect(dopo.ripetizioni, 1);
    expect(dopo.prossima, DateTime(2026, 10, 14));
    final rev = await db.select(db.revisioni).get();
    expect(rev.single.risposta, Risposta.giusta);
    expect(rev.single.cartaId, c.id);
  });

  test('carta non saputa e poi giusta nella stessa sessione: SM-2 parte dallo stato salvato, non dalla copia vecchia', () async {
    final id = await repo.salvaCarta(CarteCompanion.insert(corsoId: corso, fronte: 'R?', retro: 'V/I', origine: OrigineCarta.manuale));
    await (db.update(db.carte)..where((t) => t.id.equals(id))).write(const CarteCompanion(ripetizioni: Value(3), intervallo: Value(15), facilita: Value(2.5)));
    final copia = (await repo.guardaCarte(corso).first).single;
    await repo.rispondi(copia, Risposta.nonLaSapevo, ora);
    await repo.rispondi(copia, Risposta.giusta, ora);
    final c = (await repo.guardaCarte(corso).first).single;
    expect(c.ripetizioni, 1);
    expect(c.intervallo, 1);
    expect(c.facilita, lessThan(2.5));
  });

  test('ultimo ripasso di ogni carta', () async {
    final a = await repo.salvaCarta(CarteCompanion.insert(corsoId: corso, fronte: 'A', retro: 'a', origine: OrigineCarta.manuale));
    await repo.salvaCarta(CarteCompanion.insert(corsoId: corso, fronte: 'B', retro: 'b', origine: OrigineCarta.manuale));
    final carta = (await repo.guardaCarte(corso).first).firstWhere((c) => c.id == a);
    await repo.rispondi(carta, Risposta.nonLaSapevo, DateTime(2026, 10, 10, 9));
    await repo.rispondi(carta, Risposta.giusta, DateTime(2026, 10, 12, 9));
    expect(await repo.ultimiRipassi(), {a: DateTime(2026, 10, 12, 9)});
  });

  test('carta esclusa: non compare più', () async {
    await repo.generaCarte(doc);
    final c = (await repo.guardaCarte(corso).first).first;
    await repo.escludiCarta(c.id);
    expect((await repo.guardaCarte(corso).first).any((x) => x.id == c.id), isFalse);
  });

  test('eliminare il documento lascia le carte (senza documento); eliminare il corso le toglie', () async {
    await repo.generaCarte(doc);
    await repo.eliminaDocumento(doc);
    final rimaste = await repo.guardaCarte(corso).first;
    expect(rimaste, isNotEmpty);
    expect(rimaste.every((c) => c.documentoId == null), isTrue);
    await repo.eliminaCorso(corso);
    expect(await db.select(db.carte).get(), isEmpty);
  });

  test('tutte le carte di tutti i corsi', () async {
    await repo.generaCarte(doc);
    expect((await repo.guardaCarte(null).first).length, (await repo.guardaCarte(corso).first).length);
  });
}
