import 'dart:async';

import 'package:auri/app/blocco.dart';
import 'package:auri/app/blocco_page.dart';
import 'package:auri/app/providers.dart';
import 'package:auri/app/shell.dart';
import 'package:auri/domain/preferenze.dart';
import 'package:auri/services/touch_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/esempio.dart';

/// Ogni richiesta resta in attesa finché il test non risponde.
class TouchIdFinto extends TouchIdService {
  final richieste = <Completer<bool>>[];
  @override
  Future<bool> disponibile() async => true;
  @override
  Future<bool> autentica() {
    richieste.add(Completer());
    return richieste.last.future;
  }
}

void main() {
  late TouchIdFinto touchId;
  setUp(() => touchId = TouchIdFinto());

  /// Apre l'app già bloccata: la prima richiesta parte da sola.
  Future<ProviderContainer> bloccata(WidgetTester t) async {
    await t.pumpWidget(
      ProviderScope(
        overrides: [touchIdProvider.overrideWithValue(touchId)],
        child: MaterialApp(
          builder: (context, child) => StratoBlocco(child: child!),
          home: const Scaffold(body: Text('Dati')),
        ),
      ),
    );
    final c = ProviderScope.containerOf(t.element(find.text('Dati')));
    c.read(bloccoProvider.notifier).blocca();
    await t.pump();
    await t.pump();
    return c;
  }

  testWidgets('all\'apertura parte una sola richiesta; i pulsanti non ne aprono una seconda', (t) async {
    final c = await bloccata(t);
    expect(touchId.richieste, hasLength(1));
    await t.tap(find.text('Sblocca con Touch ID'), warnIfMissed: false);
    await t.tap(find.text('Usa il codice dell\'iPad'), warnIfMissed: false);
    await t.pump();
    expect(touchId.richieste, hasLength(1));
    touchId.richieste.single.complete(true);
    await t.pumpAndSettle();
    expect(c.read(bloccoProvider), isFalse);
  });

  testWidgets('se non la riconosce lo dice e "Sblocca con Touch ID" riprova', (t) async {
    final c = await bloccata(t);
    touchId.richieste.single.complete(false);
    await t.pump();
    expect(find.text('Non riconosciuta, riprova'), findsOneWidget);
    expect(c.read(bloccoProvider), isTrue);
    await t.tap(find.text('Sblocca con Touch ID'));
    await t.pump();
    expect(touchId.richieste, hasLength(2));
    expect(find.text('Non riconosciuta, riprova'), findsNothing);
    touchId.richieste.last.complete(true);
    await t.pumpAndSettle();
    expect(c.read(bloccoProvider), isFalse);
    expect(find.byType(BloccoPage), findsNothing);
  });

  testWidgets('"Usa il codice dell\'iPad" chiede l\'autenticazione', (t) async {
    final c = await bloccata(t);
    touchId.richieste.single.complete(false);
    await t.pump();
    await t.tap(find.text('Usa il codice dell\'iPad'));
    await t.pump();
    expect(touchId.richieste, hasLength(2));
    touchId.richieste.last.complete(true);
    await t.pumpAndSettle();
    expect(c.read(bloccoProvider), isFalse);
  });

  group('"Blocca app"', () {
    const conBlocco = Preferenze(primoAvvioFatto: true, bloccoAttivo: true);

    testWidgets('dalla barra laterale blocca l\'app', (t) async {
      await schermoIpad(t);
      await t.pumpWidget(conDati(const AuriShell(), preferenze: conBlocco));
      await t.pump();
      final c = ProviderScope.containerOf(t.element(find.byType(AuriShell)));
      await t.tap(find.text('Blocca app'));
      await t.pump();
      expect(c.read(bloccoProvider), isTrue);
    });

    testWidgets('in verticale il lucchetto blocca l\'app', (t) async {
      t.view.physicalSize = const Size(820, 1180);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(conDati(const AuriShell(), preferenze: conBlocco));
      await t.pump();
      final c = ProviderScope.containerOf(t.element(find.byType(AuriShell)));
      await t.tap(find.byTooltip('Blocca app'));
      await t.pump();
      expect(c.read(bloccoProvider), isTrue);
    });

    testWidgets('senza blocco attivo il pulsante non c\'è', (t) async {
      await schermoIpad(t);
      await t.pumpWidget(conDati(const AuriShell()));
      await t.pump();
      expect(find.text('Blocca app'), findsNothing);
    });
  });
}
