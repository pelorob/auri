import 'package:auri/app/providers.dart';
import 'package:auri/domain/preferenze.dart';
import 'package:auri/features/impostazioni/impostazioni_page.dart';
import 'package:auri/features/impostazioni/primo_avvio_page.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/esempio.dart';

void main() {
  testWidgets('impostazioni mostrano valori, firma e Touch ID non disponibile', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(
      conDati(
        const ImpostazioniPage(),
        preferenze: const Preferenze(primoAvvioFatto: true, cfuTotali: 120, valoreLode: 31),
        scadenza: DateTime(2026, 10, 25, 8),
        altri: [touchIdDisponibileProvider.overrideWith((ref) async => false)],
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('120'), findsOneWidget);
    expect(find.textContaining('Touch ID non è configurato'), findsOneWidget);
    final lista = find.byType(Scrollable).first;
    await t.scrollUntilVisible(find.text('Esporta backup'), 200, scrollable: lista);
    expect(find.text('Ripristina backup'), findsOneWidget);
    await t.scrollUntilVisible(find.text('Firma valida fino a: domenica 25 ottobre'), 200, scrollable: lista);
    expect(find.text('Firma valida fino a: domenica 25 ottobre'), findsOneWidget);
  });

  testWidgets('primo avvio: tre passi e "Salta"', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(conDati(const PrimoAvvioPage(), preferenze: const Preferenze(), altri: [touchIdDisponibileProvider.overrideWith((ref) async => false)]));
    await t.pump();
    expect(find.text('Benvenuta in auri'), findsOneWidget);
    expect(find.text('Salta'), findsOneWidget);
    await t.tap(find.text('Avanti'));
    await t.pumpAndSettle();
    expect(find.text('Quanto vale la lode?'), findsOneWidget);
    await t.tap(find.text('Avanti'));
    await t.pumpAndSettle();
    expect(find.text('Proteggere auri con Touch ID?'), findsOneWidget);
  });
}
