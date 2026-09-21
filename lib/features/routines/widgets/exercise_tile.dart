import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/workout_exercise.dart';
import 'routine_chip.dart';

class ExerciseTile extends StatelessWidget {
  final WorkoutExercise exercise;

  const ExerciseTile({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(exercise.name, style: AppTextStyles.titleMd),
          if (exercise.muscleGroup.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(exercise.muscleGroup, style: AppTextStyles.label),
          ],
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              RoutineChip(icon: Icons.repeat, text: '${exercise.sets} series'),
              RoutineChip(icon: Icons.tag, text: '${exercise.reps} reps'),
              RoutineChip(icon: Icons.timer_outlined, text: '${exercise.rest}s'),
            ],
          ),
        ],
      ),
    );
  }
}
