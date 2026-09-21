import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../widgets/ui/app_chip.dart';
import '../models/nutrition_enums.dart';

/// Selector de Desayuno / Comida / Cena / Snack.
class MealTypeSelector extends StatelessWidget {
  final MealType selected;
  final ValueChanged<MealType> onChanged;

  const MealTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final type in MealType.values)
          AppChip(
            label: type.label,
            selected: type == selected,
            onTap: () => onChanged(type),
          ),
      ],
    );
  }
}
