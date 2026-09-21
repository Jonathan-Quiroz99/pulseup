import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../services/api_service.dart';
import '../../../widgets/ui/app_button.dart';
import '../../../widgets/ui/app_card.dart';

import '../../home/home_screen.dart';
import 'models/register_models.dart';
import '../user_session.dart';
import 'widgets/step_indicator.dart';

enum _PaymentMethod { efectivo, online }

class RegisterStep2Screen extends StatefulWidget {
  final RegisterData data;

  const RegisterStep2Screen({super.key, required this.data});

  @override
  State<RegisterStep2Screen> createState() => _RegisterStep2ScreenState();
}

class _RegisterStep2ScreenState extends State<RegisterStep2Screen> {
  final ApiService _apiService = ApiService();

  bool _loading = false;
  bool _loadingPlans = true;
  String? _plansError;

  List<Map<String, dynamic>> _plans = [];
  String? _selectedPlan;

  _PaymentMethod _paymentMethod = _PaymentMethod.efectivo;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    try {
      final plans = await _apiService.getPlans();
      if (!mounted) return;
      setState(() {
        _plans = plans;
        _loadingPlans = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _plansError = 'No se pudieron cargar los planes';
        _loadingPlans = false;
      });
    }
  }

  Map<String, dynamic>? get _selectedPlanData {
    if (_selectedPlan == null) return null;
    for (final plan in _plans) {
      if (plan['nombre'] == _selectedPlan) return plan;
    }
    return null;
  }

  Future<void> _finishRegister() async {
    if (_selectedPlan == null) {
      _showError('Selecciona un plan');
      return;
    }

    setState(() => _loading = true);

    try {
      final Map<String, dynamic> response = widget.data.isGoogle
          ? await _apiService.registerGoogleMember(
              credential: widget.data.googleCredential!,
              nombre: widget.data.nombre,
              apellidos: widget.data.apellidos,
              telefono: widget.data.telefono,
              fechaNacimiento: widget.data.fechaNacimiento,
              plan: _selectedPlan!,
            )
          : await _apiService.registerMember(
              nombre: widget.data.nombre,
              apellidos: widget.data.apellidos,
              correo: widget.data.correo,
              telefono: widget.data.telefono,
              fechaNacimiento: widget.data.fechaNacimiento,
              password: widget.data.password!,
              plan: _selectedPlan!,
            );

      await UserSession.setSession(response);

      if (_paymentMethod == _PaymentMethod.online) {
        await _payOnline(response);
      } else {
        if (!mounted) return;
        _goHome(
          message:
              'Cuenta creada. Tu membresía se activará al confirmar tu pago en el gimnasio.',
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _payOnline(Map<String, dynamic> response) async {
    final plan = _selectedPlanData;

    try {
      final initPoint = await _apiService.createPaymentPreference(
        concepto: 'Membresía ${_selectedPlan!}',
        monto: plan?['precio']?.toString() ?? '0',
        email: widget.data.correo,
        memberId: response['member_id'].toString(),
      );

      final opened = await launchUrl(
        Uri.parse(initPoint),
        mode: LaunchMode.externalApplication,
      );
      if (!opened) throw Exception('No se pudo abrir la página de pago');

      if (!mounted) return;
      await _showWaitingForPaymentDialog(response['token'] as String);
    } catch (e) {
      if (!mounted) return;
      _showError('No se pudo iniciar el pago: $e');
      _goHome(
        message:
            'Cuenta creada, pero no se pudo iniciar el pago en línea. Puedes pagar en el gimnasio.',
      );
    }
  }

  Future<void> _showWaitingForPaymentDialog(String token) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmando tu pago'),
        content: const Text(
          'Completa el pago en la ventana que se abrió. Cuando termines, '
          'toca "Ya pagué" para continuar.',
        ),
        actions: [
          AppButton(
            label: 'Ya pagué',
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _checkPaymentAndContinue(token);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _checkPaymentAndContinue(String token) async {
    try {
      final profile = await _apiService.getMemberProfile(token);
      final estado = profile['estado'] as String? ?? 'Pendiente';
      if (!mounted) return;

      if (estado == 'Activo') {
        UserSession.membershipStatus = 'Activo';
        _goHome(message: '¡Pago confirmado! Tu membresía ya está activa.');
      } else {
        _goHome(
          message:
              'Aún no confirmamos tu pago. Puede tardar unos minutos — tu cuenta se activará automáticamente.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      _goHome(
        message:
            'No pudimos verificar tu pago ahora. Tu cuenta se activará automáticamente al confirmarse.',
      );
    }
  }

  void _goHome({String? message}) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 5)),
      );
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Membresía')),
      body: SafeArea(
        child: _loadingPlans
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenX,
                        AppSpacing.sm,
                        AppSpacing.screenX,
                        AppSpacing.lg,
                      ),
                      children: [
                        const StepIndicator(current: 2, total: 2),
                        const SizedBox(height: AppSpacing.xl),
                        Text('Elige tu plan', style: AppTextStyles.titleLg),
                        const SizedBox(height: AppSpacing.md),
                        if (_plansError != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: Text(
                              _plansError!,
                              style: AppTextStyles.bodySm
                                  .copyWith(color: AppColors.error),
                            ),
                          ),
                        for (final plan in _plans) ...[
                          _PlanTile(
                            plan: plan,
                            selected: _selectedPlan == plan['nombre'],
                            onTap: () => setState(
                                () => _selectedPlan = plan['nombre'] as String),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        Text('Método de pago', style: AppTextStyles.titleLg),
                        const SizedBox(height: AppSpacing.md),
                        _PayTile(
                          title: 'Pagar en el gimnasio',
                          subtitle:
                              'Tu cuenta queda pendiente hasta que recepción confirme el pago.',
                          selected: _paymentMethod == _PaymentMethod.efectivo,
                          onTap: () => setState(
                              () => _paymentMethod = _PaymentMethod.efectivo),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _PayTile(
                          title: 'Pagar en línea ahora',
                          subtitle:
                              'Tu membresía se activa automáticamente al confirmarse el pago.',
                          selected: _paymentMethod == _PaymentMethod.online,
                          onTap: () => setState(
                              () => _paymentMethod = _PaymentMethod.online),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenX,
                      AppSpacing.md,
                      AppSpacing.screenX,
                      AppSpacing.lg,
                    ),
                    child: AppButton(
                      label: 'Finalizar registro',
                      loading: _loading,
                      onPressed: _finishRegister,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  final Map<String, dynamic> plan;
  final bool selected;
  final VoidCallback onTap;

  const _PlanTile({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      borderColor: selected ? AppColors.accent : null,
      child: Row(
        children: [
          Icon(
            selected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: selected ? AppColors.accent : AppColors.textMuted,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${plan['nombre']}', style: AppTextStyles.titleMd),
                const SizedBox(height: 2),
                Text('${plan['duracion']}', style: AppTextStyles.bodySm),
              ],
            ),
          ),
          Text('${plan['precio']}', style: AppTextStyles.statSm),
        ],
      ),
    );
  }
}

class _PayTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _PayTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      borderColor: selected ? AppColors.accent : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            selected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: selected ? AppColors.accent : AppColors.textMuted,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMd),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.bodySm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
