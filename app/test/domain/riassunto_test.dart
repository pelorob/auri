import 'package:auri/domain/riassunto.dart';
import 'package:flutter_test/flutter_test.dart';

const pagine = {
  1: 'Legge di Ohm\nLa resistenza elettrica è il rapporto tra tensione e corrente in un conduttore.\nOggi piove molto forte sulla città.',
  2: 'Circuiti\nNei circuiti in serie la corrente è la stessa in ogni resistenza elettrica.\nLa tensione totale è la somma delle tensioni sulle resistenze.',
  3: 'Potenza\nLa potenza elettrica dissipata da una resistenza dipende da tensione e corrente.\nIl gatto dorme sul divano.',
};

void main() {
  test('frasi: niente titoli, niente frasi troppo corte', () {
    final f = frasiDelDocumento(pagine);
    expect(f.map((x) => x.testo), isNot(contains('Legge di Ohm')));
    expect(f.length, 6);
    expect(f.first.pagina, 1);
  });

  test('il riassunto sceglie le frasi centrali, non quelle fuori tema', () {
    final r = riassunto(pagine, quante: 3);
    expect(r.length, 3);
    final testi = r.map((x) => x.testo).join(' ');
    expect(testi, isNot(contains('piove')));
    expect(testi, isNot(contains('gatto')));
  });

  test('ordine originale delle frasi', () {
    final r = riassunto(pagine, quante: 3);
    final pos = [for (final x in r) frasiDelDocumento(pagine).indexWhere((f) => f.testo == x.testo)];
    expect(pos, [...pos]..sort());
  });

  test('quante frasi: 15% con minimo 3 e massimo 25', () {
    expect(frasiPerRiassunto(10), 3);
    expect(frasiPerRiassunto(100), 15);
    expect(frasiPerRiassunto(1000), 25);
    expect(frasiPerRiassunto(2), 2);
  });

  test('documento vuoto: riassunto vuoto', () {
    expect(riassunto(const {}), isEmpty);
    expect(riassunto(const {1: ''}), isEmpty);
  });
}
