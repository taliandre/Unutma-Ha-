import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:threshold/features/calendar/presentation/calendar_screen.dart';
import 'package:threshold/features/checklist/presentation/checklist_screen.dart';
import 'package:threshold/features/dashboard/presentation/dashboard_screen.dart';
import 'package:threshold/features/history/presentation/history_screen.dart';
import 'package:threshold/features/notifications/presentation/notifications_screen.dart';
import 'package:threshold/features/safe_zone/presentation/safe_zone_screen.dart';
import 'package:threshold/features/settings/presentation/settings_screen.dart';
import 'package:threshold/features/theme/presentation/theme_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/checklist',
        builder: (context, state) => const ChecklistScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/theme',
        builder: (context, state) => const ThemeScreen(),
      ),
      GoRoute(
        path: '/safe-zone',
        builder: (context, state) => const SafeZoneScreen(),
      ),
      GoRoute(
        path: '/calendar',
        builder: (context, state) => const CalendarScreen(),
      ),
    ],
    errorBuilder: (context, state) => const _NotFoundScreen(),
  );
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Sayfa bulunamadı')));
  }
}
