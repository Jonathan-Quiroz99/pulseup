import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/ui/app_card.dart';
import '../models/workout_plan.dart';
import 'exercise_tile.dart';

class RoutineCard extends StatelessWidget {
  final WorkoutPlan routine;

  const RoutineCard({super.key, required this.routine});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(Icons.fitness_center_outlined,
                    color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(routine.name, style: AppTextStyles.titleLg),
                    if (routine.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(routine.description, style: AppTextStyles.bodySm),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (routine.trainer.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Icon(Icons.person_outline,
                    size: 16, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text('Coach ${routine.trainer}', style: AppTextStyles.label),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          ...routine.exercises.map((e) => ExerciseTile(exercise: e)),
        ],
      ),
    );
  }
}
