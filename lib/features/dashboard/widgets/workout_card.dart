import 'package:flutter/material.dart';

import '../../../core/navigation/app_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/ui/app_button.dart';
import '../../../widgets/ui/app_card.dart';
import '../models/dashboard_workout.dart';

/// The dashboard's hero: today's workout. Accent left edge so it reads as
/// the primary call to action on the screen.
class WorkoutCard extends StatelessWidget {
  final DashboardWorkout? workout;
  final Function(AppScreen) onNavigate;

  const WorkoutCard({
    super.key,
    required this.workout,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final workout = this.workout;

    if (workout == null) {
      return AppCard(
        child: Row(
          children: [
            const Icon(Icons.fitness_center_outlined,
                color: AppColors.textMuted, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'No tienes una rutina activa todavía',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: AppColors.accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ENTRENO DE HOY',
                        style: AppTextStyles.label
                            .copyWith(color: AppColors.accent, letterSpacing: 1)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      workout.todayLabel.isNotEmpty ? workout.todayLabel : workout.name,
                      style: AppTextStyles.titleLg,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      [
                        if (workout.todayLabel.isNotEmpty) workout.name,
                        '${workout.todayExercises} ejercicios',
                        if (workout.trainer.isNotEmpty) 'Coach ${workout.trainer}',
                      ].join('  ·  '),
                      style: AppTextStyles.bodySm,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: 'Ver rutina',
                      icon: Icons.arrow_forward,
                      onPressed: () => onNavigate(AppScreen.routines),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
