import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize(BuildContext context) async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'reminder_channel',
          'Reminders',
          channelDescription: 'App reminders and motivational nudges',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await _notificationsPlugin.show(0, title, body, platformChannelSpecifics);
  }

  static Future<void> showGoalAchievement({required String goal}) async {
    await showNotification(
      title: 'Congratulations!',
      body: 'You reached your $goal goal today 🎉',
    );
  }

  /// Schedules a daily reminder at 8 AM local time
  static Future<void> scheduleDefaultDailyReminder() async {
    await scheduleDailyReminder(
      time: const TimeOfDay(hour: 8, minute: 0),
      title: 'Daily Reminder',
      body: 'Time to get moving and reach your fitness goals!',
    );
  }

  static Future<void> scheduleDailyReminder({
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate =
        tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        ).add(
          now.isAfter(
                tz.TZDateTime(
                  tz.local,
                  now.year,
                  now.month,
                  now.day,
                  time.hour,
                  time.minute,
                ),
              )
              ? const Duration(days: 1)
              : Duration.zero,
        );
    const androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      channelDescription: 'App reminders and motivational nudges',
      importance: Importance.max,
      priority: Priority.high,
    );
    final notificationDetails = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.zonedSchedule(
      1,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
