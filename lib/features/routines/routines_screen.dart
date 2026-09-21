import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../widgets/ui/app_scaffold.dart';
import '../../widgets/ui/empty_state.dart';

import '../auth/user_session.dart';

import 'models/workout_plan.dart';
import 'services/routines_service.dart';

import 'widgets/routine_card.dart';

class RoutinesScreen
    extends StatefulWidget {

  const RoutinesScreen({
    super.key,
  });

  @override
  State<RoutinesScreen>
      createState() =>
          _RoutinesScreenState();
}

class _RoutinesScreenState
    extends State<RoutinesScreen> {

  final RoutinesService
      _routinesService =
          RoutinesService();

  bool _loading = false;

  List<WorkoutPlan> _routines = [];

  @override
  void initState() {

    super.initState();

    _loadRoutines();
  }

  Future<void>
      _loadRoutines() async {

    final token =
        UserSession.token;

    if (token == null ||
        token.isEmpty) {

      return;
    }

    setState(() {
      _loading = true;
    });

    try {

      final data =
          await _routinesService
              .fetchMyWorkouts(
        token,
      );

      if (!mounted) return;

      setState(() {
        _routines = data;
      });

    } catch (e) {

      debugPrint(
        'Routines Error: $e',
      );

    } finally {

      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_routines.isEmpty) {
      return const AppScaffold(
        padding: EdgeInsets.zero,
        child: EmptyState(
          icon: Icons.fitness_center_outlined,
          title: 'Sin rutinas asignadas',
          message: 'Tu entrenador publicará aquí tu plan de entrenamiento.',
        ),
      );
    }

    return AppScaffold(
      padding: EdgeInsets.zero,
      child: RefreshIndicator(
        onRefresh: _loadRoutines,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenX,
            AppSpacing.md,
            AppSpacing.screenX,
            AppSpacing.navBarClearance,
          ),
          itemCount: _routines.length,
          separatorBuilder: (_, _) =>
              const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) =>
              RoutineCard(routine: _routines[index]),
        ),
      ),
    );
  }
}