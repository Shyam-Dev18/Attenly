import 'package:hive/hive.dart';

part 'timetable_entry.g.dart';

@HiveType(typeId: 2)
class TimetableEntry extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String subjectId;

  @HiveField(2)
  late int weekday; // 1=Mon...7=Sun (DateTime weekday)

  @HiveField(3)
  late String startTime; // HH:MM

  @HiveField(4)
  late String endTime; // HH:MM
}
