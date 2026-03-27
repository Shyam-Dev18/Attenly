import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/utils.dart';

Color hexToColor2(String hex) {
  final code = hex.replaceAll('#', '');
  return Color(int.parse('FF$code', radix: 16));
}

class SubjectCard extends StatelessWidget {
  final SubjectModel subject;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onMarkPresent;
  final VoidCallback? onMarkAbsent;
  final VoidCallback? onMarkCancelled;
  final String? currentStatus;

  const SubjectCard({
    super.key,
    required this.subject,
    this.onTap,
    this.onEdit,
    this.onMarkPresent,
    this.onMarkAbsent,
    this.onMarkCancelled,
    this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    final color = hexToColor2(subject.colorHex);
    final pct = subject.percentage;
    final goal = subject.attendanceGoal;
    final statusColor = attendanceColor(pct, goal);
    final showQuickActions =
        onMarkPresent != null && onMarkAbsent != null && onMarkCancelled != null;

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
                  if (showQuickActions) ...[
                    _QuickActionCircle(
                      icon: Icons.check,
                      semanticLabel: 'Mark ${subject.name} present',
                      color: kPresent,
                      isActive: currentStatus == 'present',
                      onTap: onMarkPresent!,
                    ),
                    const SizedBox(width: 6),
                    _QuickActionCircle(
                      icon: Icons.close,
                      semanticLabel: 'Mark ${subject.name} absent',
                      color: kAbsent,
                      isActive: currentStatus == 'absent',
                      onTap: onMarkAbsent!,
                    ),
                    const SizedBox(width: 6),
                    _QuickActionCircle(
                      icon: Icons.remove,
                      semanticLabel: 'Mark ${subject.name} cancelled',
                      color: kCancelled,
                      isActive: currentStatus == 'cancelled',
                      onTap: onMarkCancelled!,
                    ),
                  ] else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${pct.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
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
                  Text(
                    '${subject.attendedClasses}/${subject.totalClasses} classes • ${pct.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (subject.isMeetingGoal)
                        Text('Can skip ${subject.canSkip}', style: TextStyle(fontSize: 12, color: kPresent, fontWeight: FontWeight.w600))
                      else
                        Text('Attend ${subject.mustAttend} more', style: TextStyle(fontSize: 12, color: kAbsent, fontWeight: FontWeight.w600)),
                      if (onEdit != null) ...[
                        const SizedBox(width: 8),
                        InkResponse(
                          onTap: onEdit,
                          radius: 18,
                          child: const Icon(Icons.edit_outlined, size: 18),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCircle extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _QuickActionCircle({
    required this.icon,
    required this.semanticLabel,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        containedInkWell: true,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? color.withValues(alpha: 0.2) : Colors.transparent,
            border: Border.all(color: isActive ? color : color.withValues(alpha: 0.5)),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}
