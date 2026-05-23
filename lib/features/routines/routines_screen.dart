import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

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

    try {

      setState(() {
        _loading = true;
      });

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

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    final textTheme =
        Theme.of(context).textTheme;

    if (_loading) {

      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (_routines.isEmpty) {

      return Center(

        child: Text(
          'No hay rutinas disponibles',
          style:
              textTheme.bodyLarge,
        ),
      );
    }

    return ListView.separated(

      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),

      itemCount: _routines.length,

      separatorBuilder:
          (_, __) => const SizedBox(
        height: AppSpacing.md,
      ),

      itemBuilder: (context, index) {

        return RoutineCard(
          routine:
              _routines[index],
        );
      },
    );
  }
}