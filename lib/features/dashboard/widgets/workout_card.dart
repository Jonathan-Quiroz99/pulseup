import 'package:flutter/material.dart';

import '../../../core/navigation/app_screen.dart';
import '../../../core/theme/app_spacing.dart';

import '../models/dashboard_workout.dart';

class WorkoutCard
    extends StatelessWidget {

  final DashboardWorkout? workout;

  final Function(AppScreen)
      onNavigate;

  const WorkoutCard({
    super.key,
    required this.workout,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {

    final theme =
        Theme.of(context);

    final textTheme =
        theme.textTheme;

    if (workout == null) {

      return Card(

        child: Padding(

          padding: const EdgeInsets.all(
            AppSpacing.lg,
          ),

          child: Text(
            'No hay rutina activa',
            style:
                textTheme.bodyLarge,
          ),
        ),
      );
    }

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),

      decoration: BoxDecoration(

        gradient: LinearGradient(

          colors: [

            theme.colorScheme.primary,

            theme.colorScheme.secondary,
          ],
        ),

        borderRadius:
            BorderRadius.circular(
          AppSpacing.radiusLg,
        ),
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(
            'Entrenamiento Actual',

            style:
                textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
            ),
          ),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          Text(
            workout!.name,

            style: textTheme.headlineMedium
                ?.copyWith(
              color: Colors.black,
            ),
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          Text(
            '${workout!.exercises} ejercicios',

            style:
                textTheme.bodyLarge?.copyWith(
              color: Colors.black87,
            ),
          ),

          const SizedBox(
            height: AppSpacing.xs,
          ),

          Text(
            'Coach ${workout!.trainer}',

            style:
                textTheme.bodyMedium?.copyWith(
              color: Colors.black87,
            ),
          ),

          const SizedBox(
            height: AppSpacing.lg,
          ),

          ElevatedButton(

            onPressed: () {

              onNavigate(
                AppScreen.routines,
              );
            },

            style:
                ElevatedButton.styleFrom(

              backgroundColor:
                  Colors.black,

              foregroundColor:
                  theme.colorScheme.primary,
            ),

            child: const Text(
              'Ver rutina',
            ),
          ),
        ],
      ),
    );
  }
}