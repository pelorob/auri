import 'package:auri/domain/avvisi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final ora = DateTime(2026, 10, 22, 15, 0);

  test('giorni alla scadenza: 4, 3, 1, 0 e null', () {
    expect(giorniAllaScadenza(DateTime(2026, 10, 26, 8), ora), 4);
    expect(giorniAllaScadenza(DateTime(2026, 10, 25, 8), ora), 3);
    expect(giorniAllaScadenza(DateTime(2026, 10, 23, 1), ora), 1);
    expect(giorniAllaScadenza(DateTime(2026, 10, 22, 23), ora), 0);
    expect(giorniAllaScadenza(null, ora), isNull);
  });

  test('a cavallo del cambio dell\'ora legale (25 ottobre 2026)', () {
    expect(giorniTra(DateTime(2026, 10, 24, 23, 30), DateTime(2026, 10, 26, 0, 30)), 2);
  });

  test('avviso firma solo con 3 giorni o meno', () {
    expect(mostraAvvisoFirma(4), isFalse);
    expect(mostraAvvisoFirma(3), isTrue);
    expect(mostraAvvisoFirma(0), isTrue);
    expect(mostraAvvisoFirma(null), isFalse);
    expect(testoAvvisoFirma(3), 'auri scade tra 3 giorni: apri SideStore e tocca Aggiorna');
    expect(testoAvvisoFirma(1), 'auri scade domani: apri SideStore e tocca Aggiorna');
    expect(testoAvvisoFirma(0), 'auri scade oggi: apri SideStore e tocca Aggiorna');
  });

  test('notifica firma: giorno prima alle 9, null se già passata', () {
    expect(quandoNotificaFirma(DateTime(2026, 10, 25, 8), ora), DateTime(2026, 10, 24, 9));
    expect(quandoNotificaFirma(DateTime(2026, 10, 23, 8), ora), isNull);
    expect(quandoNotificaFirma(null, ora), isNull);
  });

  test('promemoria backup dopo 7 giorni', () {
    final primo = DateTime(2026, 10, 1);
    expect(mostraPromemoriaBackup(primoAvvio: primo, ora: DateTime(2026, 10, 7)), isFalse);
    expect(mostraPromemoriaBackup(primoAvvio: primo, ora: DateTime(2026, 10, 8)), isTrue);
    expect(mostraPromemoriaBackup(ultimoBackup: DateTime(2026, 10, 20), primoAvvio: primo, ora: ora), isFalse);
  });

  test('blocco dopo N minuti in background', () {
    final t0 = DateTime(2026, 10, 22, 10, 0);
    expect(deveBloccare(attivo: true, inBackgroundDa: t0, ora: t0.add(const Duration(minutes: 5)), minuti: 5), isTrue);
    expect(deveBloccare(attivo: true, inBackgroundDa: t0, ora: t0.add(const Duration(minutes: 4)), minuti: 5), isFalse);
    expect(deveBloccare(attivo: false, inBackgroundDa: t0, ora: t0.add(const Duration(hours: 1)), minuti: 5), isFalse);
    expect(deveBloccare(attivo: true, inBackgroundDa: null, ora: t0, minuti: 5), isFalse);
  });

  test('nome del file di backup', () {
    expect(nomeFileBackup(DateTime(2026, 10, 3, 18)), 'auri-backup-2026-10-03.auri');
  });
}
