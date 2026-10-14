import 'dart:math';

import 'package:auri/domain/quiz.dart';
import 'package:flutter_test/flutter_test.dart';

const pdfOhm = {
  1: 'Legge di Ohm\nLa resistenza elettrica e’ il rapporto tra tensione e corrente.\nSi definisce resistenza R = V / I.',
  2: 'Legge di Ohm\nLa corrente elettrica scorre nei circuiti in serie.\nLe resistenze in serie si sommano.',
  3: 'Potenza elettrica\nLa potenza e’ il prodotto di tensione e corrente.\nDefinizione: P = V * I.',
  4: 'Circuiti\nIl condensatore è un componente che accumula carica nei circuiti.\nLa tensione ai capi del condensatore cresce.',
};

final materiale = [const MaterialeDocumento(documentoId: 7, testoPerPagina: pdfOhm)];

void main() {
  test('genera domande dei tre tipi, con opzioni valide', () {
    final q = generaQuiz(materiale, quante: 30, caso: Random(1));
    expect(q, isNotEmpty);
    expect(q.map((d) => d.tipo).toSet(), containsAll(TipoDomanda.values));
    for (final d in q) {
      expect(d.giusta, inInclusiveRange(0, d.opzioni.length - 1));
      expect(d.opzioni.toSet().length, d.opzioni.length, reason: 'opzioni doppie in "${d.testo}"');
      expect(d.documentoId, 7);
      expect(d.pagina, isNotNull);
      if (d.tipo == TipoDomanda.veroFalso) {
        expect(d.opzioni, ['Vero', 'Falso']);
      } else {
        expect(d.opzioni.length, 4);
        expect(d.testo, contains('____'));
      }
    }
  });

  test('nella scelta multipla la risposta giusta completa davvero la frase', () {
    final q = generaQuiz(materiale, quante: 30, caso: Random(2)).where((d) => d.tipo != TipoDomanda.veroFalso);
    for (final d in q) {
      final frase = d.testo.substring(d.testo.indexOf('«') + 1, d.testo.lastIndexOf('»'));
      final completa = frase.replaceFirst('____', d.opzioni[d.giusta]).toLowerCase();
      final originale = pdfOhm[d.pagina]!.toLowerCase();
      expect(originale.contains(completa), isTrue, reason: completa);
    }
  });

  test('vero/falso: le frasi "vere" sono nel testo, le "false" no', () {
    final q = generaQuiz(materiale, quante: 30, caso: Random(3)).where((d) => d.tipo == TipoDomanda.veroFalso).toList();
    expect(q, isNotEmpty);
    for (final d in q) {
      final frase = d.testo.substring(d.testo.indexOf('«') + 1, d.testo.lastIndexOf('»')).toLowerCase();
      final nelTesto = pdfOhm[d.pagina]!.toLowerCase().contains(frase);
      expect(nelTesto, d.giusta == 0, reason: frase);
    }
  });

  test('frase esclusa: non torna più, in nessun tipo di domanda', () {
    final tutte = generaQuiz(materiale, quante: 30, caso: Random(1));
    final esclusa = tutte.first.frase;
    expect(esclusa, contains('____'));
    final dopo = generaQuiz(materiale, quante: 30, caso: Random(1), escluse: {(7, esclusa)});
    expect(dopo.where((d) => d.frase == esclusa), isEmpty);
    expect(dopo, isNotEmpty);
    // La stessa frase in un altro documento resta valida.
    expect(generaQuiz(materiale, quante: 30, caso: Random(1), escluse: {(8, esclusa)}).where((d) => d.frase == esclusa), isNotEmpty);
  });

  test('stesso seme, stesse domande; numero rispettato', () {
    final a = generaQuiz(materiale, quante: 5, caso: Random(9));
    final b = generaQuiz(materiale, quante: 5, caso: Random(9));
    expect(a.length, 5);
    expect(a.map((d) => d.testo), b.map((d) => d.testo));
  });

  test('materiale insufficiente (meno di 4 termini): eccezione chiara', () {
    expect(
      () => generaQuiz(
        [
          const MaterialeDocumento(documentoId: 1, testoPerPagina: {1: 'Titolo\nPoco testo.'}),
        ],
        quante: 10,
        caso: Random(1),
      ),
      throwsA(isA<MaterialeInsufficiente>()),
    );
  });

  test('voto in trentesimi', () {
    expect(votoSimulazione(10, 10), 30);
    expect(votoSimulazione(6, 10), 18);
    expect(votoSimulazione(5, 10), 15);
    expect(votoSimulazione(0, 0), 0);
    expect(superata(18), isTrue);
    expect(superata(17), isFalse);
  });
}
