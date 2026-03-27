import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:uuid/uuid.dart';

import '../models/timetable_entry.dart';
import '../models/subject.dart';
import '../models/attendance_record.dart';
import 'hive_service.dart';

const String _actionPresent = 'mark_present';
const String _actionAbsent = 'mark_absent';

@pragma('vm:entry-point')
Future<void> notificationTapBackground(NotificationResponse response) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  await HiveService.init();
  await NotificationService.handleNotificationResponse(response);
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final Uuid _uuid = const Uuid();

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

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Handle notification action that launched the app from terminated state.
    final launchDetails = await _notificationsPlugin.getNotificationAppLaunchDetails();
    final launchResponse = launchDetails?.notificationResponse;
    if (launchResponse != null) {
      await handleNotificationResponse(launchResponse);
    }
  }

  static Future<void> handleNotificationResponse(NotificationResponse response) async {
    final actionId = response.actionId;
    if (actionId != _actionPresent && actionId != _actionAbsent) {
      return;
    }

    final payload = response.payload;
    if (payload == null || payload.isEmpty) {
      return;
    }

    await _markAttendanceFromPayload(
      payload,
      status: actionId == _actionPresent ? 'present' : 'absent',
    );

    // Ensure tapped notification is dismissed immediately for action UX.
    final id = response.id;
    if (id != null) {
      await _notificationsPlugin.cancel(id);
    }
  }

  static Future<void> _markAttendanceFromPayload(
    String payload, {
    required String status,
  }) async {
    try {
      await HiveService.init();

      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) {
        return;
      }

      final subjectId = decoded['subjectId'] as String?;
      final subjectName = decoded['subjectName'] as String?;
      if (subjectId == null || subjectId.isEmpty) {
        return;
      }

      final subject = HiveService.subjects.get(subjectId);
      if (subject == null) {
        return;
      }

      final classDateIso = decoded['classDate'] as String?;
      final now = DateTime.now();
      DateTime date = now;
      if (classDateIso != null) {
        final parsed = DateTime.tryParse(classDateIso);
        if (parsed != null) {
          date = parsed;
        }
      }
      final day = DateTime(date.year, date.month, date.day);
      AttendanceRecord? existing;
      for (final record in HiveService.attendance.values) {
        final rd = record.date;
        if (record.subjectId == subjectId &&
            rd.year == day.year &&
            rd.month == day.month &&
            rd.day == day.day) {
          existing = record;
          break;
        }
      }

      if (existing != null) {
        final oldStatus = existing.status;
        existing.status = status;
        await existing.save();
        await _updateSubjectCounters(subject, oldStatus, status);
      } else {
        final rec = AttendanceRecord()
          ..id = _uuid.v4()
          ..subjectId = subjectId
          ..date = day
          ..status = status;
        await HiveService.attendance.put(rec.id, rec);
        if (status != 'cancelled') {
          subject.totalClasses++;
          if (status == 'present') {
            subject.attendedClasses++;
          }
        }
        await subject.save();
      }

      final resultText = status == 'present' ? 'Present' : 'Absent';
      const feedbackDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'attendance_actions',
          'Attendance Actions',
          channelDescription: 'Confirmation for attendance actions from notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          autoCancel: true,
          ongoing: false,
        ),
      );
      await _notificationsPlugin.show(
        700001,
        'Attendance Updated',
        '${subjectName ?? subject.name}: marked $resultText for today.',
        feedbackDetails,
      );

      if (kDebugMode) {
        debugPrint(
          'NotificationService.action -> subjectId=$subjectId, status=$status, date=$day',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('NotificationService.action error -> $e');
      }
    }
  }

  static Future<void> _updateSubjectCounters(SubjectModel subject, String oldStatus, String newStatus) async {
    if (oldStatus != 'cancelled') {
      subject.totalClasses--;
      if (oldStatus == 'present') {
        subject.attendedClasses--;
      }
    }

    if (newStatus != 'cancelled') {
      subject.totalClasses++;
      if (newStatus == 'present') {
        subject.attendedClasses++;
      }
    }

    await subject.save();
  }

  static Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      // Prefer plugin API for Android 13+ notification runtime permission.
      final pluginGranted = await androidPlugin?.requestNotificationsPermission();
      final fallbackStatus = await Permission.notification.request();
      final granted = (pluginGranted ?? false) || fallbackStatus.isGranted;

      final canScheduleExact =
          await androidPlugin?.canScheduleExactNotifications() ?? true;
      if (!canScheduleExact) {
        await androidPlugin?.requestExactAlarmsPermission();
      }

      if (kDebugMode) {
        debugPrint(
          'NotificationService.requestPermissions -> '
          'granted=$granted, pluginGranted=$pluginGranted, '
          'fallbackStatus=${fallbackStatus.name}, canScheduleExact=$canScheduleExact',
        );
      }

      return granted;
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

    if (kDebugMode) {
      debugPrint(
        'NotificationService.scheduleClassReminders -> '
        'entries=${entries.length}, subjects=${subjects.length}, tz=${tz.local.name}',
      );
    }

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
      if (reminderTime.isBefore(tzNow)) {
        if (kDebugMode) {
          debugPrint(
            'NotificationService.scheduleClassReminders -> '
            'skip past reminder for subject=${subject.name}, time=$reminderTime, now=$tzNow',
          );
        }
        continue;
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'class_reminders',
        'Class Reminders',
        channelDescription: 'Reminders for upcoming classes',
        importance: Importance.max,
        priority: Priority.high,
        autoCancel: true,
        ongoing: false,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            _actionPresent,
            'Mark Present',
            cancelNotification: true,
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            _actionAbsent,
            'Mark Absent',
            cancelNotification: true,
            showsUserInterface: true,
          ),
        ],
      );

      const NotificationDetails details =
          NotificationDetails(android: androidDetails);

      final payload = jsonEncode({
        'subjectId': subject.id,
        'subjectName': subject.name,
        'weekday': entry.weekday,
        'startTime': entry.startTime,
        'classDate': reminderTime.toIso8601String(),
      });

      await _notificationsPlugin.zonedSchedule(
        notificationId++,
        'Upcoming Class: ${subject.name}',
        'Starts at ${entry.startTime} in 10 minutes. Don\'t forget to mark attendance!',
        reminderTime,
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );

      if (kDebugMode) {
        debugPrint(
          'NotificationService.scheduleClassReminders -> '
          'scheduled id=${notificationId - 1}, subject=${subject.name}, reminder=$reminderTime',
        );
      }
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

    if (kDebugMode) {
      debugPrint('NotificationService.testNotification -> posted id=999 on channel=test_reminders');
    }
  }
}
