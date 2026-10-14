import 'package:auri/data/database.dart';
import 'package:auri/data/repository.dart';
import 'package:auri/domain/modelli.dart';
import 'package:auri/domain/preferenze.dart';
import 'package:auri/features/oggi/oggi_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/esempio.dart';

void main() {
  testWidgets('orizzontale nella shell, due avvisi e 3 appelli: nessun overflow', (t) async {
    // Spazio di OggiPage dentro la shell a 1180×796: 1180-40-220-20 = 900, 796-40 = 756.
    t.view.physicalSize = const Size(900, 756);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final terzo = AppelloConCorso(
      Appello(id: 3, corsoId: 8, dataOra: DateTime(2026, 10, 30, 14, 30), tipo: TipoAppello.orale, aula: 'Studio 12', iscritta: false, preavvisi: '7@9:00'),
      corsiEsempio[7].corso,
    );
    await t.pumpWidget(
      conDati(
        const OggiPage(),
        appelli: [...appelliEsempio, terzo],
        scadenza: DateTime(2026, 10, 15, 8),
        preferenze: Preferenze(primoAvvioFatto: true, primoAvvioIl: DateTime(2026, 9, 1)),
      ),
    );
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(find.textContaining('auri scade'), findsOneWidget);
    expect(find.textContaining('Fai un backup'), findsOneWidget);
  });
}
