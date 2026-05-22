import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class RegisterScreen extends StatefulWidget {

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {

  final _nameController =
      TextEditingController();

  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  final ApiService _apiService =
      ApiService();

  bool _loading = false;

  Future<void> _register() async {

    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {

      _showError('Completa todos los campos');
      return;
    }

    setState(() => _loading = true);

    try {

      await _apiService.registerMember(
        nombre: _nameController.text.trim(),
        correo: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cuenta creada correctamente',
            ),
          ),
        );

        Navigator.pop(context);
      }

    } catch (e) {

      _showError(e.toString());

    } finally {

      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showError(String msg) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Cuenta'),
      ),

      body: Padding(
        padding: EdgeInsets.all(20),

        child: Column(
          children: [

            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre',
              ),
            ),

            SizedBox(height: 16),

            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Correo',
              ),
            ),

            SizedBox(height: 16),

            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
              ),
            ),

            SizedBox(height: 24),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed:
                    _loading ? null : _register,

                child: _loading
                    ? CircularProgressIndicator()
                    : Text('Crear Cuenta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}