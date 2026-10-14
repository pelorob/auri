import 'package:auri/domain/preferenze.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('predefinite con mappa vuota', () {
    final p = Preferenze.daMappa(const {});
    expect(p.cfuTotali, 180);
    expect(p.valoreLode, 30);
    expect(p.bloccoAttivo, isFalse);
    expect(p.minutiRiblocco, 5);
    expect(p.preavvisi, '7@9:00,1@9:00,0@7:30');
    expect(p.primoAvvioFatto, isFalse);
    expect(p.ultimoBackup, isNull);
    expect(p.nomeCorsoDiLaurea, '');
  });
  test('valori letti e valori non validi ignorati', () {
    final p = Preferenze.daMappa({
      Preferenze.kCfuTotali: '120',
      Preferenze.kLode: '33',
      Preferenze.kBlocco: 'true',
      Preferenze.kMinuti: 'xx',
      Preferenze.kUltimoBackup: '2026-10-10T08:00:00.000',
      Preferenze.kNome: 'Ingegneria Informatica',
    });
    expect(p.cfuTotali, 120);
    expect(p.valoreLode, 33);
    expect(p.bloccoAttivo, isTrue);
    expect(p.minutiRiblocco, 5);
    expect(p.ultimoBackup, DateTime(2026, 10, 10, 8));
    expect(p.nomeCorsoDiLaurea, 'Ingegneria Informatica');
  });
  test('lode fuori da 30–33 torna 30', () {
    expect(Preferenze.daMappa({Preferenze.kLode: '40'}).valoreLode, 30);
  });
}
