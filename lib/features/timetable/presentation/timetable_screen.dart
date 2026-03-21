import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/subjects_provider.dart';
import '../../../shared/providers/timetable_provider.dart';
import '../../../shared/models/timetable_entry.dart';
import '../../../shared/models/subject.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

Color hexToColor(String hex) {
  final code = hex.replaceAll('#', '');
  return Color(int.parse('FF$code', radix: 16));
}

class TimetableScreen extends ConsumerWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timetable = ref.watch(timetableProvider);
    final today = DateTime.now().weekday;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Class'),
        onPressed: () => _showEntrySheet(context, ref, null),
      ),
      body: timetable.isEmpty
          ? Center(child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('No classes scheduled', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text('Tap + to schedule your classes', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                ],
              ),
            ))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: List.generate(7, (i) {
                final weekday = i + 1; // 1=Mon...7=Sun
                final entries = timetable.where((e) => e.weekday == weekday).toList();
                if (entries.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          if (weekday == today)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(8)),
                              child: Text(AppConstants.weekdaysFull[i], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            )
                          else
                            Text(AppConstants.weekdaysFull[i], style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    ...entries.map((e) => _TimetableEntryCard(entry: e, onEdit: () => _showEntrySheet(context, ref, e), onDelete: () => ref.read(timetableProvider.notifier).deleteEntry(e.id))),
                    const SizedBox(height: 8),
                  ],
                );
              }),
            ),
    );
  }

  void _showEntrySheet(BuildContext context, WidgetRef ref, TimetableEntry? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TimetableSheet(ref: ref, existing: existing),
    );
  }
}

class _TimetableEntryCard extends ConsumerWidget {
  final TimetableEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TimetableEntryCard({required this.entry, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subject = ref.watch(subjectByIdProvider(entry.subjectId));
    final color = subject != null ? hexToColor(subject.colorHex) : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(width: 4, height: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        title: Text(subject?.name ?? 'Unknown Subject', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${entry.startTime} – ${entry.endTime}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: kAbsent), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}

class _TimetableSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;
  final TimetableEntry? existing;

  const _TimetableSheet({required this.ref, this.existing});

  @override
  ConsumerState<_TimetableSheet> createState() => _TimetableSheetState();
}

class _TimetableSheetState extends ConsumerState<_TimetableSheet> {
  String? _selectedSubjectId;
  late int _weekday;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    _selectedSubjectId = widget.existing?.subjectId;
    _weekday = widget.existing?.weekday ?? DateTime.now().weekday;
    final start = widget.existing?.startTime.split(':') ?? ['09', '00'];
    final end = widget.existing?.endTime.split(':') ?? ['10', '00'];
    _startTime = TimeOfDay(hour: int.parse(start[0]), minute: int.parse(start[1]));
    _endTime = TimeOfDay(hour: int.parse(end[0]), minute: int.parse(end[1]));
  }

  String _fmt(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjects = ref.watch(subjectsProvider);

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
            Text(widget.existing == null ? 'Add Class' : 'Edit Class', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Subject'),
              initialValue: _selectedSubjectId,
              items: subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
              onChanged: (v) => setState(() => _selectedSubjectId = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Day'),
              initialValue: _weekday,
              items: List.generate(7, (i) => DropdownMenuItem(value: i + 1, child: Text(AppConstants.weekdaysFull[i]))),
              onChanged: (v) => setState(() => _weekday = v!),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: InkWell(
                  onTap: () async {
                    final t = await showTimePicker(context: context, initialTime: _startTime);
                    if (t != null) setState(() => _startTime = t);
                  },
                  child: InputDecorator(decoration: const InputDecoration(labelText: 'Start Time'), child: Text(_fmt(_startTime))),
                )),
                const SizedBox(width: 12),
                Expanded(child: InkWell(
                  onTap: () async {
                    final t = await showTimePicker(context: context, initialTime: _endTime);
                    if (t != null) setState(() => _endTime = t);
                  },
                  child: InputDecorator(decoration: const InputDecoration(labelText: 'End Time'), child: Text(_fmt(_endTime))),
                )),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  if (_selectedSubjectId == null) return;
                  if (widget.existing == null) {
                    await ref.read(timetableProvider.notifier).addEntry(subjectId: _selectedSubjectId!, weekday: _weekday, startTime: _fmt(_startTime), endTime: _fmt(_endTime));
                  } else {
                    await ref.read(timetableProvider.notifier).editEntry(widget.existing!, subjectId: _selectedSubjectId!, weekday: _weekday, startTime: _fmt(_startTime), endTime: _fmt(_endTime));
                  }
                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: Text(widget.existing == null ? 'Add Class' : 'Save Changes', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
