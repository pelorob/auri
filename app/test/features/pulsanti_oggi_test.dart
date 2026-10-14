import 'package:auri/app/providers.dart';
import 'package:auri/features/oggi/oggi_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/esempio.dart';

void main() {
  Future<ProviderContainer> apri(WidgetTester t) async {
    await schermoIpad(t);
    await t.pumpWidget(conDati(const OggiPage()));
    await t.pumpAndSettle();
    return ProviderScope.containerOf(t.element(find.byType(OggiPage)));
  }

  testWidgets('"Aggiungi" è un pulsante attivo per chi usa VoiceOver', (t) async {
    final semantica = t.ensureSemantics();
    await apri(t);
    expect(t.getSemantics(find.text('Aggiungi')), isSemantics(isButton: true, isEnabled: true, hasTapAction: true));
    semantica.dispose();
  });

  for (final (voce, titolo) in const [('Corso', 'Nuovo corso'), ('Appello', 'Nuovo appello'), ('Voto', 'Registra voto')]) {
    testWidgets('Aggiungi → $voce apre "$titolo"', (t) async {
      await apri(t);
      await t.tap(find.text('Aggiungi'));
      await t.pumpAndSettle();
      expect(find.text('Corso'), findsOneWidget);
      expect(find.text('Appello'), findsOneWidget);
      expect(find.text('Voto'), findsOneWidget);
      await t.tap(find.text(voce));
      await t.pumpAndSettle();
      expect(find.text(titolo), findsOneWidget);
      expect(find.text('Salva'), findsOneWidget);
    });
  }

  testWidgets('la scheda della media porta al Libretto', (t) async {
    final c = await apri(t);
    await t.tap(find.text('MEDIA PONDERATA'));
    await t.pump();
    expect(c.read(sezioneProvider), Sezione.libretto);
  });

  testWidgets('"Tutti" porta al Calendario', (t) async {
    final c = await apri(t);
    await t.tap(find.text('Tutti'));
    await t.pump();
    expect(c.read(sezioneProvider), Sezione.calendario);
  });

  testWidgets('"Libretto" porta al Libretto', (t) async {
    final c = await apri(t);
    await t.tap(find.text('Libretto'));
    await t.pump();
    expect(c.read(sezioneProvider), Sezione.libretto);
  });
}
