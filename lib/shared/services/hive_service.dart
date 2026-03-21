import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/subject.dart';
import '../models/attendance_record.dart';
import '../models/timetable_entry.dart';
import 'package:flutter/foundation.dart';

class HiveService {
  static const String subjectsBox = 'subjects';
  static const String attendanceBox = 'attendance';
  static const String timetableBox = 'timetable';
  static const String settingsBox = 'settings';

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(dir.path);
    Hive.registerAdapter(SubjectModelAdapter());
    Hive.registerAdapter(AttendanceRecordAdapter());
    Hive.registerAdapter(TimetableEntryAdapter());
    await Hive.openBox<SubjectModel>(subjectsBox);
    await Hive.openBox<AttendanceRecord>(attendanceBox);
    await Hive.openBox<TimetableEntry>(timetableBox);
    await Hive.openBox(settingsBox);
  }

  static Box<SubjectModel> get subjects => Hive.box<SubjectModel>(subjectsBox);
  static Box<AttendanceRecord> get attendance => Hive.box<AttendanceRecord>(attendanceBox);
  static Box<TimetableEntry> get timetable => Hive.box<TimetableEntry>(timetableBox);
  static Box get settings => Hive.box(settingsBox);
}
