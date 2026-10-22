import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/ui/app_card.dart';
import '../models/workout_exercise.dart';
import '../models/workout_plan.dart';
import 'exercise_tile.dart';

class RoutineCard extends StatelessWidget {
  final WorkoutPlan routine;

  const RoutineCard({super.key, required this.routine});

  /// Agrupa por sesión ("Dia 1 — Torso") respetando el orden del gimnasio.
  /// Las rutinas viejas sin día quedan en un solo grupo sin encabezado.
  static List<MapEntry<String, List<WorkoutExercise>>> _byDay(
      List<WorkoutExercise> exercises) {
    final groups = <String, List<WorkoutExercise>>{};
    for (final e in exercises) {
      groups.putIfAbsent(e.day, () => []).add(e);
    }
    return groups.entries.toList();
  }

  @override
  Widget build(BuildContext context) {
    final days = _byDay(routine.exercises);
    final sessions = days.where((d) => d.key.isNotEmpty).length;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    if (routine.isActive)
                      Text('RUTINA ACTUAL',
                          style: AppTextStyles.label.copyWith(
                              color: AppColors.accent, letterSpacing: 1)),
                    Text(routine.name, style: AppTextStyles.titleLg),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (sessions > 0) '$sessions sesiones',
                        '${routine.exercises.length} ejercicios',
                      ].join('  ·  '),
                      style: AppTextStyles.label,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (routine.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(routine.description, style: AppTextStyles.bodySm),
          ],
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
          for (final day in days) ...[
            if (day.key.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(day.key.toUpperCase(),
                  style: AppTextStyles.label.copyWith(
                      color: AppColors.textSecondary, letterSpacing: 0.8)),
            ] else
              const SizedBox(height: AppSpacing.sm),
            ...day.value.map((e) => ExerciseTile(exercise: e)),
          ],
        ],
      ),
    );
  }
}
