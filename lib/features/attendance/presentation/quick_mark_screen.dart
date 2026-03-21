import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/subjects_provider.dart';
import '../../../shared/providers/attendance_provider.dart';
import '../../../shared/providers/timetable_provider.dart';
import '../../../shared/models/subject.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/utils.dart';
import 'package:intl/intl.dart';

class QuickMarkScreen extends ConsumerStatefulWidget {
  const QuickMarkScreen({super.key});

  @override
  ConsumerState<QuickMarkScreen> createState() => _QuickMarkScreenState();
}

class _QuickMarkScreenState extends ConsumerState<QuickMarkScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = dateOnly(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectsProvider);
    final timetable = ref.watch(timetableProvider);
    final allRecords = ref.watch(attendanceProvider);
    final todayEntries = timetable.where((e) => e.weekday == _selectedDate.weekday).map((e) => e.subjectId).toSet();

    // Show timetable subjects first if any, then rest
    final orderedSubjects = [
      ...subjects.where((s) => todayEntries.contains(s.id)),
      ...subjects.where((s) => !todayEntries.contains(s.id)),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Mark', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: _DateSelector(
            date: _selectedDate,
            onDateChanged: (d) => setState(() => _selectedDate = d),
          ),
        ),
      ),
      body: orderedSubjects.isEmpty
          ? Center(
              child: Text('Add subjects first', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: orderedSubjects.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) {
                      final sub = orderedSubjects[i];
                      final existing = ref.read(attendanceProvider.notifier).recordForSubjectAndDate(sub.id, _selectedDate);
                      return _QuickMarkCard(
                        subject: sub,
                        currentStatus: existing?.status,
                        onMark: (status) {
                          ref.read(attendanceProvider.notifier).markAttendance(
                            subjectId: sub.id,
                            date: _selectedDate,
                            status: status,
                          );
                        },
                      );
                    },
                  ),
                ),
                _MarkAllBar(subjects: orderedSubjects, date: _selectedDate),
              ],
            ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onDateChanged;

  const _DateSelector({required this.date, required this.onDateChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => onDateChanged(date.subtract(const Duration(days: 1))),
          ),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime.now());
              if (picked != null) onDateChanged(dateOnly(picked));
            },
            child: Text(
              DateFormat('EEE, d MMM y').format(date),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: date.isBefore(dateOnly(DateTime.now())) ? () => onDateChanged(date.add(const Duration(days: 1))) : null,
          ),
        ],
      ),
    );
  }
}

class _QuickMarkCard extends StatelessWidget {
  final SubjectModel subject;
  final String? currentStatus;
  final ValueChanged<String> onMark;

  const _QuickMarkCard({required this.subject, this.currentStatus, required this.onMark});

  @override
  Widget build(BuildContext context) {
    final color = hexToColor(subject.colorHex);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 10, backgroundColor: color),
                const SizedBox(width: 8),
                Text(subject.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const Spacer(),
                Text('${subject.percentage.toStringAsFixed(0)}%', style: TextStyle(color: attendanceColor(subject.percentage, subject.attendanceGoal), fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatusButton(label: '✓ Present', status: 'present', activeColor: kPresent, currentStatus: currentStatus, onTap: () => onMark('present')),
                const SizedBox(width: 8),
                _StatusButton(label: '✗ Absent', status: 'absent', activeColor: kAbsent, currentStatus: currentStatus, onTap: () => onMark('absent')),
                const SizedBox(width: 8),
                _StatusButton(label: '— Cancel', status: 'cancelled', activeColor: kCancelled, currentStatus: currentStatus, onTap: () => onMark('cancelled')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final String status;
  final Color activeColor;
  final String? currentStatus;
  final VoidCallback onTap;

  const _StatusButton({required this.label, required this.status, required this.activeColor, this.currentStatus, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = currentStatus == status;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? activeColor.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isActive ? activeColor : Colors.grey.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(label, style: TextStyle(fontSize: 12, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? activeColor : Colors.grey)),
          ),
        ),
      ),
    );
  }
}

class _MarkAllBar extends ConsumerWidget {
  final List<SubjectModel> subjects;
  final DateTime date;

  const _MarkAllBar({required this.subjects, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: ElevatedButton.icon(
        onPressed: () async {
          for (final sub in subjects) {
            await ref.read(attendanceProvider.notifier).markAttendance(subjectId: sub.id, date: date, status: 'present');
          }
        },
        icon: const Icon(Icons.done_all),
        label: const Text('Mark All Present'),
        style: ElevatedButton.styleFrom(
          backgroundColor: kPresent,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

Color hexToColor(String hex) {
  final hexCode = hex.replaceAll('#', '');
  return Color(int.parse('FF$hexCode', radix: 16));
}
