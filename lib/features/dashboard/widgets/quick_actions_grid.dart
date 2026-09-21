import 'package:flutter/material.dart';

import '../../../core/navigation/app_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/ui/app_card.dart';

class QuickActionsGrid extends StatelessWidget {
  final Function(AppScreen) onNavigate;

  const QuickActionsGrid({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.qr_code_2_outlined, 'Check-In', AppScreen.checkin),
      (Icons.fitness_center_outlined, 'Rutinas', AppScreen.routines),
      (Icons.show_chart_outlined, 'Progreso', AppScreen.tracking),
      (Icons.receipt_long_outlined, 'Cuenta', AppScreen.billing),
    ];

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _ActionItem(
              icon: items[i].$1,
              label: items[i].$2,
              onTap: () => onNavigate(items[i].$3),
            ),
          ),
        ],
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        children: [
          Icon(icon, color: AppColors.accent, size: 22),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
