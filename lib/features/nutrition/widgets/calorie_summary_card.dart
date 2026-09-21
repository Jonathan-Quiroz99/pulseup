import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/ui/app_card.dart';
import '../models/daily_nutrition.dart';
import 'macro_progress_bar.dart';

/// Tarjeta principal del dashboard: calorías consumidas vs objetivo,
/// calorías restantes y las tres barras de macros.
class CalorieSummaryCard extends StatelessWidget {
  final DailyNutrition daily;

  const CalorieSummaryCard({super.key, required this.daily});

  @override
  Widget build(BuildContext context) {
    final targets = daily.targets;
    final consumed = daily.consumed;
    final hasTarget = targets != null;
    final goal = targets?.calories.toDouble();
    final ratio =
        hasTarget && goal! > 0 ? (consumed.calories / goal).clamp(0.0, 1.0) : 0.0;
    final remaining = daily.remainingCalories;

    return AppCard(
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${consumed.calories.round()}', style: AppTextStyles.stat),
              const SizedBox(width: AppSpacing.xs),
              Text(
                hasTarget
                    ? '/ ${targets.calories} kcal'
                    : 'kcal consumidas',
                style: AppTextStyles.bodySm,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: LinearProgressIndicator(
              value: hasTarget ? ratio : 0,
              minHeight: 8,
              backgroundColor: AppColors.surfaceHigh,
              valueColor: AlwaysStoppedAnimation(
                (remaining != null && remaining < 0)
                    ? AppColors.warning
                    : AppColors.accent,
              ),
            ),
          ),
          if (remaining != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              remaining >= 0
                  ? '${remaining.round()} kcal restantes'
                  : '${remaining.abs().round()} kcal por encima del objetivo',
              style: AppTextStyles.label.copyWith(
                color: remaining >= 0 ? AppColors.accent : AppColors.warning,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          MacroProgressBar(
            label: 'Proteína',
            consumed: consumed.protein,
            target: targets?.protein.toDouble(),
            color: AppColors.tintBlue,
          ),
          const SizedBox(height: AppSpacing.md),
          MacroProgressBar(
            label: 'Carbohidratos',
            consumed: consumed.carbs,
            target: targets?.carbs.toDouble(),
            color: AppColors.tintGreen,
          ),
          const SizedBox(height: AppSpacing.md),
          MacroProgressBar(
            label: 'Grasa',
            consumed: consumed.fat,
            target: targets?.fat.toDouble(),
            color: AppColors.tintViolet,
          ),
        ],
      ),
    );
  }
}
