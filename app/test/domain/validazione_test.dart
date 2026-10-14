import 'package:auri/domain/validazione.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('nome', () {
    expect(validaNome(''), 'Scrivi il nome del corso');
    expect(validaNome('   '), 'Scrivi il nome del corso');
    expect(validaNome('Analisi'), isNull);
  });
  test('CFU', () {
    expect(validaCfu('0'), 'I CFU devono essere un numero maggiore di 0');
    expect(validaCfu('-3'), isNotNull);
    expect(validaCfu('abc'), isNotNull);
    expect(validaCfu(' 12 '), isNull);
  });
  test('voto e lode', () {
    expect(validaVoto(17), 'Il voto va da 18 a 30');
    expect(validaVoto(31), isNotNull);
    expect(validaVoto(null), isNotNull);
    expect(validaVoto(18), isNull);
    expect(lodeAmmessa(30), isTrue);
    expect(lodeAmmessa(29), isFalse);
  });
}
