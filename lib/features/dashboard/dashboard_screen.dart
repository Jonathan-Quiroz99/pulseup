import 'package:flutter/material.dart';

import '../../core/navigation/app_screen.dart';

import '../auth/user_session.dart';

import 'models/dashboard_stats.dart';
import 'models/dashboard_workout.dart';

import 'services/dashboard_service.dart';

import 'widgets/dashboard_header_card.dart';
import 'widgets/dashboard_loading.dart';
import 'widgets/workout_card.dart';
import 'widgets/stats_row.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/challenge_card.dart';

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
  bool loading = false;

  DashboardWorkout? workout;

  DashboardStats? stats;

  int weeklyCheckins = 0;

  @override
  void initState() {
    super.initState();

    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      setState(() {
        loading = true;
      });

      final token =
          UserSession.token;

      if (token == null) return;

      final results =
          await Future.wait([
        DashboardService()
            .fetchWorkout(token),

        DashboardService()
            .fetchStats(token),

        DashboardService()
            .fetchWeeklyCheckins(
              token,
            ),
      ]);

      if (!mounted) return;

      setState(() {
        workout =
            results[0]
                as DashboardWorkout?;

        stats =
            results[1]
                as DashboardStats?;

        weeklyCheckins =
            results[2] as int;
      });
    } catch (e) {
      print(e);
    }

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF0F172A),

      body: loading
          ? const DashboardLoading()

          : SafeArea(
              child:
                  SingleChildScrollView(
                padding:
                    const EdgeInsets.all(
                  16,
                ),

                child: Column(
                  children: [
                    DashboardHeader(
                      name:
                          UserSession
                              .fullName,
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    WorkoutCard(
                      workout: workout,
                      onNavigate:
                          widget.onNavigate,
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    StatsRow(
                      stats: stats,
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    QuickActionsGrid(
                      onNavigate:
                          widget.onNavigate,
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    ChallengeCard(
                      checkins:
                          weeklyCheckins,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}