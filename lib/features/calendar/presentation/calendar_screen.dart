import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart' hide isSameDay;
import '../../../shared/providers/attendance_provider.dart';
import '../../../shared/providers/subjects_provider.dart';
import '../../../shared/models/attendance_record.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/utils.dart';
import 'package:intl/intl.dart';

Color hexToColor(String hex) {
  final code = hex.replaceAll('#', '');
  return Color(int.parse('FF$code', radix: 16));
}

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = dateOnly(DateTime.now());
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final allRecords = ref.watch(attendanceProvider);

    Map<DateTime, List<AttendanceRecord>> grouped = {};
    for (final r in allRecords) {
      final d = dateOnly(r.date);
      grouped[d] = [...(grouped[d] ?? []), r];
    }

    final selectedRecords = _selectedDay != null ? (grouped[dateOnly(_selectedDay!)] ?? []) : <AttendanceRecord>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => _selectedDay != null && isSameDay(day, _selectedDay!),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = dateOnly(selected);
                _focusedDay = focused;
              });
            },
            onPageChanged: (focused) => setState(() => _focusedDay = focused),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(color: kPrimary.withValues(alpha: 0.3), shape: BoxShape.circle),
              selectedDecoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle),
              markerDecoration: const BoxDecoration(color: kPresent, shape: BoxShape.circle),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (ctx, date, events) {
                final records = grouped[dateOnly(date)] ?? [];
                if (records.isEmpty) return null;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: records.take(3).map((r) {
                    Color c;
                    if (r.status == 'present') c = kPresent;
                    else if (r.status == 'absent') c = kAbsent;
                    else c = kCancelled;
                    return Container(width: 5, height: 5, margin: const EdgeInsets.symmetric(horizontal: 1), decoration: BoxDecoration(shape: BoxShape.circle, color: c));
                  }).toList(),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: selectedRecords.isEmpty
                ? Center(child: Text('No records for this day', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: selectedRecords.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final rec = selectedRecords[i];
                      return _DayLogTile(record: rec);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DayLogTile extends ConsumerWidget {
  final AttendanceRecord record;
  const _DayLogTile({required this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subject = ref.watch(subjectByIdProvider(record.subjectId));
    final color = subject != null ? hexToColor(subject.colorHex) : Colors.grey;
    Color statusColor;
    String statusLabel;
    if (record.status == 'present') { statusColor = kPresent; statusLabel = 'Present'; }
    else if (record.status == 'absent') { statusColor = kAbsent; statusLabel = 'Absent'; }
    else { statusColor = kCancelled; statusLabel = 'Cancelled'; }

    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, child: Text((subject?.name ?? '?')[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        title: Text(subject?.name ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Text(statusLabel, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        subtitle: Row(
          children: [
            GestureDetector(onTap: () => _editRecord(context, ref, record, 'present'), child: _EditChip(label: 'P', color: kPresent, active: record.status == 'present')),
            const SizedBox(width: 4),
            GestureDetector(onTap: () => _editRecord(context, ref, record, 'absent'), child: _EditChip(label: 'A', color: kAbsent, active: record.status == 'absent')),
            const SizedBox(width: 4),
            GestureDetector(onTap: () => _editRecord(context, ref, record, 'cancelled'), child: _EditChip(label: 'C', color: kCancelled, active: record.status == 'cancelled')),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () async {
                final confirm = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Delete record?'), actions: [TextButton(onPressed: () => context.pop(false), child: const Text('Cancel')), TextButton(onPressed: () => context.pop(true), child: const Text('Delete', style: TextStyle(color: kAbsent)))]));
                if (confirm == true) ref.read(attendanceProvider.notifier).deleteRecord(record);
              },
              child: _EditChip(label: '🗑', color: kAbsent, active: false),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editRecord(BuildContext context, WidgetRef ref, AttendanceRecord record, String newStatus) async {
    await ref.read(attendanceProvider.notifier).markAttendance(subjectId: record.subjectId, date: record.date, status: newStatus);
  }
}

class _EditChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool active;
  const _EditChip({required this.label, required this.color, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: active ? color.withValues(alpha: 0.2) : Colors.transparent, borderRadius: BorderRadius.circular(6), border: Border.all(color: color.withValues(alpha: 0.4))),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
    );
  }
}
