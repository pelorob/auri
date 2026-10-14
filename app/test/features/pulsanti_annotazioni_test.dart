import 'package:auri/features/slide/annotazioni.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/esempio.dart';

void main() {
  Future<StatoStrumento Function()> barra(WidgetTester t) async {
    await schermoIpad(t);
    await t.pumpWidget(conDati(const BarraStrumenti()));
    await t.pump();
    final c = ProviderScope.containerOf(t.element(find.byType(BarraStrumenti)));
    return () => c.read(strumentoProvider);
  }

  testWidgets('Penna: si seleziona e mostra i colori della penna; ritoccandola si deseleziona', (t) async {
    final stato = await barra(t);
    expect(find.byTooltip('Colore viola'), findsNothing);
    await t.tap(find.byTooltip('Penna'));
    await t.pump();
    expect(stato().strumento, Strumento.penna);
    for (final n in ['viola', 'nero', 'rosa', 'verde acqua']) {
      expect(find.byTooltip('Colore $n'), findsOneWidget);
    }
    await t.tap(find.byTooltip('Penna'));
    await t.pump();
    expect(stato().strumento, Strumento.nessuno);
  });

  testWidgets('Evidenziatore: si seleziona con i suoi colori e il primo colore evidenziatore', (t) async {
    final stato = await barra(t);
    await t.tap(find.byTooltip('Evidenziatore'));
    await t.pump();
    expect(stato().strumento, Strumento.evidenziatore);
    expect(stato().colore, coloriEvidenziatore.first);
    for (final n in ['lime', 'giallo', 'azzurro']) {
      expect(find.byTooltip('Colore $n'), findsOneWidget);
    }
    expect(find.byTooltip('Colore viola'), findsNothing);
    // Tornando alla penna, il colore torna uno della penna.
    await t.tap(find.byTooltip('Penna'));
    await t.pump();
    expect(stato().colore, coloriPenna.first);
  });

  testWidgets('Gomma: si seleziona e non mostra colori', (t) async {
    final stato = await barra(t);
    await t.tap(find.byTooltip('Gomma'));
    await t.pump();
    expect(stato().strumento, Strumento.gomma);
    expect(find.byTooltip('Colore viola'), findsNothing);
    expect(find.byTooltip('Colore lime'), findsNothing);
    expect(find.text('Disegna col dito'), findsOneWidget);
  });

  testWidgets('i pallini dei colori cambiano il colore', (t) async {
    final stato = await barra(t);
    await t.tap(find.byTooltip('Penna'));
    await t.pump();
    await t.tap(find.byTooltip('Colore rosa'));
    await t.pump();
    expect(stato().colore, 0xFFE0457B);
    await t.tap(find.byTooltip('Evidenziatore'));
    await t.pump();
    await t.tap(find.byTooltip('Colore azzurro'));
    await t.pump();
    expect(stato().colore, 0xFF7DD3FC);
  });

  testWidgets('pallini dei colori: area di tocco di almeno 44 punti e nome per VoiceOver', (t) async {
    final semantica = t.ensureSemantics();
    final stato = await barra(t);
    await t.tap(find.byTooltip('Penna'));
    await t.pump();
    final area = t.getSize(find.byTooltip('Colore nero'));
    expect(area.width, greaterThanOrEqualTo(44));
    expect(area.height, greaterThanOrEqualTo(44));
    expect(find.bySemanticsLabel('Colore nero'), findsOneWidget);
    // Toccando il bordo dell'area (fuori dal pallino da 26) il colore cambia lo stesso.
    final r = t.getRect(find.byTooltip('Colore nero'));
    await t.tapAt(Offset(r.center.dx, r.top + 4));
    await t.pump();
    expect(stato().colore, 0xFF19142E);
    semantica.dispose();
  });
}
