import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/ui/app_bottom_sheet.dart';
import '../models/workout_exercise.dart';
import 'exercise_thumb.dart';
import 'routine_chip.dart';

/// Fila de un ejercicio: imagen a la izquierda, nombre, músculo y series. Al
/// tocarla abre la ficha con la imagen grande y las indicaciones.
class ExerciseTile extends StatelessWidget {
  final WorkoutExercise exercise;
  final int? number;

  const ExerciseTile({super.key, required this.exercise, this.number});

  /// "10" -> "10 reps"; "20 min" o "30-45 s" ya traen su unidad.
  static String repsLabel(String reps) =>
      RegExp(r'^[\d\s\-–]+$').hasMatch(reps) ? '$reps reps' : reps;

  static String setsLabel(WorkoutExercise e) =>
      e.sets <= 1 ? repsLabel(e.reps) : '${e.sets} × ${repsLabel(e.reps)}';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: () => showExerciseDetail(context, exercise),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Row(
            children: [
              ExerciseThumb(exerciseName: exercise.name, size: 76),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      number != null ? '$number. ${exercise.name}' : exercise.name,
                      style: AppTextStyles.titleMd,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (exercise.muscleGroup.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(exercise.muscleGroup, style: AppTextStyles.label),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      [
                        setsLabel(exercise),
                        if (exercise.rest > 0) '${exercise.rest} s descanso',
                      ].join('  ·  '),
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.accent),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

void showExerciseDetail(BuildContext context, WorkoutExercise e) {
  showAppBottomSheet<void>(
    context: context,
    title: e.name,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, c) => ExerciseThumb(
            exerciseName: e.name,
            size: c.maxWidth,
            radius: AppSpacing.radiusMd,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            if (e.sets > 1) RoutineChip(icon: Icons.repeat, text: '${e.sets} series'),
            RoutineChip(icon: Icons.tag, text: ExerciseTile.repsLabel(e.reps)),
            if (e.rest > 0) RoutineChip(icon: Icons.timer_outlined, text: '${e.rest} s de descanso'),
            if (e.muscleGroup.isNotEmpty)
              RoutineChip(icon: Icons.accessibility_new, text: e.muscleGroup),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          e.sets > 1
              ? 'Haz ${e.sets} series de ${ExerciseTile.repsLabel(e.reps)}'
                  '${e.rest > 0 ? ' y descansa ${e.rest} segundos entre cada serie' : ''}.'
              : 'Haz ${ExerciseTile.repsLabel(e.reps)}.',
          style: AppTextStyles.body,
        ),
        if (e.notes.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Text('Indicación: ${e.notes}', style: AppTextStyles.bodySm),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Text(
          'Las zonas en naranja son los músculos que trabaja este ejercicio.',
          style: AppTextStyles.label,
        ),
      ],
    ),
  );
}
