import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared/services/hive_service.dart';
import 'shared/services/notification_service.dart';
import 'shared/providers/timetable_provider.dart';
import 'shared/providers/subjects_provider.dart';
import 'shared/providers/settings_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  await NotificationService.init();

  // *** FIX 3: Schedule notifications at app startup ***
  // Previously notifications were ONLY scheduled when the timetable was edited.
  // On a fresh app launch the notifications would be missing from the OS.
  runApp(
    ProviderScope(
      observers: const [],
      child: _NotificationBootstrapper(child: const AttenlyApp()),
    ),
  );
}

/// Schedules class reminders once the Riverpod container is ready.
class _NotificationBootstrapper extends ConsumerStatefulWidget {
  final Widget child;
  const _NotificationBootstrapper({required this.child});

  @override
  ConsumerState<_NotificationBootstrapper> createState() =>
      _NotificationBootstrapperState();
}

class _NotificationBootstrapperState
    extends ConsumerState<_NotificationBootstrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final settings = ref.read(settingsProvider);
    if (!settings.notificationsEnabled) return;

    final granted = await NotificationService.requestPermissions();
    if (!granted) return;

    final timetable = ref.read(timetableProvider);
    final subjects = ref.read(subjectsProvider);
    await NotificationService.scheduleClassReminders(timetable, subjects);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
