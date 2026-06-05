import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/app_colors.dart';
import 'product_placeholder.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  final Product product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: const ProductPlaceholder(iconSize: 48),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                '₽${product.basePrice.toStringAsFixed(0)}',
                style: textTheme.labelLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
