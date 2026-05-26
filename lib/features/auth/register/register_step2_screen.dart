
import 'package:flutter/material.dart';

import '../../../services/api_service.dart';

import '../../home/home_screen.dart';
import 'models/register_models.dart';
import '../user_session.dart';

class RegisterStep2Screen
    extends StatefulWidget {

  final RegisterData data;

  const RegisterStep2Screen({
    super.key,
    required this.data,
  });

  @override
  State<RegisterStep2Screen>
      createState() =>
          _RegisterStep2ScreenState();
}

class _RegisterStep2ScreenState
    extends State<RegisterStep2Screen> {

  final ApiService _apiService =
      ApiService();

  bool _loading = false;

  String? _selectedPlan;

  // Se mantiene para futura lógica
  // de pagos pero NO se envía
  // al backend actualmente.
  String _paymentMethod =
      'Efectivo';

  final List<String> _plans = [

    'Mensual',
    '3 Meses',
    '6 Meses',
    'Anual',
  ];

  Future<void> _finishRegister() async {

    if (_selectedPlan == null) {

      _showError(
        'Selecciona un plan',
      );

      return;
    }

    setState(() {
      _loading = true;
    });

    try {

      // ====================================
      // REGISTRO NORMAL
      // ====================================

      // Por ahora Google queda pendiente.
      // La estructura se mantiene para
      // implementarla después.

      final response =
          await _apiService
              .registerMember(

        nombre:
            widget.data.nombre,

        apellidos:
            widget.data.apellidos,

        correo:
            widget.data.correo,

        telefono:
            widget.data.telefono,

        fechaNacimiento:
            widget.data
                .fechaNacimiento,

        password:
            widget.data.password!,

        membresia:
            _selectedPlan!,
      );

      // ====================================
      // GUARDAR SESIÓN
      // ====================================

      UserSession.setSession(
        response,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(

        context,

        MaterialPageRoute(
          builder: (_) =>
              const HomeScreen(),
        ),

        (_) => false,
      );

    } catch (e) {

      _showError(
        e.toString(),
      );

    } finally {

      if (mounted) {

        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _showError(String msg) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(
        content: Text(msg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Membresía',
        ),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(
              'Selecciona tu plan',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            ..._plans.map(

              (plan) => RadioListTile<String>(

                value: plan,

                groupValue:
                    _selectedPlan,

                title: Text(plan),

                onChanged: (value) {

                  setState(() {

                    _selectedPlan =
                        value;
                  });
                },
              ),
            ),

            const SizedBox(height: 24),

            // ====================================
            // MÉTODO DE PAGO
            // ====================================

            // Se mantiene visualmente
            // pero todavía NO se conecta
            // al backend.

            const Text(
              'Método de pago',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(

              value: _paymentMethod,

              items: const [

                DropdownMenuItem(
                  value: 'Efectivo',
                  child:
                      Text('Efectivo'),
                ),

                DropdownMenuItem(
                  value: 'Tarjeta',
                  child:
                      Text('Tarjeta'),
                ),

                DropdownMenuItem(
                  value: 'MercadoPago',
                  child:
                      Text('MercadoPago'),
                ),
              ],

              onChanged: (value) {

                if (value == null) return;

                setState(() {

                  _paymentMethod =
                      value;
                });
              },
            ),

            const Spacer(),

            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

                onPressed:
                    _loading
                        ? null
                        : _finishRegister,

                child:
                    _loading

                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )

                        : const Text(
                            'Finalizar Registro',
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
