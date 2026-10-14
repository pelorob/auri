import 'package:auri/data/repository.dart';
import 'package:auri/features/calendario/calendario_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/esempio.dart';

void main() {
  testWidgets('ottobre 2026 con i giorni e l\'esame del 27', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(conDati(const CalendarioPage()));
    await t.pump();
    expect(find.text('Ottobre 2026'), findsOneWidget);
    expect(find.text('31'), findsOneWidget);
    expect(find.text('Analisi Matematica I · scritto'), findsOneWidget);
  });

  testWidgets('frecce: novembre mostra Basi di Dati', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(conDati(const CalendarioPage()));
    await t.pump();
    await t.tap(find.byTooltip('Mese successivo'));
    await t.pump();
    expect(find.text('Novembre 2026'), findsOneWidget);
    expect(find.text('Basi di Dati · scritto'), findsOneWidget);
  });

  testWidgets('lista appelli con giorni mancanti e stato iscrizione', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(conDati(const CalendarioPage()));
    await t.pump();
    expect(find.text('14 g'), findsOneWidget);
    expect(find.text('22 g'), findsOneWidget);
    expect(find.text('Iscritta'), findsOneWidget);
    expect(find.text('Non iscritta'), findsOneWidget);
  });

  testWidgets('nessun appello: messaggio', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(conDati(const CalendarioPage(), appelli: const <AppelloConCorso>[]));
    await t.pump();
    expect(find.text('Nessun appello in programma'), findsOneWidget);
  });
}
