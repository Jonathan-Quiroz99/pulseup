import 'package:flutter/material.dart';

import '../../core/navigation/app_screen.dart';
import '../../core/theme/app_spacing.dart';

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

class DashboardScreen
    extends StatefulWidget {

  final Function(AppScreen)
      onNavigate;

  const DashboardScreen({
    super.key,
    required this.onNavigate,
  });

  @override
  State<DashboardScreen>
      createState() =>
          _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {

  final DashboardService
      _dashboardService =
          DashboardService();

  bool _loading = false;

  DashboardWorkout? _workout;
  DashboardStats? _stats;

  int _weeklyCheckins = 0;

  @override
  void initState() {

    super.initState();

    _loadDashboard();
  }

  Future<void>
      _loadDashboard() async {

    final token =
        UserSession.token;

    if (token == null) return;

    try {

      setState(() {
        _loading = true;
      });

      final results =
          await Future.wait([

        _dashboardService
            .fetchWorkout(token),

        _dashboardService
            .fetchStats(token),

        _dashboardService
            .fetchWeeklyCheckins(
              token,
            ),
      ]);

      if (!mounted) return;

      setState(() {

        _workout =
            results[0]
                as DashboardWorkout?;

        _stats =
            results[1]
                as DashboardStats?;

        _weeklyCheckins =
            results[2] as int;
      });

    } catch (e) {

      debugPrint(
        'Dashboard Error: $e',
      );

    } finally {

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    if (_loading) {
      return const DashboardLoading();
    }

    return SafeArea(

      child: SingleChildScrollView(

        padding: const EdgeInsets.all(
          AppSpacing.md,
        ),

        child: Column(

          children: [

            DashboardHeader(
              name:
                  UserSession.fullName,
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            WorkoutCard(
              workout: _workout,
              onNavigate:
                  widget.onNavigate,
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            StatsRow(
              stats: _stats,
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            QuickActionsGrid(
              onNavigate:
                  widget.onNavigate,
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            ChallengeCard(
              checkins:
                  _weeklyCheckins,
            ),
          ],
        ),
      ),
    );
  }
}