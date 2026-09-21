import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../checkout_screen.dart';
import '../controllers/cart_controller.dart';

class CartBar extends StatelessWidget {
  const CartBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = CartController.instance;

    return ValueListenableBuilder(
      valueListenable: cart.items,
      builder: (context, value, _) {
        if (value.isEmpty) return const SizedBox.shrink();

        return Container(
          // Bottom margin clears HomeScreen's floating nav pill.
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.navBarClearance,
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.hairline),
            boxShadow: const [
              BoxShadow(
                color: AppColors.ambientShadow,
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${cart.totalItems} artículo${cart.totalItems == 1 ? '' : 's'}',
                    style: AppTextStyles.label,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${cart.total.toStringAsFixed(2)}',
                    style: AppTextStyles.statSm,
                  ),
                ],
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                ),
                child: const Text('Ver carrito'),
              ),
            ],
          ),
        );
      },
    );
  }
}
