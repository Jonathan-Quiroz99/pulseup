import 'package:flutter/material.dart';

import '../../core/http_helpers.dart';
import '../../core/navigation/app_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../widgets/ui/app_button.dart';
import '../../widgets/ui/app_scaffold.dart';
import '../auth/user_session.dart';

/// Lo que ve un socio sin membresía activa al abrir Rutinas, Progreso o
/// Nutrición: por qué está bloqueado y cómo activarlo.
class LockedFeatureScreen extends StatefulWidget {
  final AppScreen screen;
  final VoidCallback onGoToBilling;

  /// Se llama cuando al actualizar resulta que el pago ya se confirmó.
  final VoidCallback onUnlocked;

  const LockedFeatureScreen({
    super.key,
    required this.screen,
    required this.onGoToBilling,
    required this.onUnlocked,
  });

  @override
  State<LockedFeatureScreen> createState() => _LockedFeatureScreenState();
}

class _LockedFeatureScreenState extends State<LockedFeatureScreen> {
  bool _checking = false;

  (IconData, String, String) get _feature => switch (widget.screen) {
        AppScreen.routines => (
            Icons.fitness_center_rounded,
            'Rutinas',
            'tus rutinas con cada ejercicio, series y repeticiones.',
          ),
        AppScreen.tracking => (
            Icons.show_chart_rounded,
            'Progreso',
            'tu peso, medidas, gráficas y fotos de progreso.',
          ),
        _ => (
            Icons.restaurant_rounded,
            'Nutrición',
            'el análisis de tus comidas con IA y tu objetivo diario.',
          ),
      };

  Future<void> _refresh() async {
    final token = UserSession.token;
    if (token == null) return;
    setState(() => _checking = true);
    try {
      await UserSession.mergeProfile(await ApiService().getMemberProfile(token));
      if (!mounted) return;
      if (UserSession.isActiveMember) {
        widget.onUnlocked();
        return;
      }
      _snack('Tu pago todavía no aparece como pagado. Si ya pagaste en '
          'recepción, pide que lo confirmen.');
    } catch (e) {
      if (mounted) _snack(friendlyError(e));
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final (icon, name, includes) = _feature;
    final expired = UserSession.membershipStatus == 'Vencido';

    return AppScaffold(
      padding: EdgeInsets.zero,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenX,
          AppSpacing.xxl,
          AppSpacing.screenX,
          AppSpacing.navBarClearance,
        ),
        children: [
          Center(
            child: SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.hairline),
                    ),
                    child: Icon(icon, size: 48, color: AppColors.textMuted),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent,
                        border: Border.all(color: AppColors.bg, width: 4),
                      ),
                      child: const Icon(Icons.lock_rounded,
                          size: 20, color: AppColors.onAccent),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            expired ? 'Tu membresía venció' : '$name se activa con tu pago',
            style: AppTextStyles.displayMd,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            expired
                ? 'Renueva tu plan para volver a usar $name.'
                : 'Tu solicitud está pendiente. En cuanto tu pago aparezca '
                    'como pagado se desbloquea todo.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.hairline),
            ),
            child: Row(
              children: [
                const Icon(Icons.workspace_premium_outlined,
                    color: AppColors.accent),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text('Incluido en tu plan: $includes',
                      style: AppTextStyles.bodySm),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: expired ? 'Renovar membresía' : 'Ver cómo pagar',
            icon: Icons.receipt_long_rounded,
            onPressed: widget.onGoToBilling,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Ya pagué, actualizar',
            variant: AppButtonVariant.ghost,
            loading: _checking,
            onPressed: _refresh,
          ),
        ],
      ),
    );
  }
}
