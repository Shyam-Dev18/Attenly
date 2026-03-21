import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/attendance_provider.dart';
import '../providers/settings_provider.dart';
import '../models/subject.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/utils.dart';

Color hexToColor2(String hex) {
  final code = hex.replaceAll('#', '');
  return Color(int.parse('FF$code', radix: 16));
}

class SubjectCard extends ConsumerWidget {
  final SubjectModel subject;
  final VoidCallback? onTap;

  const SubjectCard({super.key, required this.subject, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final color = hexToColor2(subject.colorHex);
    final pct = subject.percentage;
    final goal = subject.attendanceGoal;
    final statusColor = attendanceColor(pct, goal);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 14, backgroundColor: color, child: Text(subject.name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                  const SizedBox(width: 10),
                  Expanded(child: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                    child: Text('${pct.toStringAsFixed(1)}%', style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct / 100,
                  backgroundColor: statusColor.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation(statusColor),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${subject.attendedClasses}/${subject.totalClasses} classes', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  if (subject.isMeetingGoal)
                    Text('Can skip ${subject.canSkip}', style: TextStyle(fontSize: 12, color: kPresent, fontWeight: FontWeight.w600))
                  else
                    Text('Attend ${subject.mustAttend} more', style: TextStyle(fontSize: 12, color: kAbsent, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
