import 'package:auri/domain/preferenze.dart';
import 'package:auri/features/oggi/oggi_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/esempio.dart';

void main() {
  testWidgets('prossimo esame, giorni, media, base, CFU', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(conDati(const OggiPage()));
    await t.pump();
    expect(find.text('Martedì 13 ottobre'.toUpperCase()), findsOneWidget);
    expect(find.text('Analisi Matematica I'), findsWidgets);
    expect(find.text('14'), findsOneWidget);
    expect(find.text('27,75'), findsOneWidget);
    expect(find.text('101,8'), findsOneWidget);
    expect(find.text('51'), findsOneWidget);
    expect(find.text('Programmazione'), findsOneWidget);
  });

  testWidgets('libretto vuoto e nessun appello: stati vuoti, nessun NaN', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(conDati(const OggiPage(), corsi: const [], appelli: const []));
    await t.pump();
    expect(find.text('Nessun esame in vista: aggiungi un appello'), findsOneWidget);
    expect(find.text('—'), findsWidgets);
    expect(find.textContaining('NaN'), findsNothing);
  });

  testWidgets('avviso firma con 2 giorni rimasti', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(conDati(const OggiPage(), scadenza: DateTime(2026, 10, 15, 8)));
    await t.pumpAndSettle();
    expect(find.text('auri scade tra 2 giorni: apri SideStore e tocca Aggiorna'), findsOneWidget);
  });

  testWidgets('promemoria backup dopo 7 giorni dal primo avvio', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(conDati(const OggiPage(), preferenze: Preferenze(primoAvvioFatto: true, primoAvvioIl: DateTime(2026, 10, 1))));
    await t.pump();
    expect(find.textContaining('Fai un backup'), findsOneWidget);
  });
}
