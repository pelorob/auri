import 'package:auri/app/providers.dart';
import 'package:auri/data/repository.dart';
import 'package:auri/features/studio/pomodoro.dart';
import 'package:auri/features/studio/studio_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/esempio.dart';

class _RepoFinto extends Fake implements Repository {
  final sessioni = <({int? corsoId, int minuti})>[];
  @override
  Future<int> salvaSessione({required int? corsoId, required DateTime inizio, required int minuti}) async {
    sessioni.add((corsoId: corsoId, minuti: minuti));
    return sessioni.length;
  }
}

void main() {
  late _RepoFinto repo;

  setUp(() => repo = _RepoFinto());

  Widget app() => conDati(
    const StudioPage(),
    altri: [
      repositoryProvider.overrideWithValue(repo),
      documentiProvider.overrideWith((ref) => Stream.value(const [])),
      sessioniProvider.overrideWith((ref) => Stream.value(const [])),
      pagineStudiateProvider.overrideWith((ref) => Stream.value(const [])),
      revisioniProvider.overrideWith((ref) => Stream.value(const [])),
      carteProvider.overrideWith((ref) => Stream.value(const [])),
      simulazioniProvider.overrideWith((ref) => Stream.value(const [])),
      richiestaPermessoNotificheProvider.overrideWithValue(() async => false),
    ],
  );

  Future<void> apri(WidgetTester t) async {
    await schermoIpad(t);
    await t.pumpWidget(app());
    final contenitore = ProviderScope.containerOf(t.element(find.byType(StudioPage)));
    addTearDown(() {
      try {
        contenitore.read(pomodoroProvider.notifier).ferma();
      } on StateError catch (_) {}
    });
    await t.pump();
  }

  testWidgets('le durate 50/10, 15/5 e 25/5 cambiano il timer', (t) async {
    await apri(t);
    expect(find.text('25:00'), findsOneWidget);
    await t.tap(find.text('50 / 10'));
    await t.pump();
    expect(find.text('50:00'), findsOneWidget);
    expect(t.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '50 / 10')).selected, isTrue);
    await t.tap(find.text('15 / 5'));
    await t.pump();
    expect(find.text('15:00'), findsOneWidget);
    await t.tap(find.text('25 / 5'));
    await t.pump();
    expect(find.text('25:00'), findsOneWidget);
    expect(t.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '25 / 5')).selected, isTrue);
  });

  testWidgets('il corso scelto finisce nella sessione salvata', (t) async {
    await apri(t);
    await t.tap(find.byType(DropdownButtonFormField<int?>));
    await t.pumpAndSettle();
    await t.tap(find.text('Statistica').last);
    await t.pumpAndSettle();
    await t.tap(find.text('15 / 5'));
    await t.pump();
    await t.tap(find.text('Inizia'));
    await t.pump();
    await t.pump(const Duration(minutes: 15, seconds: 1));
    await t.pump();
    expect(repo.sessioni, [(corsoId: 5, minuti: 15)]);
    expect(find.text('PAUSA'), findsOneWidget);
    await t.tap(find.text('Ferma'));
    await t.pump();
  });
}
