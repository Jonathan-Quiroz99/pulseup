import 'package:flutter/material.dart';
import '../models/product.dart';
import '../controllers/cart_controller.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final cart = CartController.instance;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colors.primary.withOpacity(0.2),
            child: Icon(Icons.fastfood, color: colors.primary),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.nombre,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  product.descripcion,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),

                const SizedBox(height: 6),

                Text(
                  "\$${product.precio}",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () => cart.add(product),
            icon: Icon(Icons.add_circle, color: colors.primary),
          ),
        ],
      ),
    );
  }
}