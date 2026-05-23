import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/constants.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  Future<void> _handleLogin(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final email = emailController.text.trim();
    final password = passwordController.text;
    final url = ApiConfig.loginUri;

    debugPrint('PulseUp login -> POST $url');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'pass': password,
              'password': password,
            }),
          )
          .timeout(ApiConfig.requestTimeout);

      debugPrint('PulseUp login <- statusCode=${response.statusCode}');
      debugPrint('PulseUp login <- body=${response.body}');

      final data = _decodeResponseBody(response.body);

      if (!context.mounted) return;

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
        return;
      }

      messenger.showSnackBar(
        SnackBar(content: Text(_buildErrorMessage(response.statusCode, data))),
      );
    } on TimeoutException catch (error, stackTrace) {
      debugPrint('PulseUp login timeout: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!context.mounted) return;

      messenger.showSnackBar(
        SnackBar(content: Text('Timeout: el backend tardó demasiado en responder.')),
      );
    } on SocketException catch (error, stackTrace) {
      debugPrint('PulseUp login socket error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!context.mounted) return;

      messenger.showSnackBar(
        SnackBar(content: Text('No se pudo conectar con el backend.')),
      );
    } on http.ClientException catch (error, stackTrace) {
      debugPrint('PulseUp login client error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!context.mounted) return;

      messenger.showSnackBar(
        SnackBar(content: Text('Error de red al intentar iniciar sesión.')),
      );
    } on FormatException catch (error, stackTrace) {
      debugPrint('PulseUp login invalid response format: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!context.mounted) return;

      messenger.showSnackBar(
        SnackBar(content: Text('La API respondió con un formato inválido.')),
      );
    } catch (error, stackTrace) {
      debugPrint('PulseUp login unexpected error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!context.mounted) return;

      messenger.showSnackBar(
        SnackBar(content: Text('Ocurrió un error inesperado al iniciar sesión.')),
      );
    }
  }

  Map<String, dynamic> _decodeResponseBody(String responseBody) {
    final decoded = jsonDecode(responseBody);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw const FormatException('Expected a JSON object response.');
  }

  String _buildErrorMessage(int statusCode, Map<String, dynamic> data) {
    final status = data['status']?.toString();
    final message = data['message']?.toString();
    final error = data['error']?.toString();

    if (statusCode == 401 || statusCode == 403) {
      return message ?? error ?? 'Credenciales inválidas.';
    }

    if (status == 'error') {
      return message ?? error ?? 'Login failed: el backend rechazó las credenciales.';
    }

    if (statusCode >= 500) {
      return 'Backend offline o con error interno (HTTP $statusCode).';
    }

    if (statusCode >= 400) {
      return message ?? error ?? 'La API respondió con HTTP $statusCode.';
    }

    return message ?? error ?? 'No fue posible iniciar sesión.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("PulseUp", style: TextStyle(fontSize: 32)),

            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => _handleLogin(context),
              child: Text("Login"),
            )
          ],
        ),
      ),
    );
  }
}
