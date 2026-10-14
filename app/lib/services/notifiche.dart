import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../domain/notifiche_piano.dart';

/// Notifiche riservate al Pomodoro (non toccate da [NotificheService.riprogramma]).
const idPomodoro = 900000;
bool _diPomodoro(int id) => id >= 900000 && id <= 900099;

class NotificheService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _pronta = false;

  IOSFlutterLocalNotificationsPlugin? get _ios => _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

  Future<void> inizializza() async {
    if (!Platform.isIOS) return;
    tzdata.initializeTimeZones();
    final zona = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zona.identifier));
    await _plugin.initialize(
      settings: const InitializationSettings(
        iOS: DarwinInitializationSettings(requestAlertPermission: false, requestBadgePermission: false, requestSoundPermission: false),
      ),
    );
    _pronta = true;
  }

  Future<bool> chiediPermesso() async => !_pronta ? true : (await _ios?.requestPermissions(alert: true, sound: true) ?? false);

  Future<bool?> permessoConcesso() async {
    if (!_pronta) return null;
    final s = await _ios?.checkPermissions();
    return s?.isEnabled;
  }

  Future<void> riprogramma(List<NotificaPianificata> notifiche) async {
    if (!_pronta) return;
    for (final vecchia in await _plugin.pendingNotificationRequests()) {
      if (!_diPomodoro(vecchia.id)) await _plugin.cancel(id: vecchia.id);
    }
    for (final n in notifiche) {
      try {
        await _plugin.zonedSchedule(
          id: n.id,
          title: n.titolo,
          body: n.testo,
          scheduledDate: tz.TZDateTime.from(n.quando, tz.local),
          notificationDetails: const NotificationDetails(iOS: DarwinNotificationDetails()),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } catch (_) {
        // Permesso negato o errore di sistema: si riprova alla prossima riprogrammazione.
      }
    }
  }

  /// Avviso di fine fase del Pomodoro (arriva anche con l'iPad bloccato).
  Future<void> programmaPomodoro(DateTime quando, String titolo, String testo) async {
    if (!_pronta) return;
    try {
      await _plugin.zonedSchedule(
        id: idPomodoro,
        title: titolo,
        body: testo,
        scheduledDate: tz.TZDateTime.from(quando, tz.local),
        notificationDetails: const NotificationDetails(iOS: DarwinNotificationDetails()),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (_) {}
  }

  Future<void> annullaPomodoro() async {
    if (!_pronta) return;
    try {
      await _plugin.cancel(id: idPomodoro);
    } catch (_) {}
  }
}
