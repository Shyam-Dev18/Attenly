import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/subject.dart';
import '../services/hive_service.dart';

final subjectsProvider =
    StateNotifierProvider<SubjectsNotifier, List<SubjectModel>>(
  (ref) => SubjectsNotifier(),
);

class SubjectsNotifier extends StateNotifier<List<SubjectModel>> {
  final _uuid = const Uuid();

  SubjectsNotifier() : super([]) {
    _load();
  }

  void _load() {
    state = HiveService.subjects.values.toList();
  }

  Future<void> addSubject({
    required String name,
    required String colorHex,
    required int goal,
  }) async {
    if (state.any((s) => s.name.trim().toLowerCase() == name.trim().toLowerCase())) {
      throw Exception('A subject with this name already exists.');
    }
    final sub = SubjectModel()
      ..id = _uuid.v4()
      ..name = name
      ..colorHex = colorHex
      ..attendanceGoal = goal;
    await HiveService.subjects.put(sub.id, sub);
    _load();
  }

  Future<void> editSubject(SubjectModel sub, {
    required String name,
    required String colorHex,
    required int goal,
  }) async {
    if (state.any((s) => s.id != sub.id && s.name.trim().toLowerCase() == name.trim().toLowerCase())) {
      throw Exception('A subject with this name already exists.');
    }
    sub.name = name;
    sub.colorHex = colorHex;
    sub.attendanceGoal = goal;
    await sub.save();
    _load();
  }

  Future<void> deleteSubject(String id) async {
    // Also delete attendance records and timetable entries for this subject
    final attendanceKeys = HiveService.attendance.keys
        .where((k) => HiveService.attendance.get(k)?.subjectId == id)
        .toList();
    await HiveService.attendance.deleteAll(attendanceKeys);

    final ttKeys = HiveService.timetable.keys
        .where((k) => HiveService.timetable.get(k)?.subjectId == id)
        .toList();
    await HiveService.timetable.deleteAll(ttKeys);

    await HiveService.subjects.delete(id);
    _load();
  }

  void refreshSubjects() => _load();
}

final subjectByIdProvider = Provider.family<SubjectModel?, String>((ref, id) {
  final subjects = ref.watch(subjectsProvider);
  try {
    return subjects.firstWhere((s) => s.id == id);
  } catch (_) {
    return null;
  }
});
