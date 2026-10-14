import 'package:auri/app/blocco.dart';
import 'package:auri/app/blocco_page.dart';
import 'package:auri/app/providers.dart';
import 'package:auri/services/touch_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class TouchIdFinto extends TouchIdService {
  TouchIdFinto({required this.presente});
  final bool presente;
  @override
  Future<bool> disponibile() async => presente;
  @override
  Future<bool> autentica() async => false;
}

Widget app(TouchIdService touchId) => ProviderScope(
  overrides: [touchIdProvider.overrideWithValue(touchId)],
  child: MaterialApp(
    builder: (context, child) => StratoBlocco(child: child!),
    home: Scaffold(
      body: Builder(
        builder: (c) => TextButton(
          onPressed: () => showDialog(
            context: c,
            builder: (_) => const AlertDialog(content: Text('Segreto')),
          ),
          child: const Text('Apri'),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('il blocco copre anche i dialoghi aperti', (t) async {
    await t.pumpWidget(app(TouchIdFinto(presente: true)));
    await t.tap(find.text('Apri'));
    await t.pumpAndSettle();
    final c = ProviderScope.containerOf(t.element(find.text('Segreto')));
    c.read(bloccoProvider.notifier).blocca();
    await t.pumpAndSettle();
    expect(find.byType(BloccoPage), findsOneWidget);
    expect(find.text('Segreto').hitTestable(), findsNothing);
  });

  testWidgets('senza Touch ID né codice il blocco si toglie da solo', (t) async {
    await t.pumpWidget(app(TouchIdFinto(presente: false)));
    final c = ProviderScope.containerOf(t.element(find.text('Apri')));
    c.read(bloccoProvider.notifier).blocca();
    await t.pumpAndSettle();
    expect(c.read(bloccoProvider), isFalse);
    expect(find.byType(BloccoPage), findsNothing);
  });
}
