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

    // Cuando el gimnasio asigna una rutina nueva, la anterior queda
    // "Inactivo": se muestra la actual y el historial va plegado abajo.
    final current = _routines.where((r) => r.isActive).toList();
    final previous = _routines.where((r) => !r.isActive).toList();

    return AppScaffold(
      padding: EdgeInsets.zero,
      child: RefreshIndicator(
        onRefresh: _loadRoutines,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenX,
            AppSpacing.md,
            AppSpacing.screenX,
            AppSpacing.navBarClearance,
          ),
          children: [
            for (final routine in current) ...[
              RoutineCard(routine: routine),
              const SizedBox(height: AppSpacing.md),
            ],
            if (current.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: EmptyState(
                  icon: Icons.fitness_center_outlined,
                  title: 'Sin rutina actual',
                  message: 'Pide a tu entrenador que te asigne una nueva.',
                ),
              ),
            if (previous.isNotEmpty)
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text('Rutinas anteriores (${previous.length})'),
                  children: [
                    for (final routine in previous) ...[
                      RoutineCard(routine: routine),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}