import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/workout_exercise.dart';
import 'routine_chip.dart';

class ExerciseTile extends StatelessWidget {
  final WorkoutExercise exercise;

  const ExerciseTile({super.key, required this.exercise});

  /// "10" -> "10 reps"; "20 min" o "30-45 s" ya traen su unidad.
  static String _repsLabel(String reps) =>
      RegExp(r'^[\d\s\-–]+$').hasMatch(reps) ? '$reps reps' : reps;

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
              RoutineChip(icon: Icons.tag, text: _repsLabel(exercise.reps)),
              if (exercise.rest > 0)
                RoutineChip(icon: Icons.timer_outlined, text: '${exercise.rest}s descanso'),
            ],
          ),
          if (exercise.notes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(exercise.notes, style: AppTextStyles.bodySm),
          ],
        ],
      ),
    );
  }
}
