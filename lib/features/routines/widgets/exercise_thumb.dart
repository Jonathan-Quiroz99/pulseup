import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../exercise_media.dart';

/// Imagen del ejercicio sobre fondo blanco (las ilustraciones son así), o un
/// icono si el ejercicio no tiene imagen.
class ExerciseThumb extends StatelessWidget {
  final String exerciseName;
  final double size;
  final double radius;

  const ExerciseThumb({
    super.key,
    required this.exerciseName,
    this.size = 72,
    this.radius = AppSpacing.radiusSm,
  });

  @override
  Widget build(BuildContext context) {
    final asset = ExerciseMedia.assetFor(exerciseName);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: size,
        height: size,
        color: asset != null ? Colors.white : AppColors.surfaceHigh,
        child: asset != null
            ? Image.asset(
                asset,
                fit: BoxFit.cover,
                cacheWidth: (size * 3).round(),
                errorBuilder: (_, _, _) => _icon(),
              )
            : _icon(),
      ),
    );
  }

  Widget _icon() => Center(
        child: Icon(Icons.fitness_center, color: AppColors.textMuted, size: size * 0.4),
      );
}
