import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/product_size.dart';
import '../providers/cart_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/help_fab.dart';
import '../widgets/product_placeholder.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late int _selectedSizeIndex;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _selectedSizeIndex = widget.product.sizes.length > 1 ? 1 : 0;
  }

  ProductSize get _selectedSize => widget.product.sizes[_selectedSizeIndex];

  double get _unitPrice => _selectedSize.price;

  double get _totalPrice => _unitPrice * _quantity;

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  void _incrementQuantity() {
    setState(() => _quantity++);
  }

  void _addToCart() {
    context.read<CartProvider>().addItem(
          product: widget.product,
          size: _selectedSize,
          quantity: _quantity,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.product.name} (${_selectedSize.name}) × $_quantity добавлено в корзину',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final product = widget.product;

    return Scaffold(
      backgroundColor: AppColors.surface,
      floatingActionButton: const HelpFab(),
      floatingActionButtonLocation: _ProductDetailFabLocation(),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductImageHeader(
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₽${_totalPrice.toStringAsFixed(0)}',
                      style: textTheme.labelLarge?.copyWith(
                        fontSize: 22,
                        color: AppColors.accentDark,
                      ),
                    ),
                    if (_quantity > 1) ...[
                      const SizedBox(height: 4),
                      Text(
                        '₽${_unitPrice.toStringAsFixed(0)} × $_quantity',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    Text('Размер', style: textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _SizeSelector(
                      sizes: product.sizes,
                      selectedIndex: _selectedSizeIndex,
                      onSelected: (index) =>
                          setState(() => _selectedSizeIndex = index),
                    ),
                    const SizedBox(height: 28),
                    Text('Количество', style: textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _QuantitySelector(
                      quantity: _quantity,
                      onDecrement: _decrementQuantity,
                      onIncrement: _incrementQuantity,
                    ),
                    const SizedBox(height: 28),
                    Text('Описание', style: textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentDark,
                foregroundColor: AppColors.textOnPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textOnPrimary,
                ),
              ),
              child: Text(
                'В корзину · ₽${_totalPrice.toStringAsFixed(0)}',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductImageHeader extends StatelessWidget {
  const _ProductImageHeader({
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: const ProductPlaceholder(iconSize: 96),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: _CircleIconButton(
            icon: Icons.arrow_back_rounded,
            onPressed: onBack,
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: AppColors.textPrimary.withValues(alpha: 0.15),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 22,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _SizeSelector extends StatelessWidget {
  const _SizeSelector({
    required this.sizes,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<ProductSize> sizes;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < sizes.length; i++) ...[
          if (i > 0) const SizedBox(width: 48),
          GestureDetector(
            onTap: () => onSelected(i),
            child: Text(
              sizes[i].name,
              style: textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight:
                    i == selectedIndex ? FontWeight.w700 : FontWeight.w500,
                color: i == selectedIndex
                    ? AppColors.textPrimary
                    : AppColors.textMuted,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _QuantityButton(
          icon: Icons.remove_rounded,
          onPressed: quantity > 1 ? onDecrement : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            '$quantity',
            style: textTheme.titleLarge?.copyWith(fontSize: 20),
          ),
        ),
        _QuantityButton(
          icon: Icons.add_rounded,
          onPressed: onIncrement,
        ),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceMuted,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 22,
            color: onPressed != null
                ? AppColors.textPrimary
                : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _ProductDetailFabLocation extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    const padding = 16.0;
    const bottomBarHeight = 76.0;

    final fabSize = scaffoldGeometry.floatingActionButtonSize;
    final scaffoldSize = scaffoldGeometry.scaffoldSize;

    return Offset(
      scaffoldSize.width - fabSize.width - padding,
      scaffoldSize.height - fabSize.height - bottomBarHeight - padding,
    );
  }
}
