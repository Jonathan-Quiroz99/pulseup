import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/http_helpers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../widgets/ui/app_button.dart';
import '../../widgets/ui/app_text_field.dart';
import '../home/home_screen.dart';
import 'user_session.dart';

/// "¿Primera vez o olvidaste tu contraseña?"
///
/// Sirve para dos casos con el mismo código de 6 dígitos:
/// - Se inscribió en recepción y nunca eligió contraseña: el código le crea su
///   cuenta de la app ligada a su registro (y su membresía).
/// - Olvidó su contraseña: el código le deja poner una nueva.
/// El código lo da recepción (en persona) o llega a su correo.
class AccessCodeScreen extends StatefulWidget {
  final String initialIdentifier;

  const AccessCodeScreen({super.key, this.initialIdentifier = ''});

  @override
  State<AccessCodeScreen> createState() => _AccessCodeScreenState();
}

class _AccessCodeScreenState extends State<AccessCodeScreen> {
  final _api = ApiService();
  late final TextEditingController _identifier;
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _sending = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _identifier = TextEditingController(text: widget.initialIdentifier);
  }

  void _show(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _sendByEmail() async {
    final correo = _identifier.text.trim();
    if (!correo.contains('@')) {
      _show('Para recibirlo por correo escribe tu correo arriba. Si no tienes correo, pide el código en recepción.');
      return;
    }
    setState(() => _sending = true);
    try {
      final message = await _api.requestAccessCodeByEmail(correo);
      if (mounted) _show(message);
    } catch (e) {
      if (mounted) _show(friendlyError(e));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _submit() async {
    final ident = _identifier.text.trim();
    final code = _code.text.trim();
    final password = _password.text;
    if (ident.isEmpty) {
      _show('Escribe tu teléfono o correo');
      return;
    }
    if (code.length != 6) {
      _show('El código tiene 6 dígitos');
      return;
    }
    if (password.length < 6) {
      _show('La contraseña debe tener al menos 6 caracteres');
      return;
    }
    if (password != _confirm.text) {
      _show('Las contraseñas no coinciden');
      return;
    }
    setState(() => _saving = true);
    try {
      final session = await _api.claimAccessCode(
        identificador: ident,
        codigo: code,
        password: password,
      );
      await UserSession.setSession(session);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } catch (e) {
      if (mounted) _show(friendlyError(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _sending || _saving;
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar con código')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenX,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('¿Primera vez o olvidaste tu contraseña?', style: AppTextStyles.titleLg),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Si te inscribiste en recepción, o no recuerdas tu contraseña, '
                'usa un código de 6 dígitos para entrar y elegir tu contraseña.',
                style: AppTextStyles.bodySm,
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Text(
                  '¿Cómo obtengo el código?\n'
                  '• Pídelo en recepción del gimnasio (vale 24 horas).\n'
                  '• O, si registraste un correo, escríbelo abajo y toca '
                  '"Enviarme el código por correo" (vale 30 minutos).',
                  style: AppTextStyles.bodySm,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _identifier,
                label: 'Teléfono o correo',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.person_outline,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'Enviarme el código por correo',
                icon: Icons.mail_outline,
                variant: AppButtonVariant.secondary,
                loading: _sending,
                onPressed: busy ? null : _sendByEmail,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _code,
                label: 'Código de 6 dígitos',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.pin_outlined,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _password,
                label: 'Contraseña nueva',
                obscureText: true,
                prefixIcon: Icons.lock_outline,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _confirm,
                label: 'Confirma la contraseña',
                obscureText: true,
                prefixIcon: Icons.lock_outline,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Entrar',
                loading: _saving,
                onPressed: busy ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _identifier.dispose();
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }
}
