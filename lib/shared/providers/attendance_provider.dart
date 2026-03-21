import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/attendance_record.dart';
import '../models/subject.dart';
import '../services/hive_service.dart';
import '../../core/utils/utils.dart';
import 'subjects_provider.dart';

final attendanceProvider =
    StateNotifierProvider<AttendanceNotifier, List<AttendanceRecord>>(
  (ref) => AttendanceNotifier(ref),
);

class AttendanceNotifier extends StateNotifier<List<AttendanceRecord>> {
  final Ref _ref;
  final _uuid = const Uuid();

  AttendanceNotifier(this._ref) : super([]) {
    _load();
  }

  void _load() {
    state = HiveService.attendance.values.toList();
  }

  List<AttendanceRecord> recordsForDate(DateTime date) {
    final d = dateOnly(date);
    return state.where((r) => isSameDay(r.date, d)).toList();
  }

  List<AttendanceRecord> recordsForSubject(String subjectId) {
    return state.where((r) => r.subjectId == subjectId).toList();
  }

  AttendanceRecord? recordForSubjectAndDate(String subjectId, DateTime date) {
    final d = dateOnly(date);
    try {
      return state.firstWhere((r) => r.subjectId == subjectId && isSameDay(r.date, d));
    } catch (_) {
      return null;
    }
  }

  Future<void> markAttendance({
    required String subjectId,
    required DateTime date,
    required String status,
  }) async {
    final existing = recordForSubjectAndDate(subjectId, date);
    final subject = HiveService.subjects.get(subjectId);
    if (subject == null) return;

    if (existing != null) {
      final oldStatus = existing.status;
      existing.status = status;
      await existing.save();

      // Update subject counters
      _updateSubjectCounters(subject, oldStatus, status);
    } else {
      final rec = AttendanceRecord()
        ..id = _uuid.v4()
        ..subjectId = subjectId
        ..date = dateOnly(date)
        ..status = status;
      await HiveService.attendance.put(rec.id, rec);

      // Increment counters
      if (status != 'cancelled') {
        subject.totalClasses++;
        if (status == 'present') subject.attendedClasses++;
      }
      await subject.save();
    }

    _load();
    _ref.read(subjectsProvider.notifier).refreshSubjects();
  }

  void _updateSubjectCounters(SubjectModel subject, String oldStatus, String newStatus) {
    // Reverse old
    if (oldStatus != 'cancelled') {
      subject.totalClasses--;
      if (oldStatus == 'present') subject.attendedClasses--;
    }
    // Apply new
    if (newStatus != 'cancelled') {
      subject.totalClasses++;
      if (newStatus == 'present') subject.attendedClasses++;
    }
    subject.save();
  }

  Future<void> deleteRecord(AttendanceRecord record) async {
    final subject = HiveService.subjects.get(record.subjectId);
    if (subject != null) {
      _updateSubjectCounters(subject, record.status, 'cancelled');
      // Actually remove from total that we marked as cancelled:
      // After calling _updateSubjectCounters with 'cancelled', counters are correct.
    }
    await HiveService.attendance.delete(record.id);
    _load();
    _ref.read(subjectsProvider.notifier).refreshSubjects();
  }
}

final attendanceByDateProvider = Provider.family<List<AttendanceRecord>, DateTime>((ref, date) {
  final all = ref.watch(attendanceProvider);
  return all.where((r) => isSameDay(r.date, date)).toList();
});

final attendanceBySubjectProvider = Provider.family<List<AttendanceRecord>, String>((ref, subjectId) {
  final all = ref.watch(attendanceProvider);
  return all.where((r) => r.subjectId == subjectId).toList();
});
