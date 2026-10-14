import 'package:auri/domain/libretto.dart';
import 'package:flutter_test/flutter_test.dart';

// Libretto del mockup: 6 esami a voto (48 CFU) + Inglese idoneità (3 CFU).
const esempio = [
  VoceLibretto(cfu: 12, superato: true, aVoto: true, voto: 30, lode: true),
  VoceLibretto(cfu: 9, superato: true, aVoto: true, voto: 29),
  VoceLibretto(cfu: 6, superato: true, aVoto: true, voto: 28),
  VoceLibretto(cfu: 6, superato: true, aVoto: true, voto: 27),
  VoceLibretto(cfu: 6, superato: true, aVoto: true, voto: 26),
  VoceLibretto(cfu: 9, superato: true, aVoto: true, voto: 25),
  VoceLibretto(cfu: 3, superato: true, aVoto: false),
  VoceLibretto(cfu: 12, superato: false, aVoto: true),
];

void main() {
  test('medie, base e CFU del mockup', () {
    final r = calcolaRiepilogo(esempio, valoreLode: 30);
    expect(r.sommaPesata, 1332);
    expect(r.cfuConVoto, 48);
    expect(r.cfuOttenuti, 51);
    expect(r.mediaPonderata, closeTo(27.75, 1e-9));
    expect(r.mediaAritmetica, closeTo(27.5, 1e-9));
    expect(r.baseLaurea, closeTo(101.75, 1e-9));
  });

  test('la lode vale valoreLode', () {
    final r = calcolaRiepilogo(esempio, valoreLode: 33);
    expect(r.sommaPesata, 1368);
    expect(r.mediaPonderata, closeTo(28.5, 1e-9));
  });

  test('lode ignorata se il voto non è 30', () {
    expect(valoreVoto(29, true, 33), 29);
  });

  test('libretto vuoto: tutto null, CFU 0', () {
    final r = calcolaRiepilogo(const [], valoreLode: 30);
    expect(r.mediaPonderata, isNull);
    expect(r.mediaAritmetica, isNull);
    expect(r.baseLaurea, isNull);
    expect(r.cfuOttenuti, 0);
  });

  test('solo idoneità: CFU contati, nessuna media', () {
    final r = calcolaRiepilogo(const [VoceLibretto(cfu: 3, superato: true, aVoto: false)], valoreLode: 30);
    expect(r.cfuOttenuti, 3);
    expect(r.mediaPonderata, isNull);
  });

  test('simulatore: Analisi 12 CFU con 27', () {
    final r = calcolaRiepilogo(esempio, valoreLode: 30);
    expect(simulaMedia(r, cfu: 12, voto: 27, valoreLode: 30), closeTo(27.6, 1e-9));
    expect(simulaMedia(r, cfu: 12, voto: 30, lode: true, valoreLode: 33), closeTo((1332 + 396) / 60, 1e-9));
  });

  test('media necessaria per 100 / 105 / 110 su 180 CFU', () {
    final r = calcolaRiepilogo(esempio, valoreLode: 30);
    final m100 = mediaNecessaria(r, obiettivo: 100, cfuTotali: 180);
    final m105 = mediaNecessaria(r, obiettivo: 105, cfuTotali: 180);
    expect(m100, isA<Raggiungibile>());
    expect((m100 as Raggiungibile).valore, closeTo(27.0951, 1e-3));
    expect((m105 as Raggiungibile).valore, closeTo(28.9662, 1e-3));
    expect(mediaNecessaria(r, obiettivo: 110, cfuTotali: 180), isA<FuoriPortata>());
  });

  test('media necessaria sotto 18: basta passare', () {
    final r = calcolaRiepilogo(const [VoceLibretto(cfu: 170, superato: true, aVoto: true, voto: 30)], valoreLode: 30);
    expect(mediaNecessaria(r, obiettivo: 100, cfuTotali: 180), isA<BastaPassare>());
  });

  test('nessun CFU mancante: null', () {
    final r = calcolaRiepilogo(const [VoceLibretto(cfu: 180, superato: true, aVoto: true, voto: 28)], valoreLode: 30);
    expect(mediaNecessaria(r, obiettivo: 105, cfuTotali: 180), isNull);
  });
}
