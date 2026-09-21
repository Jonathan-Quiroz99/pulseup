import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/ui/app_card.dart';
import '../models/checkin_record.dart';

class CheckinHistoryTile extends StatelessWidget {
  final CheckinRecord checkin;

  const CheckinHistoryTile({super.key, required this.checkin});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: const Icon(Icons.login, color: AppColors.textSecondary, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(checkin.tipo, style: AppTextStyles.titleMd),
                const SizedBox(height: 2),
                Text(
                  '${checkin.fecha}  ·  ${checkin.hora}'
                  '${checkin.puerta.isNotEmpty ? '  ·  ${checkin.puerta}' : ''}',
                  style: AppTextStyles.label,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
