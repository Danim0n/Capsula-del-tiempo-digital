import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../features/capsules/domain/capsule_models.dart';

class NotificationPreferences {
  const NotificationPreferences({
    this.opening = true,
    this.dayBefore = false,
    this.weekBefore = false,
  });
  final bool opening;
  final bool dayBefore;
  final bool weekBefore;
}

class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // tz.local remains available as a safe fallback on unsupported platforms.
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  Future<bool> requestPermission() async {
    if (!Platform.isAndroid) return true;
    return await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission() ??
        false;
  }

  Future<void> scheduleCapsule(
    Capsule capsule,
    NotificationPreferences preferences,
  ) async {
    await cancelCapsule(capsule.id);
    final base = capsule.id.hashCode & 0x3fffffff;
    final details = const NotificationDetails(
      android: AndroidNotificationDetails(
        'capsule_openings',
        'Aperturas de cápsulas',
        channelDescription: 'Avisos y recordatorios de cápsulas del tiempo',
        icon: 'ic_notification',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    if (preferences.opening) {
      await _schedule(
        base,
        capsule.unlockAt,
        'Tu cápsula está lista',
        "Ha llegado el momento de abrir '${capsule.title}'.",
        capsule.id,
        details,
      );
    }
    if (preferences.dayBefore) {
      await _schedule(
        base + 1,
        capsule.unlockAt.subtract(const Duration(days: 1)),
        'Mañana se abre una cápsula',
        "Pronto volverás a '${capsule.title}'.",
        capsule.id,
        details,
      );
    }
    if (preferences.weekBefore) {
      await _schedule(
        base + 2,
        capsule.unlockAt.subtract(const Duration(days: 7)),
        'Una cápsula se acerca',
        "Falta una semana para '${capsule.title}'.",
        capsule.id,
        details,
      );
    }
  }

  Future<void> _schedule(
    int id,
    DateTime when,
    String title,
    String body,
    String payload,
    NotificationDetails details,
  ) async {
    if (!when.isAfter(DateTime.now())) return;
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> cancelCapsule(String id) async {
    final base = id.hashCode & 0x3fffffff;
    await Future.wait([
      _plugin.cancel(id: base),
      _plugin.cancel(id: base + 1),
      _plugin.cancel(id: base + 2),
    ]);
  }
}
