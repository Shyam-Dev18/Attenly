import 'package:hive/hive.dart';

part 'subject.g.dart';

@HiveType(typeId: 0)
class SubjectModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  String colorHex = '#6C63FF';

  @HiveField(3)
  int attendanceGoal = 75;

  @HiveField(4)
  int totalClasses = 0;

  @HiveField(5)
  int attendedClasses = 0;

  // Computed
  double get percentage =>
      totalClasses == 0 ? 100.0 : (attendedClasses / totalClasses) * 100;

  bool get isMeetingGoal => percentage >= attendanceGoal;

  int get canSkip {
    if (totalClasses == 0 || isMeetingGoal == false) return 0;
    final goal = attendanceGoal / 100.0;
    if (goal >= 1.0) return 0;
    final val = ((attendedClasses - goal * totalClasses) / goal).floor();
    return val < 0 ? 0 : val;
  }

  int get mustAttend {
    if (isMeetingGoal) return 0;
    final goal = attendanceGoal / 100.0;
    if (goal >= 1.0) return 0;
    final val = ((goal * totalClasses - attendedClasses) / (1 - goal)).ceil();
    return val < 0 ? 0 : val;
  }
}
