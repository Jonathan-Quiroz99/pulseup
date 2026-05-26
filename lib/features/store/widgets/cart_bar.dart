import 'package:flutter/material.dart';
import '../controllers/cart_controller.dart';

class CartBar extends StatelessWidget {
  const CartBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = CartController.instance;

    if (cart.totalItems == 0) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${cart.totalItems} items",
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            "\$${cart.total.toStringAsFixed(2)}",
            style: const TextStyle(color: Colors.white),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text("Checkout"),
          )
        ],
      ),
    );
  }
}