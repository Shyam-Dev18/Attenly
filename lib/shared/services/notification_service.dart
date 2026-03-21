import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/timetable_entry.dart';
import '../models/subject.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
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
        return status.isGranted;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final bool? result = await _notificationsPlugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
        return result ?? false;
    }
    return false;
  }

  static Future<void> scheduleClassReminders(List<TimetableEntry> entries, List<SubjectModel> subjects) async {
    await _notificationsPlugin.cancelAll();

    final subjectMap = {for (var s in subjects) s.id: s};

    int notificationId = 0;

    for (var entry in entries) {
      final subject = subjectMap[entry.subjectId];
      if (subject == null) continue;

      // Class starts at entry.startTime (e.g. "09:00")
      // We want to remind 10 minutes before
      final parts = entry.startTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // Calculate next occurrence of this weekday
      DateTime now = DateTime.now();
      // DateTime weekday: 1=Mon .. 7=Sun
      int daysUntil = entry.weekday - now.weekday;
      if (daysUntil < 0 || (daysUntil == 0 && (now.hour > hour || (now.hour == hour && now.minute >= minute)))) {
        daysUntil += 7; // Next week
      }

      DateTime nextDate = now.add(Duration(days: daysUntil));
      DateTime scheduledTime = DateTime(nextDate.year, nextDate.month, nextDate.day, hour, minute);
      DateTime reminderTime = scheduledTime.subtract(const Duration(minutes: 10));

      // Don't schedule in the past
      if (reminderTime.isBefore(DateTime.now())) {
          reminderTime = reminderTime.add(const Duration(days: 7));
      }

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'class_reminders',
        'Class Reminders',
        channelDescription: 'Reminders for upcoming classes',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails details = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.zonedSchedule(
        notificationId++,
        'Upcoming Class: ${subject.name}',
        'Starts at ${entry.startTime} in 10 minutes. Don\'t forget to mark attendance!',
        tz.TZDateTime.from(reminderTime, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
