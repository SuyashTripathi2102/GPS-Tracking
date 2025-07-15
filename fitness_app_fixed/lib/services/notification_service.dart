import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings android = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const InitializationSettings settings = InitializationSettings(
      android: android,
    );
    await _plugin.initialize(settings);
  }

  static Future<void> showCompletedNotification(String title) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'challenge_channel',
          'Challenge Updates',
          importance: Importance.max,
          priority: Priority.high,
        );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );
    await _plugin.show(
      0,
      '🎉 Challenge Complete!',
      '$title marked as DONE!',
      details,
    );
  }
}
