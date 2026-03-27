import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/subject.dart';
import '../models/attendance_record.dart';
import '../models/timetable_entry.dart';

class HiveService {
  static const String subjectsBox = 'subjects';
  static const String attendanceBox = 'attendance';
  static const String timetableBox = 'timetable';
  static const String settingsBox = 'settings';
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    final dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(dir.path);

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SubjectModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(AttendanceRecordAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TimetableEntryAdapter());
    }

    if (!Hive.isBoxOpen(subjectsBox)) {
      await Hive.openBox<SubjectModel>(subjectsBox);
    }
    if (!Hive.isBoxOpen(attendanceBox)) {
      await Hive.openBox<AttendanceRecord>(attendanceBox);
    }
    if (!Hive.isBoxOpen(timetableBox)) {
      await Hive.openBox<TimetableEntry>(timetableBox);
    }
    if (!Hive.isBoxOpen(settingsBox)) {
      await Hive.openBox(settingsBox);
    }

    _initialized = true;
  }

  static Box<SubjectModel> get subjects => Hive.box<SubjectModel>(subjectsBox);
  static Box<AttendanceRecord> get attendance => Hive.box<AttendanceRecord>(attendanceBox);
  static Box<TimetableEntry> get timetable => Hive.box<TimetableEntry>(timetableBox);
  static Box get settings => Hive.box(settingsBox);
}
