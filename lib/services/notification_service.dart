import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  /// ✅ تهيئة النظام
  static Future<void> init() async {
    // إعداد Android
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    // إعداد iOS
    const ios = DarwinInitializationSettings();

    // ربط الإعدادات
    const settings = InitializationSettings(android: android, iOS: ios);

    // تهيئة Local Notifications
    await _plugin.initialize(settings);

    // تهيئة Timezone
    tz.initializeTimeZones();
  }

  /// ✅ إشعار فوري
  static Future<void> showNow({
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'doctime_channel',
        'Doctime Notifications',
        channelDescription: 'General notifications for DocTime app',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000), // unique id
      title,
      body,
      details,
    );
  }

  /// ✅ إشعار مجدول (Reminder)
  static Future<void> schedule({
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'doctime_channel',
        'Doctime Notifications',
        channelDescription: 'Reminders for appointments',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    // id فريد لكل إشعار
    final notifId = scheduledTime.millisecondsSinceEpoch.remainder(100000);

    await _plugin.zonedSchedule(
      notifId,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null, // إذا بدك تكرار (مثلاً يومياً) بتحط: DateTimeComponents.time
    );
  }
}
