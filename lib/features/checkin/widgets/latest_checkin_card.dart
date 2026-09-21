import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/ui/app_card.dart';
import '../models/checkin_record.dart';

class LatestCheckinCard extends StatelessWidget {
  final CheckinRecord checkin;

  const LatestCheckinCard({super.key, required this.checkin});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          const Icon(Icons.history, color: AppColors.textMuted, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Último acceso', style: AppTextStyles.label),
                const SizedBox(height: 2),
                Text(
                  '${checkin.fecha}  ·  ${checkin.hora}',
                  style: AppTextStyles.titleMd,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
