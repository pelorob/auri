import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'services/notifiche.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  pdfrxFlutterInitialize();
  final notifiche = NotificheService();
  await notifiche.inizializza();
  runApp(ProviderScope(overrides: [notificheProvider.overrideWithValue(notifiche)], child: const AuriApp()));
}
