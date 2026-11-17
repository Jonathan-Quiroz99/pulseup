import 'package:flutter/material.dart';

import '../../../core/birthdate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/ui/app_button.dart';
import '../../../widgets/ui/app_text_field.dart';
import '../../home/home_screen.dart';
import '../google_auth_service.dart';
import '../user_session.dart';
import 'models/register_models.dart';
import 'register_step2_screen.dart';
import 'widgets/step_indicator.dart';

class RegisterStep1Screen extends StatefulWidget {
  final RegisterData initialData;

  const RegisterStep1Screen({super.key, required this.initialData});

  @override
  State<RegisterStep1Screen> createState() => _RegisterStep1ScreenState();
}

class _RegisterStep1ScreenState extends State<RegisterStep1Screen> {
  late final TextEditingController _nombreController;
  late final TextEditingController _apellidosController;
  late final TextEditingController _correoController;
  final _telefonoController = TextEditingController();
  final _fechaController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.initialData.nombre);
    _apellidosController = TextEditingController(
      text: widget.initialData.apellidos,
    );
    _correoController = TextEditingController(text: widget.initialData.correo);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _fechaController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final latest = latestBirthdate(now);
    final earliest = earliestBirthdate(now);
    final current = DateTime.tryParse(_fechaController.text.trim());
    final initial =
        (current != null &&
            !current.isAfter(latest) &&
            !current.isBefore(earliest))
        ? current
        : DateTime(now.year - 18, now.month, now.day.clamp(1, 28));
    // Solo se puede elegir una fecha dentro del rango de edad permitido
    // (antes el límite era "hoy" y se podía poner que naciste en 2025).
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: earliest,
      lastDate: latest,
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Fecha de nacimiento',
    );
    if (picked == null) return;

    setState(() => _fechaController.text = formatBirthdate(picked));
  }

  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  void _continue() {
    final nombre = _nombreController.text.trim();
    final apellidos = _apellidosController.text.trim();
    final correo = _correoController.text.trim();
    final telefono = _telefonoController.text.trim();
    final fecha = _fechaController.text.trim();

    if (nombre.isEmpty || apellidos.isEmpty) {
      _showError('Completa nombre y apellidos');
      return;
    }
    // El correo es opcional: sin correo la cuenta queda ligada al teléfono
    // (para socios que no usan correo) y entran con teléfono + contraseña.
    if (correo.isNotEmpty && !_emailRe.hasMatch(correo)) {
      _showError('Ingresa un correo válido');
      return;
    }
    if (telefono.isEmpty ||
        telefono.replaceAll(RegExp(r'\D'), '').length < 10) {
      _showError('Ingresa un teléfono válido (10 dígitos)');
      return;
    }
    final fechaError = birthdateError(fecha);
    if (fechaError != null) {
      _showError(fechaError);
      return;
    }
    if (!widget.initialData.isGoogle && _passwordController.text.length < 6) {
      _showError('La contraseña debe tener mínimo 6 caracteres');
      return;
    }

    final data = RegisterData(
      nombre: nombre,
      apellidos: apellidos,
      correo: correo,
      telefono: telefono,
      fechaNacimiento: fecha,
      password: widget.initialData.isGoogle
          ? null
          : _passwordController.text.trim(),
      isGoogle: widget.initialData.isGoogle,
      googleCredential: widget.initialData.googleCredential,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RegisterStep2Screen(data: data)),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  final _googleAuth = GoogleAuthService();
  bool _googleLoading = false;

  Future<void> _continueWithGoogle() async {
    setState(() => _googleLoading = true);
    try {
      final outcome = await _googleAuth.signInOrRegister();
      if (!mounted || outcome.cancelled) return;

      if (outcome.error != null) {
        _showError(outcome.error!);
        return;
      }

      if (outcome.isSession) {
        // Ya tenía cuenta → iniciar sesión directo.
        await UserSession.setSession({
          ...outcome.session!,
          'picture': outcome.googleUser?.photoUrl,
        });
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
        );
        return;
      }

      // Cuenta nueva → elegir plan (Google ya dio nombre y correo).
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RegisterStep2Screen(data: outcome.needsRegistration!),
        ),
      );
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenX,
            AppSpacing.sm,
            AppSpacing.screenX,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StepIndicator(current: 1, total: 2),
              const SizedBox(height: AppSpacing.xl),
              if (!widget.initialData.isGoogle) ...[
                AppButton(
                  label: 'Continuar con Google',
                  icon: Icons.g_mobiledata,
                  variant: AppButtonVariant.secondary,
                  loading: _googleLoading,
                  onPressed: _continueWithGoogle,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.hairline)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Text(
                        'o con tus datos',
                        style: AppTextStyles.label,
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.hairline)),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              Text('Datos personales', style: AppTextStyles.titleLg),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _nombreController,
                label: 'Nombre',
                autofillHints: const [AutofillHints.givenName],
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _apellidosController,
                label: 'Apellidos',
                autofillHints: const [AutofillHints.familyName],
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _correoController,
                label: widget.initialData.isGoogle
                    ? 'Correo'
                    : 'Correo (opcional)',
                helperText: widget.initialData.isGoogle
                    ? null
                    : 'Si no tienes correo, entrarás con tu teléfono',
                enabled: !widget.initialData.isGoogle,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _telefonoController,
                label: 'Teléfono',
                keyboardType: TextInputType.phone,
                autofillHints: const [AutofillHints.telephoneNumber],
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _fechaController,
                label: 'Fecha de nacimiento',
                hint: 'AAAA-MM-DD',
                readOnly: true,
                onTap: _pickBirthDate,
                prefixIcon: Icons.calendar_today_outlined,
              ),
              if (!widget.initialData.isGoogle) ...[
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  obscureText: true,
                  helperText: 'Mínimo 6 caracteres',
                  autofillHints: const [AutofillHints.newPassword],
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              AppButton(label: 'Continuar', onPressed: _continue),
            ],
          ),
        ),
      ),
    );
  }
}
