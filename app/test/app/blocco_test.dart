import 'package:auri/app/blocco.dart';
import 'package:auri/app/notifiche_app.dart';
import 'package:auri/domain/preferenze.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/esempio.dart';

void main() {
  test('si blocca al ritorno dopo 5 minuti solo se attivo', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final b = c.read(bloccoProvider.notifier);
    final t0 = DateTime(2026, 10, 13, 10);
    b.inBackground(t0);
    b.alRitorno(t0.add(const Duration(minutes: 6)), const Preferenze(bloccoAttivo: false));
    expect(c.read(bloccoProvider), isFalse);
    b.inBackground(t0);
    b.alRitorno(t0.add(const Duration(minutes: 6)), const Preferenze(bloccoAttivo: true));
    expect(c.read(bloccoProvider), isTrue);
    b.sblocca();
    expect(c.read(bloccoProvider), isFalse);
  });

  test('tutte le notifiche: appelli + firma con id 0', () {
    final n = tutteLeNotifiche(appelli: appelliEsempio, scadenza: DateTime(2026, 10, 20, 8), ora: ora);
    expect(n.where((x) => x.id == 0).single.quando, DateTime(2026, 10, 19, 9));
    expect(n.where((x) => x.id == 0).single.testo, 'auri scade domani: apri SideStore e tocca Aggiorna');
    expect(n.length, 7);
  });

  test('senza scadenza nessuna notifica firma', () {
    final n = tutteLeNotifiche(appelli: appelliEsempio, scadenza: null, ora: ora);
    expect(n.where((x) => x.id == 0), isEmpty);
  });
}
