import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

import '../../../widgets/custom_card.dart';

import '../models/workout_plan.dart';

import 'exercise_tile.dart';

class RoutineCard
    extends StatelessWidget {

  final WorkoutPlan routine;

  const RoutineCard({
    super.key,
    required this.routine,
  });

  @override
  Widget build(BuildContext context) {

    final theme =
        Theme.of(context);

    final textTheme =
        theme.textTheme;

    return CustomCard(

      child: Padding(

        padding: const EdgeInsets.all(
          AppSpacing.md,
        ),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Row(

              children: [

                Container(

                  padding: const EdgeInsets.all(
                    AppSpacing.sm,
                  ),

                  decoration: BoxDecoration(

                    color: theme
                        .colorScheme.primary
                        .withOpacity(0.12),

                    borderRadius:
                        BorderRadius.circular(
                      AppSpacing.radiusMd,
                    ),
                  ),

                  child: Icon(
                    Icons.fitness_center,
                    color:
                        theme.colorScheme.primary,
                  ),
                ),

                const SizedBox(
                  width: AppSpacing.sm,
                ),

                Expanded(

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(
                        routine.name,
                        style:
                            textTheme.titleLarge,
                      ),

                      const SizedBox(
                        height: AppSpacing.xs,
                      ),

                      Text(
                        routine.description,
                        style:
                            textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            Row(

              children: [

                Icon(
                  Icons.person,
                  size: 18,
                  color:
                      theme.colorScheme.onSurface
                          .withOpacity(0.6),
                ),

                const SizedBox(
                  width: AppSpacing.xs,
                ),

                Text(
                  'Coach: ${routine.trainer}',
                  style:
                      textTheme.bodyMedium,
                ),
              ],
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            ...routine.exercises.map(

              (exercise) {

                return ExerciseTile(
                  exercise: exercise,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}