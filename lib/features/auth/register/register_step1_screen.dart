import 'package:flutter/material.dart';

import 'models/register_models.dart';
import 'register_step2_screen.dart';

class RegisterStep1Screen
    extends StatefulWidget {

  final RegisterData initialData;

  const RegisterStep1Screen({
    super.key,
    required this.initialData,
  });

  @override
  State<RegisterStep1Screen>
      createState() =>
          _RegisterStep1ScreenState();
}

class _RegisterStep1ScreenState
    extends State<RegisterStep1Screen> {

  late final TextEditingController
      _nombreController;

  late final TextEditingController
      _apellidosController;

  late final TextEditingController
      _correoController;

  late final TextEditingController
      _telefonoController;

  late final TextEditingController
      _fechaController;

  final _passwordController =
      TextEditingController();

  @override
  void initState() {

    super.initState();

    _nombreController =
        TextEditingController(
      text: widget.initialData.nombre,
    );

    _apellidosController =
        TextEditingController(
      text: widget.initialData.apellidos,
    );

    _correoController =
        TextEditingController(
      text: widget.initialData.correo,
    );

    _telefonoController =
        TextEditingController();

    _fechaController =
        TextEditingController();
  }

  void _continue() {

    if (_nombreController.text.isEmpty ||
        _apellidosController.text.isEmpty ||
        _correoController.text.isEmpty) {

      _showError(
        'Completa los campos',
      );

      return;
    }

    if (!widget.initialData.isGoogle &&
        _passwordController.text.length < 6) {

      _showError(
        'La contraseña debe tener mínimo 6 caracteres',
      );

      return;
    }

    final data = RegisterData(

      nombre:
          _nombreController.text.trim(),

      apellidos:
          _apellidosController.text.trim(),

      correo:
          _correoController.text.trim(),

      telefono:
          _telefonoController.text.trim(),

      fechaNacimiento:
          _fechaController.text.trim(),

      password:
          widget.initialData.isGoogle
              ? null
              : _passwordController.text.trim(),

      isGoogle:
          widget.initialData.isGoogle,

      googleCredential:
          widget.initialData.googleCredential,
    );

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>
            RegisterStep2Screen(
          data: data,
        ),
      ),
    );
  }

  void _showError(String msg) {

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Datos personales',
        ),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(
              controller:
                  _nombreController,
              decoration:
                  const InputDecoration(
                labelText: 'Nombre',
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  _apellidosController,
              decoration:
                  const InputDecoration(
                labelText: 'Apellidos',
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  _correoController,

              enabled:
                  !widget.initialData
                      .isGoogle,

              decoration:
                  const InputDecoration(
                labelText: 'Correo',
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  _telefonoController,
              decoration:
                  const InputDecoration(
                labelText: 'Teléfono',
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  _fechaController,
              decoration:
                  const InputDecoration(
                labelText:
                    'Fecha nacimiento',
              ),
            ),

            if (!widget.initialData.isGoogle)
              ...[

                const SizedBox(height: 16),

                TextField(
                  controller:
                      _passwordController,

                  obscureText: true,

                  decoration:
                      const InputDecoration(
                    labelText:
                        'Contraseña',
                  ),
                ),
              ],

            const Spacer(),

            SizedBox(

              width: double.infinity,

              child: ElevatedButton(
                onPressed: _continue,
                child: const Text(
                  'Continuar',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}