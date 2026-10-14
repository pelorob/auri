import 'package:auri/features/corsi/corsi_page.dart';
import 'package:auri/features/corsi/corso_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/esempio.dart';

void main() {
  testWidgets('griglia: corsi superati con voto, da sostenere con prossimo appello', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(conDati(const CorsiPage()));
    await t.pump();
    expect(find.text('Programmazione'), findsOneWidget);
    expect(find.text('Superato · 29'), findsOneWidget);
    expect(find.text('Appello 27 ottobre'), findsOneWidget);
    expect(find.text('Superato · Idoneo'), findsOneWidget);
  });

  testWidgets('form: senza nome e con CFU 0 mostra gli errori e non chiude', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(conDati(const FormCorso()));
    await t.enterText(find.byKey(const Key('cfu')), '0');
    await t.tap(find.text('Salva'));
    await t.pump();
    expect(find.text('Scrivi il nome del corso'), findsOneWidget);
    expect(find.text('I CFU devono essere un numero maggiore di 0'), findsOneWidget);
  });
}
