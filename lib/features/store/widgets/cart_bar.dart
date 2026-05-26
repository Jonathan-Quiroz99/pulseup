import 'package:flutter/material.dart';
import '../controllers/cart_controller.dart';
import '../checkout_screen.dart'; // Ajusta la ruta según tu estructura

class CartBar extends StatelessWidget {
  const CartBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = CartController.instance;

    return ValueListenableBuilder(
      valueListenable: cart.items,
      builder: (context, value, _) {
        if (value.isEmpty) return const SizedBox();

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(
            children: [
              // Items count
              Text(
                "${cart.totalItems} items",
                style: const TextStyle(color: Colors.white),
              ),
              
              const SizedBox(width: 12),
              
              // Total price (expanded to fill space)
              Expanded(
                child: Text(
                  "\$${cart.total.toStringAsFixed(2)}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              
              // Checkout button with proper constraints
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 80,
                  maxWidth: 120,
                ),
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      // 🔥 SOLUCIÓN: Usar push en lugar de pushNamed
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CheckoutScreen(),
                        ),
                      );
                    },
                    child: const Text("Checkout"),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}