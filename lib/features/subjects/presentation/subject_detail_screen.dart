import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../shared/providers/subjects_provider.dart';
import '../../../shared/providers/attendance_provider.dart';
import '../../../shared/models/subject.dart';
import '../../../shared/models/attendance_record.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/utils.dart';

Color _hexColor(String hex) {
  final code = hex.replaceAll('#', '');
  return Color(int.parse('FF$code', radix: 16));
}

class SubjectDetailScreen extends ConsumerStatefulWidget {
  final String subjectId;
  const SubjectDetailScreen({super.key, required this.subjectId});

  @override
  ConsumerState<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends ConsumerState<SubjectDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final subject = ref.watch(subjectByIdProvider(widget.subjectId));
    if (subject == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Subject')),
        body: const Center(child: Text('Subject not found')),
      );
    }

    final allRecords = ref.watch(attendanceBySubjectProvider(widget.subjectId));
    // Sort newest first
    final records = [...allRecords]..sort((a, b) => b.date.compareTo(a.date));
    final color = _hexColor(subject.colorHex);
    final pct = subject.percentage;
    final statusColor = attendanceColor(pct, subject.attendanceGoal);

    return Scaffold(
      appBar: AppBar(
        title: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditSheet(context, ref, subject),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Add Record'),
        onPressed: () => _showAddRecord(context, ref, subject),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _StatsCard(subject: subject, color: color, statusColor: statusColor),
                  const SizedBox(height: 12),
                  _GoalCard(subject: subject, statusColor: statusColor),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Attendance Log', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Text('${records.length} records', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          records.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.history, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text('No records yet. Tap + to add attendance.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final rec = records[i];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: _RecordTile(record: rec, onEdit: (newStatus) async {
                          await ref.read(attendanceProvider.notifier).markAttendance(
                            subjectId: widget.subjectId,
                            date: rec.date,
                            status: newStatus,
                          );
                        }, onDelete: () async {
                          await ref.read(attendanceProvider.notifier).deleteRecord(rec);
                        }),
                      );
                    },
                    childCount: records.length,
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, WidgetRef ref, SubjectModel subject) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditSubjectSheet(ref: ref, subject: subject),
    );
  }

  void _showAddRecord(BuildContext context, WidgetRef ref, SubjectModel subject) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddRecordSheet(ref: ref, subjectId: subject.id),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final SubjectModel subject;
  final Color color;
  final Color statusColor;

  const _StatsCard({required this.subject, required this.color, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 90,
              height: 90,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: subject.totalClasses == 0 ? 0 : subject.percentage / 100,
                    backgroundColor: statusColor.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation(statusColor),
                    strokeWidth: 8,
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${subject.percentage.toStringAsFixed(0)}%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: statusColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatRow(label: 'Attended', value: '${subject.attendedClasses}', color: kPresent),
                  const SizedBox(height: 6),
                  _StatRow(label: 'Total Classes', value: '${subject.totalClasses}', color: Colors.grey),
                  const SizedBox(height: 6),
                  _StatRow(label: 'Target', value: '${subject.attendanceGoal}%', color: kPrimary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  final SubjectModel subject;
  final Color statusColor;
  const _GoalCard({required this.subject, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              subject.isMeetingGoal ? Icons.check_circle_outline : Icons.warning_amber_outlined,
              color: statusColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: subject.isMeetingGoal
                  ? Text.rich(
                      TextSpan(children: [
                        TextSpan(text: 'You can skip ', style: TextStyle(color: Colors.grey.shade700)),
                        TextSpan(text: '${subject.canSkip} more class${subject.canSkip == 1 ? '' : 'es'}', style: const TextStyle(color: kPresent, fontWeight: FontWeight.bold, fontSize: 15)),
                        TextSpan(text: ' and still meet your goal.', style: TextStyle(color: Colors.grey.shade700)),
                      ]),
                    )
                  : Text.rich(
                      TextSpan(children: [
                        TextSpan(text: 'Attend ', style: TextStyle(color: Colors.grey.shade700)),
                        TextSpan(text: '${subject.mustAttend} more class${subject.mustAttend == 1 ? '' : 'es'}', style: const TextStyle(color: kAbsent, fontWeight: FontWeight.bold, fontSize: 15)),
                        TextSpan(text: ' to reach ${subject.attendanceGoal}%.', style: TextStyle(color: Colors.grey.shade700)),
                      ]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  final AttendanceRecord record;
  final ValueChanged<String> onEdit;
  final VoidCallback onDelete;

  const _RecordTile({required this.record, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusLabel;
    IconData statusIcon;
    if (record.status == 'present') {
      statusColor = kPresent; statusLabel = 'Present'; statusIcon = Icons.check_circle;
    } else if (record.status == 'absent') {
      statusColor = kAbsent; statusLabel = 'Absent'; statusIcon = Icons.cancel;
    } else {
      statusColor = kCancelled; statusLabel = 'Cancelled'; statusIcon = Icons.remove_circle;
    }

    return Card(
      child: ListTile(
        leading: Icon(statusIcon, color: statusColor, size: 28),
        title: Text(DateFormat('EEE, d MMM y').format(record.date), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
          child: Text(statusLabel, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
        ),
        isThreeLine: false,
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 18),
          onSelected: (val) {
            if (val == 'delete') {
              onDelete();
            } else {
              onEdit(val);
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'present', child: Text('Mark Present')),
            const PopupMenuItem(value: 'absent', child: Text('Mark Absent')),
            const PopupMenuItem(value: 'cancelled', child: Text('Mark Cancelled')),
            const PopupMenuDivider(),
            const PopupMenuItem(value: 'delete', child: Text('Delete Record', style: TextStyle(color: kAbsent))),
          ],
        ),
      ),
    );
  }
}

// ---- Edit Subject Sheet ----
class _EditSubjectSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;
  final SubjectModel subject;
  const _EditSubjectSheet({required this.ref, required this.subject});

  @override
  ConsumerState<_EditSubjectSheet> createState() => _EditSubjectSheetState();
}

class _EditSubjectSheetState extends ConsumerState<_EditSubjectSheet> {
  late TextEditingController _nameCtrl;
  late String _selectedColor;
  late double _goal;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.subject.name);
    _selectedColor = widget.subject.colorHex;
    _goal = widget.subject.attendanceGoal.toDouble();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Edit Subject', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Subject Name'), textCapitalization: TextCapitalization.words),
            const SizedBox(height: 16),
            Text('Color', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: kSubjectColorHexes.map((hex) {
                final selected = hex == _selectedColor;
                final c = _hexColor(hex);
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = hex),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: selected ? Border.all(color: Colors.white, width: 2) : null, boxShadow: selected ? [BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 8)] : null),
                    child: selected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Text('Target Attendance', style: theme.textTheme.labelLarge),
              const Spacer(),
              Text('${_goal.toInt()}%', style: const TextStyle(color: kPrimary, fontWeight: FontWeight.bold)),
            ]),
            Slider(value: _goal, min: 50, max: 100, divisions: 10, activeColor: kPrimary, onChanged: (v) => setState(() => _goal = v)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  final name = _nameCtrl.text.trim();
                  if (name.isEmpty) return;
                  await ref.read(subjectsProvider.notifier).editSubject(widget.subject, name: name, colorHex: _selectedColor, goal: _goal.toInt());
                  if (context.mounted) context.pop();
                },
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Add Attendance Record Sheet ----
class _AddRecordSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;
  final String subjectId;
  const _AddRecordSheet({required this.ref, required this.subjectId});

  @override
  ConsumerState<_AddRecordSheet> createState() => _AddRecordSheetState();
}

