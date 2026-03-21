import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/settings_provider.dart';
import '../../../shared/providers/subjects_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/export_service.dart';
import '../../../shared/providers/attendance_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader('Appearance'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Theme'),
                  trailing: DropdownButton<String>(
                    value: settings.themeMode,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'system', child: Text('System')),
                      DropdownMenuItem(value: 'light', child: Text('Light')),
                      DropdownMenuItem(value: 'dark', child: Text('Dark')),
                    ],
                    onChanged: (v) => notifier.setThemeMode(v!),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader('Attendance'),
          Card(
            child: Column(children: [
              ListTile(
                title: const Text('Global Attendance Goal'),
                subtitle: Slider(
                  value: settings.globalGoal.toDouble(),
                  min: 50, max: 100, divisions: 10,
                  label: '${settings.globalGoal}%',
                  activeColor: kPrimary,
                  onChanged: (v) => notifier.setGlobalGoal(v.toInt()),
                ),
                trailing: Text('${settings.globalGoal}%', style: const TextStyle(color: kPrimary, fontWeight: FontWeight.bold)),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          _SectionHeader('Notifications'),
          Card(
            child: SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Reminders 10 min before class'),
              value: settings.notificationsEnabled,
              activeThumbColor: kPrimary,
              onChanged: (v) => notifier.setNotifications(v),
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader('Data'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Export Attendance (Excel)'),
                  leading: const Icon(Icons.file_download_outlined),
                  onTap: () async {
                    final subjects = ref.read(subjectsProvider);
                    final records = ref.read(attendanceProvider);
                    // Show simple snackbar
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generating Excel file...')));
                    await ExportService.exportAttendanceToExcel(subjects, records);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Reset All Data', style: TextStyle(color: kAbsent, fontWeight: FontWeight.bold)),
                  leading: const Icon(Icons.delete_forever_outlined, color: kAbsent),
                  onTap: () => _confirmReset(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: const ListTile(
              title: Text('Version'),
              trailing: Text('1.0.0', style: TextStyle(color: Colors.grey)),
              leading: Icon(Icons.info_outline),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text('This will permanently delete all subjects, attendance records, and timetable entries.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset', style: TextStyle(color: kAbsent)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      ref.read(settingsProvider.notifier).resetAll();
      ref.read(subjectsProvider.notifier).refreshSubjects();
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(title.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1.2)),
    );
  }
}
