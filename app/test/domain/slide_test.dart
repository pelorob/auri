import 'package:auri/domain/slide.dart';
import 'package:flutter_test/flutter_test.dart';

const pdfOhm = {
  1: 'Legge di Ohm\nLa resistenza elettrica e’ il rapporto tra tensione e corrente.\nSi definisce resistenza R = V / I.',
  2: 'Legge di Ohm\nEsempi di circuiti in serie e in parallelo.\nLe resistenze in serie si sommano.',
  3: 'Potenza elettrica\nLa potenza e’ il prodotto di tensione e corrente.\nDefinizione: P = V * I.',
};

void main() {
  group('radice', () {
    test('toglie la vocale finale delle parole lunghe', () {
      expect(radice('resistenze'), 'resistenz');
      expect(radice('Elettrica'), 'elettric');
      expect(radice('ohm'), 'ohm');
      expect(radice('legge'), 'legg');
    });
    test('toglie gli accenti', () {
      expect(radice('perché'), 'perch');
      expect(radice('Proprietà'), 'propriet');
    });
  });

  group('queryRicerca', () {
    test('parole → prefissi in AND', () {
      expect(queryRicerca('legge ohm'), '"legg"* "ohm"*');
    });
    test('solo simboli → null', () {
      expect(queryRicerca('"*-'), isNull);
      expect(queryRicerca('   '), isNull);
    });
    test('apostrofi e simboli dentro le parole non rompono la query', () {
      expect(queryRicerca("l'energia"), '"l"* "energi"*');
      expect(queryRicerca('R = V / I'), '"r"* "v"* "i"*');
    });
  });

  test('titolo della pagina: prima riga non vuota, al massimo 80 caratteri', () {
    expect(titoloPagina('\n\n  Legge di Ohm  \nTesto'), 'Legge di Ohm');
    expect(titoloPagina(''), '');
    expect(titoloPagina('x' * 100).length, 80);
  });

  test('indice: unisce pagine consecutive con lo stesso titolo, salta le vuote', () {
    final i = indiceDaPagine(['Legge di Ohm', 'Legge di Ohm', '', 'Potenza elettrica', 'Legge di Ohm']);
    expect(i.map((v) => '${v.pagina}:${v.titolo}'), ['1:Legge di Ohm', '4:Potenza elettrica', '5:Legge di Ohm']);
  });

  group('glossario', () {
    final g = glossario(pdfOhm);
    final termini = g.map((t) => t.termine).toList();
    test('contiene i termini ricorrenti in più pagine', () {
      expect(termini, contains('legge di ohm'));
      expect(termini, contains('tensione'));
      expect(g.firstWhere((t) => t.termine == 'tensione').pagine, [1, 3]);
    });
    test('niente parole vuote e niente termini di una sola pagina', () {
      expect(termini.any((t) => paroleVuote.contains(t)), isFalse);
      expect(termini, isNot(contains('parallelo')));
    });
    test('rispetta il limite', () {
      expect(glossario(pdfOhm, massimo: 2).length, 2);
    });
  });

  test('definizioni', () {
    final d = definizioni(pdfOhm);
    expect(d.map((x) => '${x.pagina}:${x.testo}'), ['1:Si definisce resistenza R = V / I.', '3:Definizione: P = V * I.']);
  });

  test('definizioni con "è" e "si dice"', () {
    final d = definizioni({7: 'Il condensatore è un componente che accumula carica.\nSi dice capacità il rapporto Q/V.\nAltro testo.'});
    expect(d.length, 2);
    expect(d.first.pagina, 7);
  });
}
