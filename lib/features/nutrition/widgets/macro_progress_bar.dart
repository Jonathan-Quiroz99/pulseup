import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Barra compacta "consumido / objetivo" para un macronutriente.
class MacroProgressBar extends StatelessWidget {
  final String label;
  final double consumed;
  final double? target;
  final String unit;
  final Color color;

  const MacroProgressBar({
    super.key,
    required this.label,
    required this.consumed,
    required this.target,
    this.unit = 'g',
    this.color = AppColors.accent,
  });

  @override
  Widget build(BuildContext context) {
    final hasTarget = target != null && target! > 0;
    final ratio = hasTarget ? (consumed / target!).clamp(0.0, 1.0) : 0.0;
    final over = hasTarget && consumed > target!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: AppTextStyles.label)),
            Text(
              hasTarget
                  ? '${consumed.round()} / ${target!.round()} $unit'
                  : '${consumed.round()} $unit',
              style: AppTextStyles.label.copyWith(
                color: over ? AppColors.warning : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          child: LinearProgressIndicator(
            value: hasTarget ? ratio : 0,
            minHeight: 6,
            backgroundColor: AppColors.surfaceHigh,
            valueColor: AlwaysStoppedAnimation(over ? AppColors.warning : color),
          ),
        ),
      ],
    );
  }
}
