import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';
import 'timetable_provider.dart';
import 'subjects_provider.dart';

class SettingsState {
  final int globalGoal;
  final bool notificationsEnabled;
  final String themeMode; // 'system' | 'light' | 'dark'

  const SettingsState({
    this.globalGoal = 75,
    this.notificationsEnabled = true,
    this.themeMode = 'system',
  });

  SettingsState copyWith({int? globalGoal, bool? notificationsEnabled, String? themeMode}) {
    return SettingsState(
      globalGoal: globalGoal ?? this.globalGoal,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) => SettingsNotifier(ref));

class SettingsNotifier extends StateNotifier<SettingsState> {
  final Ref _ref;

  SettingsNotifier(this._ref) : super(const SettingsState()) {
    _load();
  }

  void _load() {
    final box = HiveService.settings;
    state = SettingsState(
      globalGoal: box.get(AppConstants.globalGoalKey, defaultValue: AppConstants.defaultGoal),
      notificationsEnabled: box.get(AppConstants.notificationsKey, defaultValue: true),
      themeMode: box.get(AppConstants.themeKey, defaultValue: 'system'),
    );
  }

  Future<void> setGlobalGoal(int goal) async {
    await HiveService.settings.put(AppConstants.globalGoalKey, goal);
    state = state.copyWith(globalGoal: goal);
  }

  Future<void> setNotifications(bool enabled) async {
    await HiveService.settings.put(AppConstants.notificationsKey, enabled);
    state = state.copyWith(notificationsEnabled: enabled);
    
    if (enabled) {
      await NotificationService.requestPermissions();
      final timetable = _ref.read(timetableProvider);
      final subjects = _ref.read(subjectsProvider);
      await NotificationService.scheduleClassReminders(timetable, subjects);
    } else {
      await NotificationService.cancelAll();
    }
  }

  Future<void> setThemeMode(String mode) async {
    await HiveService.settings.put(AppConstants.themeKey, mode);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> resetAll() async {
    await HiveService.subjects.clear();
    await HiveService.attendance.clear();
    await HiveService.timetable.clear();
    _load();
  }
}
