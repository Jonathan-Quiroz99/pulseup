import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/ui/status_badge.dart';

/// Thin strip under the app bar: current plan + live membership status.
class DashboardHeader extends StatelessWidget {
  final String? membership;
  final String? status;

  const DashboardHeader({super.key, this.membership, this.status});

  @override
  Widget build(BuildContext context) {
    final plan = (membership ?? '').isEmpty ? 'Sin plan' : 'Plan $membership';

    return Row(
      children: [
        Icon(Icons.workspace_premium_outlined,
            size: 18, color: AppColors.textMuted),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            plan,
            style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
          ),
        ),
        StatusBadge.fromEstado(status),
      ],
    );
  }
}
