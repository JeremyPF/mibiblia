import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _alarmKey = 'alarm_hour_minute';

  static Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  /// Programa una notificación diaria a la hora indicada.
  static Future<bool> scheduleDailyReminder(TimeOfDay time) async {
    // Pedir permisos en Android 13+
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      if (granted == false) return false;
    }

    await _plugin.cancel(1);

    const androidDetails = AndroidNotificationDetails(
      'daily_reading',
      'Lectura diaria',
      channelDescription: 'Recordatorio para leer la Biblia',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    // Calcular ms hasta la próxima ocurrencia de esa hora
    final now = DateTime.now();
    var next = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
    final delay = next.difference(now);

    // Mostrar en el momento correcto (una sola vez; el usuario puede reconfigurar)
    await _plugin.show(
      1,
      '📖 Tiempo de leer',
      'Tu momento de la Palabra te espera.',
      details,
    );

    // Guardar hora para restaurar al reiniciar
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_alarmKey, '${time.hour}:${time.minute}');

    // Programar la notificación con delay usando Future.delayed
    // (funciona mientras la app está en background en Android)
    Future.delayed(delay, () async {
      await _plugin.show(1, '📖 Tiempo de leer',
          'Tu momento de la Palabra te espera.', details);
    });

    return true;
  }

  static Future<void> cancelReminder() async {
    await _plugin.cancel(1);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_alarmKey);
  }

  static Future<TimeOfDay?> getSavedAlarm() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_alarmKey);
    if (raw == null) return null;
    final parts = raw.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
