import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/ui/app_card.dart';
import '../models/meal.dart';
import '../models/nutrition_enums.dart';

IconData mealTypeIcon(MealType type) => switch (type) {
      MealType.breakfast => Icons.wb_twilight_outlined,
      MealType.lunch => Icons.lunch_dining_outlined,
      MealType.dinner => Icons.dinner_dining_outlined,
      MealType.snack => Icons.cookie_outlined,
    };

/// Fila de una comida del historial del día.
class MealHistoryTile extends StatelessWidget {
  final Meal meal;
  final VoidCallback? onTap;

  const MealHistoryTile({super.key, required this.meal, this.onTap});

  @override
  Widget build(BuildContext context) {
    final time = meal.consumedAt;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(mealTypeIcon(meal.type),
                color: AppColors.accent, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal.name,
                    style: AppTextStyles.titleMd,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  'P ${meal.protein.round()}g · C ${meal.carbs.round()}g · G ${meal.fat.round()}g'
                  '${time != null ? '  ·  ${_hhmm(time)}' : ''}',
                  style: AppTextStyles.label,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text('${meal.calories.round()} kcal', style: AppTextStyles.statSm),
        ],
      ),
    );
  }

  String _hhmm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
