import 'package:flutter/material.dart';

import '../core/api_config.dart';
import '../models/product.dart';
import 'product_placeholder.dart';

class ProductPhoto extends StatelessWidget {
  const ProductPhoto({
    super.key,
    required this.product,
    this.iconSize = 48,
    this.fit = BoxFit.cover,
    this.photoUrl,
    this.headers,
  });

  final Product product;
  final double iconSize;
  final BoxFit fit;
  final String? photoUrl;
  final Map<String, String>? headers;

  @override
  Widget build(BuildContext context) {
    if (!product.hasPhoto) {
      return ProductPlaceholder(iconSize: iconSize);
    }

    return Image.network(
      photoUrl ?? productPhotoUrl(product.id),
      headers: headers,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return ProductPlaceholder(iconSize: iconSize);
      },
      errorBuilder: (_, __, ___) => ProductPlaceholder(iconSize: iconSize),
    );
  }
}
