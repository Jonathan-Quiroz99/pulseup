import 'package:flutter/material.dart';

import '../../core/navigation/app_screen.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/ui/app_scaffold.dart';
import '../../widgets/ui/section_header.dart';

import '../auth/user_session.dart';

import 'models/dashboard_stats.dart';
import 'models/dashboard_workout.dart';

import 'services/dashboard_service.dart';

import 'widgets/challenge_card.dart';
import 'widgets/dashboard_header_card.dart';
import 'widgets/dashboard_loading.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/stats_row.dart';
import 'widgets/workout_card.dart';

class DashboardScreen extends StatefulWidget {
  final Function(AppScreen) onNavigate;

  const DashboardScreen({super.key, required this.onNavigate});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _dashboardService = DashboardService();

  // Starts true: the first load runs from initState, where calling
  // setState() synchronously would throw.
  bool _loading = true;

  DashboardWorkout? _workout;
  DashboardStats? _stats;
  int _weeklyCheckins = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  /// Runs [task], returning [fallback] if it throws. Each dashboard card
  /// loads independently — one failing endpoint shouldn't blank the whole
  /// screen. Auth (401) errors are already handled globally by
  /// checkAuthResponse before they reach here.
  Future<T> _guard<T>(Future<T> Function() task, T fallback, String label) async {
    try {
      return await task();
    } catch (e) {
      debugPrint('Dashboard: $label failed: $e');
      return fallback;
    }
  }

  Future<void> _loadDashboard() async {
    final token = UserSession.token;
    if (token == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    if (!_loading) {
      setState(() => _loading = true);
    }

    final results = await Future.wait([
      _guard<DashboardWorkout?>(
          () => _dashboardService.fetchWorkout(token), null, 'workout'),
      _guard<DashboardStats?>(
          () => _dashboardService.fetchStats(token), null, 'stats'),
      _guard<int>(
          () => _dashboardService.fetchWeeklyCheckins(token), 0, 'checkins'),
    ]);

    if (!mounted) return;

    setState(() {
      _workout = results[0] as DashboardWorkout?;
      _stats = results[1] as DashboardStats?;
      _weeklyCheckins = results[2] as int;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppScaffold(padding: EdgeInsets.zero, child: DashboardLoading());
    }

    return AppScaffold(
      padding: EdgeInsets.zero,
      child: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenX,
            AppSpacing.md,
            AppSpacing.screenX,
            AppSpacing.navBarClearance,
          ),
          children: [
            DashboardHeader(
              membership: UserSession.membership,
              status: UserSession.membershipStatus,
            ),
            const SizedBox(height: AppSpacing.lg),
            WorkoutCard(workout: _workout, onNavigate: widget.onNavigate),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader(title: 'Tu progreso'),
            StatsRow(stats: _stats),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader(title: 'Accesos rápidos'),
            QuickActionsGrid(onNavigate: widget.onNavigate),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader(title: 'Actividad'),
            ChallengeCard(checkins: _weeklyCheckins),
          ],
        ),
      ),
    );
  }
}
