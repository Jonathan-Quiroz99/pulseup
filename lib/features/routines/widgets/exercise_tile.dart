import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

import '../models/workout_exercise.dart';

import 'routine_chip.dart';

class ExerciseTile
    extends StatelessWidget {

  final WorkoutExercise exercise;

  const ExerciseTile({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {

    final textTheme =
        Theme.of(context).textTheme;

    return Card(

      margin: const EdgeInsets.only(
        bottom: AppSpacing.sm,
      ),

      child: Padding(

        padding: const EdgeInsets.all(
          AppSpacing.md,
        ),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(
              exercise.name,
              style:
                  textTheme.titleMedium,
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),

            Wrap(

              spacing: AppSpacing.sm,

              runSpacing:
                  AppSpacing.sm,

              children: [

                RoutineChip(
                  icon: Icons.repeat,
                  text:
                      '${exercise.sets} series',
                ),

                RoutineChip(
                  icon: Icons.numbers,
                  text:
                      '${exercise.reps} reps',
                ),

                RoutineChip(
                  icon: Icons.timer,
                  text:
                      '${exercise.rest}s',
                ),

                RoutineChip(
                  icon:
                      Icons.sports_gymnastics,

                  text:
                      exercise.muscleGroup,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}