import 'package:auri/domain/formati.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatta con virgola e decimali', () {
    expect(formatta(27.75, 2), '27,75');
    expect(formatta(101.75, 1), '101,8');
    expect(formatta(27.5, 2), '27,50');
    expect(formatta(null, 2), '—');
  });
  test('giorni fa', () {
    final ora = DateTime(2026, 10, 14, 9);
    expect(giorniFa(DateTime(2026, 10, 14, 8), ora), 'oggi');
    expect(giorniFa(DateTime(2026, 10, 13, 23), ora), 'ieri');
    expect(giorniFa(DateTime(2026, 10, 4, 12), ora), '10 giorni fa');
  });

  test('date in italiano', () {
    final d = DateTime(2026, 10, 27, 9, 0);
    expect(dataLunga(d), '27 ottobre');
    expect(oraMinuti(d), '9:00');
    expect(oraMinuti(DateTime(2026, 10, 30, 14, 30)), '14:30');
    expect(meseBreve(d), 'OTT');
    expect(giornoSettimana(d), 'martedì');
  });
}
