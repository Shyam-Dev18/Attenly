import 'package:hive/hive.dart';

part 'attendance_record.g.dart';

@HiveType(typeId: 1)
class AttendanceRecord extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String subjectId;

  @HiveField(2)
  late DateTime date;

  @HiveField(3)
  late String status; // 'present' | 'absent' | 'cancelled'
}
