import 'package:auri/features/libretto/libretto_page.dart';
import 'package:auri/features/libretto/voto_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/esempio.dart';

void main() {
  testWidgets('medie, base, CFU ed elenchi', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(conDati(const LibrettoPage()));
    await t.pump();
    expect(find.text('27,75'), findsOneWidget);
    expect(find.text('aritmetica 27,50'), findsOneWidget);
    expect(find.textContaining('101,8'), findsOneWidget);
    expect(find.text('SUPERATI · 7'), findsOneWidget);
    expect(find.text('DA SOSTENERE · 2'), findsOneWidget);
    expect(find.text('30L'), findsOneWidget);
    expect(find.text('Idoneo'), findsOneWidget);
  });

  testWidgets('simulatore: + porta il voto da 27 a 28 e aggiorna la media', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(conDati(const LibrettoPage()));
    await t.pump();
    expect(find.textContaining('27,60'), findsOneWidget);
    await t.tap(find.bySemanticsLabel('Alza il voto'));
    await t.pump();
    expect(find.text('28'), findsWidgets);
    expect(find.textContaining('27,80'), findsOneWidget);
  });

  testWidgets('obiettivo 110 fuori portata, 105 → 28,97', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(conDati(const LibrettoPage()));
    await t.pump();
    expect(find.text('28,97'), findsOneWidget);
    await t.tap(find.text('110'));
    await t.pump();
    expect(find.text('oltre 30'), findsOneWidget);
  });

  testWidgets('libretto vuoto: trattini, nessun simulatore', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(conDati(const LibrettoPage(), corsi: const []));
    await t.pump();
    expect(find.text('—'), findsWidgets);
    expect(find.bySemanticsLabel('Alza il voto'), findsNothing);
  });

  testWidgets('form voto: lode disattivata se il voto non è 30', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(conDati(FormVoto(corso: corsiEsempio[7].corso)));
    await t.pump();
    final lode = t.widget<SwitchListTile>(find.byType(SwitchListTile));
    expect(lode.onChanged, isNull);
  });

  testWidgets('form voto per corso a idoneità: nessun campo voto', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(conDati(FormVoto(corso: corsiEsempio[6].corso)));
    await t.pump();
    expect(find.byKey(const Key('voto')), findsNothing);
  });
}
