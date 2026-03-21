import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/timetable_entry.dart';
import '../models/subject.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    // *** FIX 1: Detect the device's local timezone name and set it ***
    // Without this, tz.local defaults to UTC which makes every notification
    // fire at the wrong time (or not at all on the same day).
    try {
      final String timeZoneName = DateTime.now().timeZoneName;
      // timeZoneName on Android is like "IST". We try to match it; if not found
      // we fall back to UTC+offset approach.
      final locations = tz.timeZoneDatabase.locations;
      final match = locations.entries.firstWhere(
        (e) => e.value.currentTimeZone.abbreviation == timeZoneName,
        orElse: () => locations.entries.first,
      );
      tz.setLocalLocation(match.value);
    } catch (_) {
      // Fallback: manually offset from UTC using the system offset
      final offsetSeconds = DateTime.now().timeZoneOffset.inSeconds;
      // Find a timezone that matches current offset
      final match = tz.timeZoneDatabase.locations.entries.firstWhere(
        (e) => e.value.currentTimeZone.offset == offsetSeconds * 1000,
        orElse: () => tz.timeZoneDatabase.locations.entries
            .firstWhere((e) => e.key == 'UTC'),
      );
      tz.setLocalLocation(match.value);
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings);
  }

  static Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.request();
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestExactAlarmsPermission();
      return status.isGranted;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final bool? result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    }
    return false;
  }

  static Future<void> scheduleClassReminders(
      List<TimetableEntry> entries, List<SubjectModel> subjects) async {
    await _notificationsPlugin.cancelAll();

    final subjectMap = {for (var s in subjects) s.id: s};
    int notificationId = 0;

    for (var entry in entries) {
      final subject = subjectMap[entry.subjectId];
      if (subject == null) continue;

      final parts = entry.startTime.split(':');
      if (parts.length < 2) continue;
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null || minute == null) continue;

      // *** FIX 2: Use tz-aware now so the comparison is in device local time ***
      final tzNow = tz.TZDateTime.now(tz.local);

      // entry.weekday: 1=Mon .. 7=Sun (same as DateTime.monday etc.)
      int daysUntil = entry.weekday - tzNow.weekday;
      if (daysUntil < 0) {
        daysUntil += 7;
      } else if (daysUntil == 0) {
        // Same weekday — check if the class time (minus 10 min) has already passed today
        final todayReminder = tz.TZDateTime(
            tz.local, tzNow.year, tzNow.month, tzNow.day, hour, minute)
            .subtract(const Duration(minutes: 10));
        if (tzNow.isAfter(todayReminder)) {
          daysUntil = 7; // Schedule for next week
        }
      }

      final scheduledDay = tzNow.add(Duration(days: daysUntil));
      final reminderTime = tz.TZDateTime(
        tz.local,
        scheduledDay.year,
        scheduledDay.month,
        scheduledDay.day,
        hour,
        minute,
      ).subtract(const Duration(minutes: 10));

      // Safety: never schedule in the past
      if (reminderTime.isBefore(tzNow)) continue;

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'class_reminders',
        'Class Reminders',
        channelDescription: 'Reminders for upcoming classes',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails details =
          NotificationDetails(android: androidDetails);

      await _notificationsPlugin.zonedSchedule(
        notificationId++,
        'Upcoming Class: ${subject.name}',
        'Starts at ${entry.startTime} in 10 minutes. Don\'t forget to mark attendance!',
        reminderTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  static Future<void> testNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'test_reminders',
      'Test Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      999,
      'Test Notification',
      'Notifications and exact alarms are working perfectly!',
      details,
    );
  }
}
