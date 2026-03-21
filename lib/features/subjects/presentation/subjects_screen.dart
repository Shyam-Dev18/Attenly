import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/subjects_provider.dart';
import '../../../shared/models/subject.dart';
import '../../../core/theme/app_theme.dart';

class SubjectsScreen extends ConsumerStatefulWidget {
  const SubjectsScreen({super.key});

  @override
  ConsumerState<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends ConsumerState<SubjectsScreen> {
  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjects', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSubjectSheet(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Add Subject'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
      ),
      body: subjects.isEmpty
          ? Center(child: Text('No subjects. Tap + to add one.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: subjects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final sub = subjects[i];
                return Dismissible(
                  key: Key(sub.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) async {
                    final confirmed = await _confirmDelete(context, sub.name);
                    if (confirmed == true) {
                      await ref.read(subjectsProvider.notifier).deleteSubject(sub.id);
                      return true;
                    }
                    return false;
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: kAbsent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  child: _SubjectListTile(
                    subject: sub,
                    onTap: () => context.push('/subjects/${sub.id}'),
                    onEdit: () => _showSubjectSheet(context, ref, sub),
                  ),
                );
              },
            ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, String name) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Subject?'),
        content: Text('Delete "$name"? All attendance records for this subject will also be removed.'),
        actions: [
          TextButton(onPressed: () => context.pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => context.pop(true),
            child: const Text('Delete', style: TextStyle(color: kAbsent)),
          ),
        ],
      ),
    );
  }
}

class _SubjectListTile extends StatelessWidget {
  final SubjectModel subject;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _SubjectListTile({required this.subject, required this.onTap, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final color = hexToColor(subject.colorHex);
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(backgroundColor: color, child: Text(subject.name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        title: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${subject.percentage.toStringAsFixed(1)}% attended · Target: ${subject.attendanceGoal}%', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: onEdit),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

// ---------- Subject Bottom Sheet ----------
void _showSubjectSheet(BuildContext context, WidgetRef ref, SubjectModel? existing) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SubjectSheet(ref: ref, existing: existing),
  );
}

class _SubjectSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;
  final SubjectModel? existing;

  const _SubjectSheet({required this.ref, this.existing});

  @override
  ConsumerState<_SubjectSheet> createState() => _SubjectSheetState();
}

class _SubjectSheetState extends ConsumerState<_SubjectSheet> {
  late TextEditingController _nameCtrl;
  late String _selectedColor;
  late double _goal;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _selectedColor = widget.existing?.colorHex ?? kSubjectColorHexes[0];
    _goal = (widget.existing?.attendanceGoal ?? 75).toDouble();
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
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            Text(widget.existing == null ? 'Add Subject' : 'Edit Subject', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Subject Name'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            Text('Color', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: kSubjectColorHexes.map((hex) {
                final selected = hex == _selectedColor;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = hex),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: hexToColor(hex),
                      shape: BoxShape.circle,
                      border: selected ? Border.all(color: Colors.white, width: 2) : null,
                      boxShadow: selected ? [BoxShadow(color: hexToColor(hex).withValues(alpha: 0.5), blurRadius: 8)] : null,
                    ),
                    child: selected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Target Attendance', style: theme.textTheme.labelLarge),
                Text('${_goal.toInt()}%', style: TextStyle(color: kPrimary, fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              value: _goal,
              min: 50, max: 100, divisions: 10,
              activeColor: kPrimary,
              onChanged: (v) => setState(() => _goal = v),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  final name = _nameCtrl.text.trim();
                  if (name.isEmpty) return;
                  try {
                    if (widget.existing == null) {
                      await ref.read(subjectsProvider.notifier).addSubject(
                        name: name, colorHex: _selectedColor, goal: _goal.toInt());
                    } else {
                      await ref.read(subjectsProvider.notifier).editSubject(
                        widget.existing!, name: name, colorHex: _selectedColor, goal: _goal.toInt());
                    }
                    if (context.mounted) context.pop();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(e.toString().replaceAll('Exception: ', '')),
                        backgroundColor: kAbsent,
                      ));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: Text(widget.existing == null ? 'Add Subject' : 'Save Changes', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color hexToColor(String hex) {
  final hexCode = hex.replaceAll('#', '');
  return Color(int.parse('FF$hexCode', radix: 16));
}
