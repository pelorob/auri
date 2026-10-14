import 'dart:ui';

import 'package:auri/domain/tratti.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('punti: scrittura e lettura (coordinate 0–1, 4 decimali)', () {
    final p = [const Offset(0.1, 0.2), const Offset(0.12345, 0.98765)];
    final testo = scriviPunti(p);
    expect(testo, '0.1000,0.2000;0.1235,0.9877');
    final letti = leggiPunti(testo);
    expect(letti.length, 2);
    expect(letti[1].dx, closeTo(0.1235, 1e-9));
  });

  test('lettura tollerante: parti rotte saltate, stringa vuota → nessun punto', () {
    expect(leggiPunti(''), isEmpty);
    expect(leggiPunti('0.1,0.2;rotto;0.3'), [const Offset(0.1, 0.2)]);
  });

  test('semplificazione: toglie i punti troppo vicini, tiene primo e ultimo', () {
    final p = [for (var i = 0; i <= 100; i++) Offset(i / 1000, 0)];
    final s = semplifica(p, distanzaMinima: 0.01);
    expect(s.first, p.first);
    expect(s.last, p.last);
    expect(s.length, lessThan(15));
  });

  test('normalizza e denormalizza rispetto alla pagina', () {
    const pagina = Rect.fromLTWH(100, 50, 400, 800);
    final n = normalizza(const Offset(300, 450), pagina);
    expect(n, const Offset(0.5, 0.5));
    expect(denormalizza(n, pagina), const Offset(300, 450));
  });

  test('gomma: un tratto è toccato se passa vicino al punto', () {
    final tratto = [const Offset(0.1, 0.1), const Offset(0.5, 0.1)];
    expect(toccato(tratto, const Offset(0.3, 0.11), raggio: 0.02), isTrue);
    expect(toccato(tratto, const Offset(0.3, 0.3), raggio: 0.02), isFalse);
  });
}
