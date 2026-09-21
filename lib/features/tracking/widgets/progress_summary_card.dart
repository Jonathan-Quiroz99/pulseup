import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/ui/app_card.dart';

/// Wrapped in [Expanded] so it drops straight into a Row of two.
class ProgressSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const ProgressSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.stat,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(title, style: AppTextStyles.label),
          ],
        ),
      ),
    );
  }
}
