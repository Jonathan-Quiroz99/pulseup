import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/ui/app_card.dart';
import '../controllers/cart_controller.dart';
import '../models/product.dart';

/// Maps a category to an icon + tint so every card isn't the same badge.
class _CategoryStyle {
  final IconData icon;
  final Color tint;
  const _CategoryStyle(this.icon, this.tint);
}

const _categoryStyles = <String, _CategoryStyle>{
  'Bebidas': _CategoryStyle(Icons.local_drink_outlined, AppColors.tintBlue),
  'Suplementos':
      _CategoryStyle(Icons.medication_outlined, AppColors.tintViolet),
  'Frutas': _CategoryStyle(Icons.eco_outlined, AppColors.tintGreen),
};

_CategoryStyle _styleFor(String categoria) =>
    _categoryStyles[categoria] ??
    const _CategoryStyle(Icons.shopping_bag_outlined, AppColors.accent);

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(product.categoria);
    final cart = CartController.instance;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: style.tint.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(style.icon, color: style.tint, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nombre,
                    style: AppTextStyles.titleMd,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (product.descripcion.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      product.descripcion,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySm,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    '\$${product.precio.toStringAsFixed(0)}',
                    style: AppTextStyles.statSm.copyWith(color: AppColors.accent),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              onPressed: () => cart.add(product),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.accentSoft,
                foregroundColor: AppColors.accent,
              ),
              icon: const Icon(Icons.add, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
