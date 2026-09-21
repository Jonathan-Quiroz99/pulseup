import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/ui/app_card.dart';
import '../../../widgets/ui/status_badge.dart';

class MembershipStatusCard extends StatelessWidget {
  final String membership;
  final String status;

  const MembershipStatusCard({
    super.key,
    required this.membership,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: const Icon(Icons.workspace_premium_outlined,
                color: AppColors.accent, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(membership, style: AppTextStyles.titleMd)),
          StatusBadge.fromEstado(status),
        ],
      ),
    );
  }
}
