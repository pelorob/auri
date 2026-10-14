import 'package:auri/app/providers.dart';
import 'package:auri/app/shell.dart';
import 'package:auri/domain/preferenze.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/esempio.dart';

void main() {
  testWidgets('la barra laterale mostra le sezioni e quelle future come "presto"', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(conDati(const AuriShell()));
    await t.pump();
    for (final s in ['Oggi', 'Corsi', 'Calendario', 'Libretto', 'Impostazioni', 'Lezioni', 'Ripasso']) {
      expect(find.text(s), findsWidgets);
    }
    expect(find.text('presto'), findsOneWidget); // solo Lezioni: Ripasso è attivo dalla fase 3
  });

  testWidgets('le voci del menu non vengono troncate (es. "Lezioni" con "presto")', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(conDati(const AuriShell()));
    await t.pump();
    for (final voce in ['Lezioni', 'Ripasso', 'Impostazioni', 'Calendario']) {
      final testo = t.renderObject<RenderParagraph>(find.text(voce).first);
      expect(testo.didExceedMaxLines, isFalse, reason: '$voce è troncato');
    }
  });

  testWidgets('il menu laterale non trabocca anche con poco spazio in altezza (blocco attivo)', (t) async {
    t.view.physicalSize = const Size(1180, 450); // come con la tastiera aperta
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(conDati(const AuriShell(), preferenze: const Preferenze(primoAvvioFatto: true, bloccoAttivo: true)));
    await t.pump();
    expect(t.takeException(), isNull);
    expect(find.text('Blocca app'), findsOneWidget);
  });

  testWidgets('toccare Libretto cambia sezione', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(conDati(const AuriShell()));
    await t.pump();
    await t.tap(find.text('Libretto').first);
    await t.pump();
    final container = ProviderScope.containerOf(t.element(find.byType(AuriShell)));
    expect(container.read(sezioneProvider), Sezione.libretto);
  });
}
