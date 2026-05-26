import 'package:flutter/material.dart';
import 'controllers/cart_controller.dart';
import 'services/cart_service.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = CartController.instance;
    final service = CartService();

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: ValueListenableBuilder(
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
              
              // Botón de pago
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: items.isEmpty
                          ? null
                          : () async {
                              try {
                                await service.checkout();
                                cart.clear();
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Error checkout: $e")),
                                  );
                                }
                              }
                            },
                      child: Text(
                        "Pagar \$${cart.total.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}