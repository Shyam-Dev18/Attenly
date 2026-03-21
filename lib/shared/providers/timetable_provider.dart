import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/timetable_entry.dart';
import '../services/hive_service.dart';

final timetableProvider =
    StateNotifierProvider<TimetableNotifier, List<TimetableEntry>>(
  (ref) => TimetableNotifier(),
);

class TimetableNotifier extends StateNotifier<List<TimetableEntry>> {
  final _uuid = const Uuid();

  TimetableNotifier() : super([]) {
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
  }

  Future<void> deleteEntry(String id) async {
    await HiveService.timetable.delete(id);
    _load();
  }

  List<TimetableEntry> entriesForWeekday(int weekday) {
    return state.where((e) => e.weekday == weekday).toList();
  }
}
