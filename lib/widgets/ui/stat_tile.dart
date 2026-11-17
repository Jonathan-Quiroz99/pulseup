import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_card.dart';

/// The value + label pattern used across dashboard, tracking and check-in.
/// Pass a null [value] to render `--`.
class StatTile extends StatelessWidget {
  final String label;
  final String? value;
  final IconData? icon;
  final bool accentValue;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.accentValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.sm),
          ],
          // Se encoge en vez de cortarse: en tarjetas de un tercio de ancho
          // "84.0 kg" salia como "84.0…" y no se veia la unidad.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value ?? '--',
              maxLines: 1,
              style: accentValue
                  ? AppTextStyles.stat.copyWith(color: AppColors.accent)
                  : AppTextStyles.stat,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.label,
          ),
        ],
      ),
    );
  }
}
