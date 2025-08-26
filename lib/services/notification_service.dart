import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(settings);

    // ضروري للجدولة
    tz.initializeTimeZones();
  }

  /// إشعار فوري
  static Future<void> showNow({
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'doctime_channel',
        'Doctime Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(0, title, body, details);
  }

  /// إشعار مجدول
  static Future<void> schedule({
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'doctime_channel',
        'Doctime Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    // id لازم يكون int
    final notifId = scheduledTime.millisecondsSinceEpoch.remainder(100000);

    await _plugin.zonedSchedule(
      notifId,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
