import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

import '../../services/api_service.dart';
import '../../widgets/ui/app_button.dart';
import '../../widgets/ui/app_card.dart';
import '../../widgets/ui/app_scaffold.dart';
import '../../widgets/ui/empty_state.dart';
import '../../widgets/ui/section_header.dart';
import '../../widgets/ui/status_badge.dart';

import '../auth/user_session.dart';
import '../onboarding/section_guide.dart';

class BillingScreen
    extends StatefulWidget {

  const BillingScreen({
    super.key,
  });

  @override
  State<BillingScreen>
      createState() =>
          _BillingScreenState();
}

class _BillingScreenState
    extends State<BillingScreen> {

  final ApiService _apiService =
      ApiService();

  bool _loading = true;
  bool _paying = false;

  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _plans = [];
  List<Map<String, dynamic>> _payments = [];

  // Mini tutorial del Estado de cuenta.
  final _planKey = GlobalKey();
  final _payKey = GlobalKey();
  final _historyKey = GlobalKey();
  bool _guideChecked = false;

  @override
  void initState() {
    super.initState();
    SectionGuide.attach(this, () => SectionGuide.show(context, _guideSteps()));
    _load();
  }

  @override
  void dispose() {
    SectionGuide.detach(this);
    super.dispose();
  }

  List<GuideStep> _guideSteps() => [
        GuideStep(
          target: _planKey,
          icon: Icons.card_membership_outlined,
          title: 'Tu membresía',
          body: 'Tu plan, su precio, si está activo y cuándo vence.',
        ),
        GuideStep(
          target: _payKey,
          icon: Icons.payments_outlined,
          title: 'Activa tu membresía',
          body: 'Paga en línea para activarla al instante, o paga en el '
              'gimnasio y recepción la confirma.',
        ),
        GuideStep(
          target: _historyKey,
          icon: Icons.receipt_long_outlined,
          title: 'Tus pagos',
          body: 'Aquí quedan todos tus pagos con su fecha y estado.',
        ),
      ];

  Future<void> _load() async {
    final token = UserSession.token;
    if (token == null) return;

    setState(() {
      _loading = true;
    });

    Map<String, dynamic>? profile;
    try {
      profile = await _apiService.getMemberProfile(token);
      // Keep the session in sync with the real backend status — this is
      // the one screen that always re-checks it.
      await UserSession.mergeProfile(profile);
    } catch (e) {
      debugPrint('Billing: profile failed: $e');
    }

    List<Map<String, dynamic>> plans = const [];
    try {
      plans = await _apiService.getPlans();
    } catch (e) {
      debugPrint('Billing: plans failed: $e');
    }

    List<Map<String, dynamic>> payments = const [];
    try {
      payments = await _apiService.getMemberPayments(token);
    } catch (e) {
      debugPrint('Billing: payments failed: $e');
    }

    if (!mounted) return;

    if (profile == null && _profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cargar tu cuenta.')),
      );
    }

    setState(() {
      if (profile != null) _profile = profile;
      _plans = plans;
      _payments = payments;
      _loading = false;
    });
    if (!_guideChecked && _profile != null) {
      _guideChecked = true;
      SectionGuide.showIfFirstTime(context, 'cuenta', _guideSteps);
    }
  }

  Map<String, dynamic>? get _currentPlanData {
    final membresia = _profile?['membresia'] as String?;
    if (membresia == null || membresia.isEmpty) return null;
    for (final plan in _plans) {
      if (plan['nombre'] == membresia) return plan;
    }
    return null;
  }

  Future<void> _payOnline() async {
    final token = UserSession.token;
    final profile = _profile;
    final plan = _currentPlanData;

    if (token == null || profile == null) return;

    if (plan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No tienes un plan asignado todavía. Acércate a recepción para elegir uno.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _paying = true;
    });

    try {
      final initPoint = await _apiService.createPaymentPreference(
        concepto: 'Membresía ${plan['nombre']}',
        monto: plan['precio']?.toString() ?? '0',
        email: UserSession.email ?? '',
        memberId: profile['id']?.toString() ?? UserSession.memberId ?? '',
      );

      final opened = await launchUrl(
        Uri.parse(initPoint),
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        throw Exception('No se pudo abrir la página de pago');
      }

      if (!mounted) return;
      await _showWaitingForPaymentDialog();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo iniciar el pago: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _paying = false;
        });
      }
    }
  }

  Future<void> _showWaitingForPaymentDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirmando tu pago'),
          content: const Text(
            'Completa el pago en la ventana que se abrió. Cuando termines, '
            'toca "Ya pagué" para actualizar tu cuenta.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _load();
              },
              child: const Text('Ya pagué'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final profile = _profile;

    if (profile == null) {
      return EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No se pudo cargar tu cuenta',
        actionLabel: 'Reintentar',
        onAction: _load,
      );
    }

    final estado = (profile['estado'] as String?) ?? 'Pendiente';
    final isActive = estado == 'Activo';
    final membresia = (profile['membresia'] as String?) ?? '';
    final plan = _currentPlanData;
    final fechaFin = profile['fechaFin'] as String?;

    return AppScaffold(
      padding: EdgeInsets.zero,
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          scrollCacheExtent: const ScrollCacheExtent.pixels(3000),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenX,
            AppSpacing.md,
            AppSpacing.screenX,
            AppSpacing.xxl,
          ),
          children: [
            Text('Estado de cuenta', style: AppTextStyles.displayMd),
            const SizedBox(height: AppSpacing.lg),

            AppCard(
              key: _planKey,
              elevated: true,
              borderColor: isActive ? AppColors.success : AppColors.accent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          membresia.isEmpty
                              ? 'Sin membresía asignada'
                              : 'Membresía $membresia',
                          style: AppTextStyles.titleLg,
                        ),
                      ),
                      StatusBadge.fromEstado(estado),
                    ],
                  ),
                  if (plan != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '${plan['precio']}  ·  ${plan['duracion']}',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                  if ((fechaFin ?? '').isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text('Vence: $fechaFin', style: AppTextStyles.label),
                  ],
                ],
              ),
            ),

            if (!isActive) ...[
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tu membresía todavía no está activa',
                        style: AppTextStyles.titleMd),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Paga en línea para activarla al instante, o paga en el '
                      'gimnasio y espera a que recepción la confirme.',
                      style: AppTextStyles.bodySm,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      key: _payKey,
                      label: 'Pagar en línea ahora',
                      loading: _paying,
                      onPressed: _payOnline,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xl),
            SectionHeader(key: _historyKey, title: 'Historial de pagos'),

            if (_payments.isEmpty)
              const EmptyState(
                icon: Icons.payments_outlined,
                title: 'Todavía no tienes pagos registrados',
              )
            else
              ..._payments.map(
                (payment) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(payment['concepto'] as String? ?? '',
                                  style: AppTextStyles.titleMd),
                              const SizedBox(height: 2),
                              Text(
                                '${payment['fecha']}  ·  ${payment['metodo']}',
                                style: AppTextStyles.label,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(payment['monto'] as String? ?? '',
                                style: AppTextStyles.statSm),
                            // Una compra "pagar en el gimnasio" queda Pendiente:
                            // sin esto se veia igual que un pago ya hecho.
                            if ((payment['estado'] as String? ?? 'Pagado') !=
                                'Pagado') ...[
                              const SizedBox(height: AppSpacing.xs),
                              StatusBadge.fromEstado(
                                  payment['estado'] as String?),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
