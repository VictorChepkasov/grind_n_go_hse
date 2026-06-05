import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ProductPlaceholder extends StatelessWidget {
  const ProductPlaceholder({super.key, this.iconSize = 48});

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.accentLight.withValues(alpha: 0.45),
      child: Icon(
        Icons.local_cafe_rounded,
        size: iconSize,
        color: AppColors.coffee.withValues(alpha: 0.7),
      ),
    );
  }
}
