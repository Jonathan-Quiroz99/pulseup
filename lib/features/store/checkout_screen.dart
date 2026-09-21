import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/api_service.dart';
import '../auth/user_session.dart';
import 'controllers/cart_controller.dart';
import 'services/cart_service.dart';

enum _PaymentMethod { efectivo, online }

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _service = CartService();
  final _apiService = ApiService();

  bool _processing = false;
  _PaymentMethod _paymentMethod = _PaymentMethod.efectivo;

  Future<void> _pay() async {
    if (_paymentMethod == _PaymentMethod.efectivo) {
      await _payCash();
    } else {
      await _payOnline();
    }
  }

  /// Reserves the items (stock is deducted right away) and records the
  /// sale as "Pendiente" — staff collects payment and confirms it in
  /// person, same as the "pay at the gym" option during registration.
  Future<void> _payCash() async {
    setState(() {
      _processing = true;
    });

    try {
      await _service.checkout(metodo: 'Efectivo', estado: 'Pendiente');
      final cart = CartController.instance;
      cart.clear();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Compra registrada! Paga en el gimnasio para recoger tu pedido.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar la compra: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _processing = false;
        });
      }
    }
  }

  Future<void> _payOnline() async {
    final cart = CartController.instance;

    setState(() {
      _processing = true;
    });

    try {
      final initPoint = await _apiService.createPaymentPreference(
        concepto: 'Compra en tienda',
        monto: cart.total.toStringAsFixed(0),
        email: UserSession.email ?? '',
        memberId: UserSession.memberId ?? '',
      );

      final opened = await launchUrl(
        Uri.parse(initPoint),
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        throw Exception('No se pudo abrir la página de pago');
      }

      if (!mounted) return;
      await _showWaitingForPaymentDialog();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo iniciar el pago: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _processing = false;
        });
      }
    }
  }

  Future<void> _showWaitingForPaymentDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirmando tu pago'),
          content: const Text(
            'Completa el pago en la ventana que se abrió. Cuando termines, '
            'toca "Ya terminé" para registrar tu pedido.\n\n'
            'Tu pedido queda como PENDIENTE hasta que el gimnasio valide el '
            'pago en MercadoPago — no se marca pagado automáticamente.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _finalizeOnlineSale();
              },
              child: const Text('Ya terminé'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _finalizeOnlineSale() async {
    final cart = CartController.instance;

    try {
      // We open MercadoPago in an external browser and never see the
      // return redirect, so we can't confirm the payment from here.
      // Record the order as pending — staff (or a future webhook) marks
      // it paid once MercadoPago confirms.
      await _service.checkout(
        metodo: 'MercadoPago',
        estado: 'Pendiente confirmacion',
      );
      cart.clear();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Pedido registrado. Se confirmará cuando validemos tu pago.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar la compra: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartController.instance;

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: cart.items,
          builder: (context, items, _) {
            return Column(
              children: [
                // Lista de productos
                Expanded(
                  child: items.isEmpty
                      ? const Center(child: Text("Tu carrito está vacío"))
                      : ListView(
                          padding: const EdgeInsets.all(12),
                          children: items.entries.map((e) {
                            final product = cart.getProduct(e.key);
                            final qty = e.value;

                            if (product == null) return const SizedBox();

                            return Card(
                              child: ListTile(
                                title: Text(product.nombre),
                                subtitle: Text("\$${product.precio}"),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () => cart.decrease(product),
                                    ),
                                    Text("$qty"),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () => cart.add(product),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => cart.remove(product),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),

                if (items.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Método de pago',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        RadioGroup<_PaymentMethod>(
                          groupValue: _paymentMethod,
                          onChanged: (value) {
                            if (_processing || value == null) return;
                            setState(() => _paymentMethod = value);
                          },
                          child: const Column(
                            children: [
                              RadioListTile<_PaymentMethod>(
                                contentPadding: EdgeInsets.zero,
                                value: _PaymentMethod.efectivo,
                                title: Text('Pagar en el gimnasio'),
                                subtitle: Text('Recoge y paga en recepción'),
                              ),
                              RadioListTile<_PaymentMethod>(
                                contentPadding: EdgeInsets.zero,
                                value: _PaymentMethod.online,
                                title: Text('Pagar en línea ahora'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Botón de pago
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (items.isEmpty || _processing)
                          ? null
                          : _pay,
                      child: _processing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _paymentMethod == _PaymentMethod.efectivo
                                  ? "Registrar compra \$${cart.total.toStringAsFixed(2)}"
                                  : "Pagar \$${cart.total.toStringAsFixed(2)}",
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
