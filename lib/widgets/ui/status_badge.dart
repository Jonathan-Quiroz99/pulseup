import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

enum StatusTone { positive, caution, negative, neutral }

/// Non-interactive status pill (membership state, payment state, …). A dot
/// + label on a soft tinted background. Do not use [AppChip] for this.
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusTone tone;

  const StatusBadge({super.key, required this.label, required this.tone});

  /// Maps a raw backend `estado` string to a tone.
  factory StatusBadge.fromEstado(String? estado) {
    final value = (estado ?? '').trim();
    final tone = switch (value.toLowerCase()) {
      'activo' || 'pagado' => StatusTone.positive,
      'pendiente' || 'pendiente confirmacion' => StatusTone.caution,
      'vencido' || 'suspendido' || 'inactivo' || 'cancelado' || 'fallido' =>
        StatusTone.negative,
      _ => StatusTone.neutral,
    };
    return StatusBadge(label: value.isEmpty ? '—' : value, tone: tone);
  }

  ({Color fg, Color bg}) get _colors => switch (tone) {
        StatusTone.positive => (fg: AppColors.success, bg: AppColors.successSoft),
        StatusTone.caution => (fg: AppColors.warning, bg: AppColors.warningSoft),
        StatusTone.negative => (fg: AppColors.error, bg: AppColors.errorSoft),
        StatusTone.neutral => (
            fg: AppColors.textSecondary,
            bg: AppColors.surfaceHigh
          ),
      };

  @override
  Widget build(BuildContext context) {
    final c = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: c.fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.label.copyWith(color: c.fg),
            ),
          ),
        ],
      ),
    );
  }
}
