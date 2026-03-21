import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/timetable_entry.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';
import 'subjects_provider.dart';
import 'settings_provider.dart';

final timetableProvider =
    StateNotifierProvider<TimetableNotifier, List<TimetableEntry>>(
  (ref) => TimetableNotifier(ref),
);

class TimetableNotifier extends StateNotifier<List<TimetableEntry>> {
  final Ref _ref;
  final _uuid = const Uuid();

  TimetableNotifier(this._ref) : super([]) {
    _load();
  }

  void _load() {
    final entries = HiveService.timetable.values.toList();
    entries.sort((a, b) {
      if (a.weekday != b.weekday) return a.weekday.compareTo(b.weekday);
      return a.startTime.compareTo(b.startTime);
    });
    state = entries;
  }

  Future<void> addEntry({
    required String subjectId,
    required int weekday,
    required String startTime,
    required String endTime,
  }) async {
    final entry = TimetableEntry()
      ..id = _uuid.v4()
      ..subjectId = subjectId
      ..weekday = weekday
      ..startTime = startTime
      ..endTime = endTime;
    await HiveService.timetable.put(entry.id, entry);
    _load();
    _rescheduleNotifications();
  }

  Future<void> editEntry(TimetableEntry entry, {
    required String subjectId,
    required int weekday,
    required String startTime,
    required String endTime,
  }) async {
    entry.subjectId = subjectId;
    entry.weekday = weekday;
    entry.startTime = startTime;
    entry.endTime = endTime;
    await entry.save();
    _load();
    _rescheduleNotifications();
  }

  Future<void> deleteEntry(String id) async {
    await HiveService.timetable.delete(id);
    _load();
    _rescheduleNotifications();
  }

  Future<void> _rescheduleNotifications() async {
    final settings = _ref.read(settingsProvider);
    if (!settings.notificationsEnabled) {
      await NotificationService.cancelAll();
      return;
    }
    
    // Request permissions if first time scheduling
    await NotificationService.requestPermissions();
    
    final subjects = _ref.read(subjectsProvider);
    await NotificationService.scheduleClassReminders(state, subjects);
  }

  List<TimetableEntry> entriesForWeekday(int weekday) {
    return state.where((e) => e.weekday == weekday).toList();
  }
}
