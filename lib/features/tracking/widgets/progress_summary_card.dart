import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';

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
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                value,
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                title,
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}