class _AddRecordSheetState extends ConsumerState<_AddRecordSheet> {
  DateTime _selectedDate = dateOnly(DateTime.now());
  String _status = 'present';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Add Attendance Record', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Date picker
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now());
                if (picked != null) setState(() => _selectedDate = dateOnly(picked));
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Date', prefixIcon: Icon(Icons.calendar_today)),
                child: Text(DateFormat('EEE, d MMM y').format(_selectedDate)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Status', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                _StatusChip(label: '✓ Present', status: 'present', color: kPresent, selected: _status == 'present', onTap: () => setState(() => _status = 'present')),
                const SizedBox(width: 8),
                _StatusChip(label: '✗ Absent', status: 'absent', color: kAbsent, selected: _status == 'absent', onTap: () => setState(() => _status = 'absent')),
                const SizedBox(width: 8),
                _StatusChip(label: '— Cancel', status: 'cancelled', color: kCancelled, selected: _status == 'cancelled', onTap: () => setState(() => _status = 'cancelled')),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  await ref.read(attendanceProvider.notifier).markAttendance(subjectId: widget.subjectId, date: _selectedDate, status: _status);
                  if (context.mounted) context.pop();
                },
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('Save Record', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final String status;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _StatusChip({required this.label, required this.status, required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? color : Colors.grey.withValues(alpha: 0.3)),
          ),
          child: Center(child: Text(label, style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.bold : FontWeight.normal, color: selected ? color : Colors.grey))),
        ),
      ),
    );
  }
}
