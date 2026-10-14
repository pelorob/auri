import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Carica i caratteri veri dell'app, così le misure nei test sono realistiche.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final (famiglia, file) in const [('Bricolage', 'assets/fonts/Bricolage.ttf'), ('DMSans', 'assets/fonts/DMSans.ttf')]) {
    await (FontLoader(famiglia)..addFont(rootBundle.load(file))).load();
  }
  await testMain();
}
