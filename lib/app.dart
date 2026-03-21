import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/subjects/presentation/subjects_screen.dart';
import 'features/subjects/presentation/subject_detail_screen.dart';
import 'features/attendance/presentation/quick_mark_screen.dart';
import 'features/timetable/presentation/timetable_screen.dart';
import 'features/calendar/presentation/calendar_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'core/theme/app_theme.dart';
import 'shared/providers/settings_provider.dart';

final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (ctx, state) => const SplashScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return _MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (ctx, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/subjects',
              builder: (ctx, state) => const SubjectsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/timetable',
              builder: (ctx, state) => const TimetableScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/calendar',
              builder: (ctx, state) => const CalendarScreen(),
            ),
          ],
        ),
      ],
    ),
    // Detail / overlay screens pushed ON TOP with their own back button
    GoRoute(
      path: '/subjects/:id',
      builder: (ctx, state) => SubjectDetailScreen(subjectId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/quick-mark', builder: (ctx, state) => const QuickMarkScreen()),
    GoRoute(path: '/settings', builder: (ctx, state) => const SettingsScreen()),
  ],
);

class AttenlyApp extends ConsumerWidget {
  const AttenlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    ThemeMode mode;
    switch (settings.themeMode) {
      case 'light': mode = ThemeMode.light; break;
      case 'dark': mode = ThemeMode.dark; break;
      default: mode = ThemeMode.system;
    }
    return MaterialApp.router(
      title: 'Attenly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      routerConfig: _router,
    );
  }
}

class _MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _MainScaffold({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (i) {
          navigationShell.goBranch(
            i,
            initialLocation: i == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Subjects'),
          NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today), label: 'Timetable'),
          NavigationDestination(icon: Icon(Icons.event_outlined), selectedIcon: Icon(Icons.event), label: 'Calendar'),
        ],
      ),
    );
  }
}
