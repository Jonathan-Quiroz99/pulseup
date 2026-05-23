import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/theme/app_spacing.dart';
import '../../services/api_service.dart';

import '../home/home_screen.dart';
import 'register_screen.dart';
import 'user_session.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  final ApiService _apiService =
      ApiService();

  final GoogleSignIn _googleSignIn =
      GoogleSignIn(
    scopes: ['email'],
  );

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {

    final email =
        _emailController.text.trim();

    final password =
        _passwordController.text.trim();

    if (email.isEmpty ||
        password.isEmpty) {

      _showError(
        'Ingresa correo y contraseña',
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {

      final response =
          await _apiService.memberLogin(
        email,
        password,
      );

      _saveSession(response);

      if (!mounted) return;

      _navigateToHome();

    } catch (e) {

      _showError(
        'Error de login\n$e',
      );

    } finally {

      if (mounted) {

        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _googleLogin() async {

  try {

    setState(() {
      _isLoading = true;
    });

    print('STEP 1');

    await _googleSignIn.signOut();

    print('STEP 2');

    final googleUser =
        await _googleSignIn.signIn();

    print('STEP 3');

    if (googleUser == null) {

      print('GOOGLE USER NULL');
      return;
    }

    print('EMAIL: ${googleUser.email}');

    final googleAuth =
        await googleUser.authentication;

    print('STEP 4');

    print('ACCESS TOKEN: ${googleAuth.accessToken}');
    print('ID TOKEN: ${googleAuth.idToken}');

    final idToken =
        googleAuth.idToken;

    if (idToken == null ||
        idToken.isEmpty) {

      throw Exception(
        'Google no devolvió ID Token',
      );
    }

    print('STEP 5');

    final response =
        await _apiService.googleLogin(
      idToken,
    );

    print('STEP 6');
    print(response);

    _saveSession(response);

    if (!mounted) return;

    _navigateToHome();

  } catch (e, stack) {

    print('GOOGLE LOGIN ERROR');
    print(e);
    print(stack);

    _showError(
      'Google Login Error\n$e',
    );

  } finally {

    if (mounted) {

      setState(() {
        _isLoading = false;
      });
    }
  }
}

  void _navigateToHome() {

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const HomeScreen(),
      ),
    );
  }

  void _saveSession(
    Map<String, dynamic> response,
  ) {

    UserSession.currentUser = {

      'member_id':
          response['member_id'],

      'correo':
          response['correo'],

      'nombre':
          response['nombre'],

      'role':
          response['role'],
    };

    UserSession.token =
        response['token'];
  }

  void _showError(String message) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final textTheme =
        Theme.of(context).textTheme;

    return Scaffold(

      body: SafeArea(

        child: Center(

          child: SingleChildScrollView(

            padding: const EdgeInsets.all(
              AppSpacing.lg,
            ),

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.stretch,

              children: [

                Text(
                  'PulseUp',
                  textAlign: TextAlign.center,
                  style:
                      textTheme.headlineLarge,
                ),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                TextField(
                  controller:
                      _emailController,

                  keyboardType:
                      TextInputType
                          .emailAddress,

                  decoration:
                      const InputDecoration(
                    hintText:
                        'Correo electrónico',

                    prefixIcon: Icon(
                      Icons.email_outlined,
                    ),
                  ),
                ),

                const SizedBox(
                  height: AppSpacing.md,
                ),

                TextField(
                  controller:
                      _passwordController,

                  obscureText:
                      _obscurePassword,

                  decoration:
                      InputDecoration(
                    hintText:
                        'Contraseña',

                    prefixIcon:
                        const Icon(
                      Icons.lock_outline,
                    ),

                    suffixIcon:
                        IconButton(

                      onPressed: () {

                        setState(() {

                          _obscurePassword =
                              !_obscurePassword;
                        });
                      },

                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: AppSpacing.lg,
                ),

                ElevatedButton(

                  onPressed:
                      _isLoading
                          ? null
                          : _login,

                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Iniciar Sesión',
                        ),
                ),

                const SizedBox(
                  height: AppSpacing.md,
                ),

                OutlinedButton.icon(

                  onPressed:
                      _isLoading
                          ? null
                          : _googleLogin,

                  icon: const Icon(
                    Icons.g_mobiledata,
                  ),

                  label: const Text(
                    'Continuar con Google',
                  ),
                ),

                const SizedBox(
                  height: AppSpacing.sm,
                ),

                TextButton(

                  onPressed: () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                             RegisterScreen(),
                      ),
                    );
                  },

                  child: const Text(
                    '¿No tienes cuenta? Regístrate',
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