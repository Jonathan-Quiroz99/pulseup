import 'package:flutter/material.dart';
import '../models/product.dart';
import '../controllers/cart_controller.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = CartController.instance;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.05),
          )
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            child: Icon(Icons.fastfood),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold)),

                Text(product.descripcion,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),

                const SizedBox(height: 6),

                Text("\$${product.precio}",
                    style: const TextStyle(color: Colors.green)),
              ],
            ),
          ),

          IconButton(
            onPressed: () => cart.add(product),
            icon: const Icon(Icons.add_circle),
          ),
        ],
      ),
    );
  }
}