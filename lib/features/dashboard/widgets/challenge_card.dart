import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/ui/app_card.dart';

class ChallengeCard extends StatelessWidget {
  final int checkins;

  const ChallengeCard({super.key, required this.checkins});

  @override
  Widget build(BuildContext context) {
    final filled = checkins.clamp(0, 7);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$checkins', style: AppTextStyles.stat),
              const SizedBox(width: AppSpacing.sm),
              Text('visitas · últimos 7 días', style: AppTextStyles.bodySm),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              for (var i = 0; i < 7; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: i < filled ? AppColors.accent : AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            filled >= 4
                ? 'Buen ritmo. Sigue así 🔥'
                : 'Cada visita cuenta. Vamos por más.',
            style: AppTextStyles.bodySm,
          ),
        ],
      ),
    );
  }
}
