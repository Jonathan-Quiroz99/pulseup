import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/ui/app_card.dart';
import '../services/progress_insights.dart';

/// Meta de peso: de dónde empezaste, dónde vas, cuánto falta y, si la
/// tendencia lo permite, cuándo llegarías.
class GoalCard extends StatelessWidget {
  final GoalProgress? progress;
  final double? goal;
  final double? weeklyRate;
  final VoidCallback onEdit;

  const GoalCard({
    super.key,
    required this.progress,
    required this.goal,
    required this.weeklyRate,
    required this.onEdit,
  });

  static const _months = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto',
      'septiembre', 'octubre', 'noviembre', 'diciembre'];

  @override
  Widget build(BuildContext context) {
    final p = progress;
    if (goal == null || p == null) {
      return AppCard(
        child: Row(
          children: [
            const Icon(Icons.flag_outlined, color: AppColors.accent),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Define tu meta de peso', style: AppTextStyles.titleMd),
                  const SizedBox(height: 2),
                  Text('Te mostraremos tu avance y cuándo podrías llegar.',
                      style: AppTextStyles.bodySm),
                ],
              ),
            ),
            TextButton(onPressed: onEdit, child: const Text('Definir')),
          ],
        ),
      );
    }

    final rate = weeklyRate;
    final String paceText;
    if (p.reached) {
      paceText = '¡Llegaste a tu meta! Define una nueva cuando quieras.';
    } else if (p.eta != null) {
      paceText = 'A tu ritmo (${rate!.abs().toStringAsFixed(2)} kg/semana) llegarías '
          'cerca del ${p.eta!.day} de ${_months[p.eta!.month - 1]}.';
    } else if (rate == null) {
      paceText = 'Registra tu peso cada semana para estimar cuándo llegarás.';
    } else {
      paceText = p.losing
          ? 'Tu tendencia reciente no va a la baja todavía. ¡Ánimo, la constancia gana!'
          : 'Tu tendencia reciente no va al alza todavía. ¡Ánimo, la constancia gana!';
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('META DE PESO',
                  style: AppTextStyles.label.copyWith(color: AppColors.accent, letterSpacing: 1)),
              const Spacer(),
              TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Editar'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                p.reached ? '¡Meta!' : '${p.remaining.toStringAsFixed(1)} kg',
                style: AppTextStyles.stat,
              ),
              const SizedBox(width: AppSpacing.sm),
              if (!p.reached)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(p.losing ? 'por bajar' : 'por subir', style: AppTextStyles.label),
                ),
              const Spacer(),
              Text('${(p.fraction * 100).round()}%',
                  style: AppTextStyles.statSm.copyWith(color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: LinearProgressIndicator(
              value: p.fraction,
              minHeight: 10,
              backgroundColor: AppColors.surfaceHigh,
              color: p.reached ? AppColors.success : AppColors.accent,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Inicio ${p.start.toStringAsFixed(1)}', style: AppTextStyles.label),
              Text('Hoy ${p.current.toStringAsFixed(1)}', style: AppTextStyles.label),
              Text('Meta ${p.goal.toStringAsFixed(1)}', style: AppTextStyles.label),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(paceText, style: AppTextStyles.bodySm),
        ],
      ),
    );
  }
}
