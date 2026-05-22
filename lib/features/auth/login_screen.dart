import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final ApiService _apiService =
      ApiService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  final GoogleSignIn _googleSignIn =
      GoogleSignIn(
    serverClientId:
        '118869026911-7o2emhtca6vqlftlf30do7kcdp6vhqtb.apps.googleusercontent.com',
  );

  Future<void> _login() async {

    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty) {

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
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      _saveSession(response);

      if (mounted) {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const HomeScreen(),
          ),
        );
      }

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

      await _googleSignIn.signOut();

      final GoogleSignInAccount?
          googleUser =
          await _googleSignIn.signIn();

      if (googleUser == null) {

        setState(() {
          _isLoading = false;
        });

        return;
      }

      final GoogleSignInAuthentication
          googleAuth =
          await googleUser.authentication;

      final String? idToken =
          googleAuth.idToken;

      print('GOOGLE ID TOKEN:');
      print(idToken);

      if (idToken == null ||
          idToken.isEmpty) {

        throw Exception(
          'Google no devolvió ID Token',
        );
      }

      final response =
          await _apiService.googleLogin(
        idToken,
      );

      _saveSession(response);

      if (mounted) {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const HomeScreen(),
          ),
        );
      }

    } catch (e) {

      print('GOOGLE LOGIN ERROR: $e');

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
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: SafeArea(

        child: Padding(

          padding:
              const EdgeInsets.all(20),

          child: Column(

            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              const Text(
                'PulseUp',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              TextField(
                controller:
                    emailController,

                keyboardType:
                    TextInputType
                        .emailAddress,

                decoration:
                    InputDecoration(
                  labelText:
                      'Correo electrónico',

                  prefixIcon:
                      const Icon(
                    Icons.email,
                  ),

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller:
                    passwordController,

                obscureText:
                    _obscurePassword,

                decoration:
                    InputDecoration(
                  labelText:
                      'Contraseña',

                  prefixIcon:
                      const Icon(
                    Icons.lock,
                  ),

                  suffixIcon:
                      IconButton(

                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),

                    onPressed: () {

                      setState(() {

                        _obscurePassword =
                            !_obscurePassword;
                      });
                    },
                  ),

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton(

                  onPressed:
                      _isLoading
                          ? null
                          : _login,

                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Iniciar Sesión',
                        ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 50,

                child:
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
              ),

              const SizedBox(height: 12),

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
    );
  }

  @override
  void dispose() {

    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }
}