import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Aviso discreto: las cifras son estimaciones, no información médica exacta.
class NutritionDisclaimer extends StatelessWidget {
  const NutritionDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, size: 14, color: AppColors.textMuted),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'Los valores nutricionales son estimaciones y pueden variar según '
            'los ingredientes, la preparación y el tamaño de las porciones.',
            style: AppTextStyles.label.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
