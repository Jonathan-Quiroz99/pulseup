import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/ui/app_button.dart';
import '../../../widgets/ui/app_card.dart';
import '../models/body_composition.dart';

/// Resultado del análisis de composición corporal (foto + medidas).
///
/// Muestra el estimado como RANGO y explica de dónde sale cada número: el
/// usuario debe ver que es una estimación y por qué, no un "dato exacto".
/// Devuelve `true` si el usuario pidió guardarlo en sus medidas.
class BodyCompositionSheet extends StatelessWidget {
  final BodyComposition result;

  /// Fecha de las medidas usadas (p. ej. "14 nov"), para que se entienda de
  /// qué día son el peso y la cintura.
  final String measurementLabel;

  /// Solo se ofrece guardar si las medidas son recientes (ver tracking_screen).
  final bool canSave;

  const BodyCompositionSheet({
    super.key,
    required this.result,
    required this.measurementLabel,
    required this.canSave,
  });

  String _n(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final r = result;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenX, AppSpacing.lg, AppSpacing.screenX, AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tu composición corporal', style: AppTextStyles.titleLg),
            const SizedBox(height: AppSpacing.xs),
            Text('Estimado con tu foto y tus medidas del $measurementLabel',
                style: AppTextStyles.bodySm),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _BigStat(
                    label: 'Grasa corporal',
                    value: '${_n(r.bodyFatPct)} %',
                    detail: 'entre ${_n(r.bodyFatLow)} y ${_n(r.bodyFatHigh)} %',
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _BigStat(
                    label: 'Músculo',
                    value: '${_n(r.musclePct)} %',
                    detail: 'del peso corporal',
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SmallStat('Masa magra', '${_n(r.leanMassKg)} kg'),
                  _SmallStat('Masa grasa', '${_n(r.fatMassKg)} kg'),
                  _SmallStat('IMC', _n(r.bmi)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('¿De dónde sale?', style: AppTextStyles.titleMd),
            const SizedBox(height: AppSpacing.sm),
            _SourceRow(
              icon: Icons.straighten,
              title: r.formulaMethod == 'cintura'
                  ? 'Tus medidas (cintura y altura)'
                  : 'Tu peso, altura y edad',
              value: '${_n(r.formulaBodyFatPct)} %',
              used: true,
            ),
            _SourceRow(
              icon: Icons.photo_camera_outlined,
              title: 'La foto (IA)',
              value: r.photoBodyFatPct == null ? '—' : '${_n(r.photoBodyFatPct!)} %',
              used: r.photoUsed,
            ),
            if (r.photoCues.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 32, bottom: AppSpacing.sm),
                child: Text('La IA vio: ${r.photoCues}', style: AppTextStyles.bodySm),
              ),
            for (final w in r.warnings)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppColors.textMuted),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(w, style: AppTextStyles.bodySm)),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Es una estimación: ninguna foto ni cinta métrica da un valor exacto '
              '(para eso se necesita un estudio como DEXA). Sirve para ver tu '
              'tendencia: compárate siempre con fotos parecidas (misma luz y pose).',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (canSave)
              AppButton(
                label: 'Guardar en mis medidas',
                icon: Icons.save_outlined,
                expanded: true,
                onPressed: () => Navigator.pop(context, true),
              )
            else
              Text(
                'Para guardarlo en tu historial, registra primero tu peso de hoy.',
                style: AppTextStyles.bodySm,
              ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: 'Cerrar',
              variant: AppButtonVariant.ghost,
              expanded: true,
              onPressed: () => Navigator.pop(context, false),
            ),
          ],
        ),
      ),
    );
  }
}

class _BigStat extends StatelessWidget {
  final String label;
  final String value;
  final String detail;
  final Color color;

  const _BigStat({
    required this.label,
    required this.value,
    required this.detail,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      elevated: true,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: AppTextStyles.stat.copyWith(color: color)),
          Text(detail, style: AppTextStyles.bodySm),
        ],
      ),
    );
  }
}

class _SmallStat extends StatelessWidget {
  final String label;
  final String value;

  const _SmallStat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.statSm),
        Text(label, style: AppTextStyles.bodySm),
      ],
    );
  }
}

class _SourceRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool used;

  const _SourceRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.used,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 20, color: used ? AppColors.textSecondary : AppColors.textMuted),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(title, style: AppTextStyles.body)),
          Text(value, style: AppTextStyles.body),
          const SizedBox(width: AppSpacing.sm),
          Text(
            used ? 'usado' : 'no usado',
            style: AppTextStyles.bodySm.copyWith(
                color: used ? AppColors.success : AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
