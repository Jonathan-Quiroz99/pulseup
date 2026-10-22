import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/ui/app_card.dart';
import '../models/body_measurement.dart';

class MeasurementTile extends StatelessWidget {
  final BodyMeasurement measurement;
  final VoidCallback? onDelete;

  /// Cambio de peso contra la medición anterior (null en la primera).
  final double? weightDelta;

  /// true = el cambio acerca a la meta (verde), false = aleja, null = neutro.
  final bool? deltaIsGood;

  const MeasurementTile({
    super.key,
    required this.measurement,
    this.onDelete,
    this.weightDelta,
    this.deltaIsGood,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(measurement.date, style: AppTextStyles.titleMd),
              ),
              if (weightDelta != null && weightDelta!.abs() >= 0.05)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: Text(
                    '${weightDelta! > 0 ? '+' : '−'}${weightDelta!.abs().toStringAsFixed(1)}',
                    style: AppTextStyles.label.copyWith(
                      color: switch (deltaIsGood) {
                        true => AppColors.success,
                        false => AppColors.warning,
                        null => AppColors.textSecondary,
                      },
                    ),
                  ),
                ),
              Text(
                '${measurement.weightKg.toStringAsFixed(1)} kg',
                style: AppTextStyles.statSm.copyWith(color: AppColors.accent),
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: AppColors.textMuted,
                  visualDensity: VisualDensity.compact,
                  onPressed: onDelete,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if (measurement.bodyFat != null)
                _Chip('Grasa', '${measurement.bodyFat!.toStringAsFixed(1)}%'),
              if (measurement.muscle != null)
                _Chip('Músculo', '${measurement.muscle!.toStringAsFixed(1)}%'),
              if (measurement.waist != null)
                _Chip('Cintura', '${measurement.waist!.toStringAsFixed(1)} cm'),
              if (measurement.chest != null)
                _Chip('Pecho', '${measurement.chest!.toStringAsFixed(1)} cm'),
              if (measurement.arm != null)
                _Chip('Brazo', '${measurement.arm!.toStringAsFixed(1)} cm'),
            ],
          ),
          if (measurement.notes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(measurement.notes, style: AppTextStyles.bodySm),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final String value;

  const _Chip(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text('$label  $value', style: AppTextStyles.label),
    );
  }
}
