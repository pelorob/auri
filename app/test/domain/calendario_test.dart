import 'package:auri/domain/calendario.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ottobre 2026 inizia di giovedì: 3 vuoti, 35 celle', () {
    final c = celleMese(2026, 10);
    expect(c.length, 35);
    expect(c.take(3), everyElement(isNull));
    expect(c[3], DateTime(2026, 10, 1));
    expect(c[33], DateTime(2026, 10, 31));
    expect(c[34], isNull);
  });
  test('febbraio 2027 inizia di lunedì: 28 celle esatte', () {
    final c = celleMese(2027, 2);
    expect(c.length, 28);
    expect(c.first, DateTime(2027, 2, 1));
  });
}
