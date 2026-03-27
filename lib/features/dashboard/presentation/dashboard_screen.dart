import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/providers/subjects_provider.dart';
import '../../../shared/providers/attendance_provider.dart';
import '../../../shared/providers/settings_provider.dart';
import '../../../shared/providers/timetable_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/utils.dart';
import '../../../shared/widgets/subject_card.dart';
import '../../../shared/widgets/attendance_fab.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectsProvider);
    final settings = ref.watch(settingsProvider);
    final attendanceRecords = ref.watch(attendanceProvider);
    final timetable = ref.watch(timetableProvider);
    final today = dateOnly(DateTime.now());
    final currentStatusBySubject = <String, String>{};
    for (final record in attendanceRecords) {
      if (isSameDay(record.date, today)) {
        currentStatusBySubject[record.subjectId] = record.status;
      }
    }

    double overallPct = 0;
    if (subjects.isNotEmpty) {
      overallPct = subjects.fold(0.0, (sum, s) => sum + s.percentage) / subjects.length;
    }

    final color = subjects.isEmpty
        ? Colors.grey
        : attendanceColor(overallPct, settings.globalGoal);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attenly', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26, letterSpacing: -0.5))
            .animate().fade(duration: 500.ms).slideX(begin: -0.1),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      floatingActionButton: AttendanceFab(
        onPressed: () async {
          final scheduledIds = timetable
              .where((entry) => entry.weekday == today.weekday)
              .map((entry) => entry.subjectId)
              .toSet();
          final scheduledSubjects =
              subjects.where((subject) => scheduledIds.contains(subject.id)).toList();

          if (scheduledSubjects.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No classes scheduled for today.')),
            );
            return;
          }

          for (final subject in scheduledSubjects) {
            await ref.read(attendanceProvider.notifier).markAttendance(
              subjectId: subject.id,
              date: today,
              status: 'present',
            );
          }

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Marked ${scheduledSubjects.length} scheduled subject${scheduledSubjects.length == 1 ? '' : 's'} present.',
                ),
              ),
            );
          }
        },
      ),
      body: subjects.isEmpty
          ? _buildOnboarding(context).animate().fade(duration: 500.ms).scale(begin: const Offset(0.95, 0.95))
          : RefreshIndicator(
              onRefresh: () async {
                ref.read(subjectsProvider.notifier).refreshSubjects();
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: _buildOverallCard(context, overallPct, color, subjects.length)
                          .animate().fade(duration: 500.ms, delay: 100.ms).scale(begin: const Offset(0.97, 0.97)),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((ctx, i) {
                        final sub = subjects[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SubjectCard(
                            subject: sub,
                            onTap: () => context.push('/subjects/${sub.id}'),
                            currentStatus: currentStatusBySubject[sub.id],
                            onMarkPresent: () async {
                              await ref.read(attendanceProvider.notifier).markAttendance(
                                subjectId: sub.id,
                                date: today,
                                status: 'present',
                              );
                            },
                            onMarkAbsent: () async {
                              await ref.read(attendanceProvider.notifier).markAttendance(
                                subjectId: sub.id,
                                date: today,
                                status: 'absent',
                              );
                            },
                            onMarkCancelled: () async {
                              await ref.read(attendanceProvider.notifier).markAttendance(
                                subjectId: sub.id,
                                date: today,
                                status: 'cancelled',
                              );
                            },
                          ).animate().fade(duration: 400.ms, delay: (150 + (i * 50)).ms).slideY(begin: 0.1),
                        );
                      }, childCount: subjects.length),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
    );
  }

  Widget _buildOnboarding(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            Text('No subjects yet', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Add your subjects to start tracking attendance', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/subjects'),
              icon: const Icon(Icons.add),
              label: const Text('Add Subject'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOverallCard(BuildContext context, double pct, Color color, int count) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: pct / 100,
                    backgroundColor: color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation(color),
                    strokeWidth: 8,
                  ),
                  Center(
                    child: Text(
                      '${pct.toStringAsFixed(0)}%',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Overall Attendance', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('$count subject${count == 1 ? '' : 's'} tracked', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
