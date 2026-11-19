import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/http_helpers.dart';
import '../../core/server_settings_dialog.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../widgets/ui/app_button.dart';
import '../../widgets/ui/app_text_field.dart';

import '../home/home_screen.dart';
import 'access_code_screen.dart';
import 'google_auth_service.dart';
import 'user_session.dart';

import 'register/register_step1_screen.dart';
import 'register/register_step2_screen.dart';
import 'register/models/register_models.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final ApiService _apiService = ApiService();
  final GoogleAuthService _googleAuth = GoogleAuthService();

  bool _isLoading = false;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Ingresa tu correo o teléfono y tu contraseña');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.memberLogin(email, password);
      await _saveSession(response);
      if (!mounted) return;
      _navigateToHome();
    } catch (e) {
      _showError(friendlyError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _googleLogin() async {
    setState(() => _isLoading = true);
    try {
      final outcome = await _googleAuth.signInOrRegister();
      if (!mounted || outcome.cancelled) return;

      if (outcome.error != null) {
        _showError(outcome.error!);
        return;
      }

      if (outcome.isSession) {
        await _saveSession(outcome.session!, googleUser: outcome.googleUser);
        if (!mounted) return;
        _navigateToHome();
        return;
      }

      // Cuenta nueva: como Google ya nos dio nombre y correo, saltamos el paso
      // de datos personales y vamos directo a elegir plan.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RegisterStep2Screen(data: outcome.needsRegistration!),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  Future<void> _saveSession(
    Map<String, dynamic> response, {
    GoogleSignInAccount? googleUser,
  }) async {
    await UserSession.setSession({
      ...response,
      'picture': googleUser?.photoUrl,
    });

    if (UserSession.profileImage != null && mounted) {
      precacheImage(NetworkImage(UserSession.profileImage!), context);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenX,
              vertical: AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  // Sin texto de "Servidor" en el login: mantener presionado
                  // el logo abre el ajuste para escribir la IP de la PC a
                  // mano, solo por si la app no la encuentra sola.
                  child: GestureDetector(
                    onLongPress: () => showServerSettingsDialog(context),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.accentSoft,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLg,
                        ),
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 72,
                        height: 72,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'PulseUp',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.displayLg,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Tu gimnasio, en tu bolsillo',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySm,
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppTextField(
                  controller: _emailController,
                  // Socios sin correo entran con su teléfono (el backend
                  // distingue por la "@").
                  label: 'Correo o teléfono',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.person_outline,
                  autofillHints: const [
                    AutofillHints.email,
                    AutofillHints.telephoneNumber,
                  ],
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: 'Iniciar sesión',
                  loading: _isLoading,
                  onPressed: _login,
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'Continuar con Google',
                  icon: Icons.g_mobiledata,
                  variant: AppButtonVariant.secondary,
                  onPressed: _isLoading ? null : _googleLogin,
                ),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RegisterStep1Screen(
                                  initialData: RegisterData(
                                    nombre: '',
                                    apellidos: '',
                                    correo: '',
                                    telefono: '',
                                    fechaNacimiento: '',
                                    isGoogle: false,
                                  ),
                                ),
                              ),
                            );
                          },
                    child: const Text('¿No tienes cuenta?  Regístrate'),
                  ),
                ),
                // Tambien sirve a quien se inscribio en recepcion y nunca
                // eligio contrasena (la pantalla lo explica).
                Center(
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AccessCodeScreen(
                                  initialIdentifier: _emailController.text.trim(),
                                ),
                              ),
                            ),
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: AppTextStyles.bodySm,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
