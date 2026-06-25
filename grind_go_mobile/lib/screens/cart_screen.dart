import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exception.dart';
import '../data/order_repository.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/navigation_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/product_photo.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _orderRepository = OrderRepository();
  bool _isSubmitting = false;

  Future<void> _placeOrder() async {
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final token = auth.token;

    if (token == null || cart.items.isEmpty) return;

    if (cart.items.any((item) => item.size.productSizeId == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Не удалось оформить заказ. Обновите меню и добавьте напитки заново.',
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final order = await _orderRepository.createOrder(
        token: token,
        items: cart.items,
      );

      cart.clear();

      if (!mounted) return;
      context.read<NavigationProvider>().selectTab(2, refreshProfile: true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Заказ #${order.id} отправлен. Статус — в профиле.',
          ),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось отправить заказ. Проверьте подключение к API.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: cart.items.isEmpty
            ? _EmptyCart(textTheme: textTheme)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Text(
                      'Ваш заказ',
                      style: textTheme.headlineLarge,
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: cart.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _CartItemCard(
                          index: index,
                          onRemove: () => cart.removeItemAt(index),
                        );
                      },
                    ),
                  ),
                  _CartFooter(
                    totalPrice: cart.totalPrice,
                    isSubmitting: _isSubmitting,
                    onPlaceOrder: _placeOrder,
                  ),
                ],
              ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: AppColors.coffeeLight,
            ),
            const SizedBox(height: 16),
            Text('Корзина', style: textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Добавьте напитки из меню.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.index,
    required this.onRemove,
  });

  final int index;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final item = cart.items[index];
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: ProductPhoto(
                    product: item.product,
                    iconSize: 32,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.product.name,
                            style: textTheme.titleLarge,
                          ),
                        ),
                        TextButton(
                          onPressed: onRemove,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Удалить'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Размер: ${item.size.name}',
                      style: textTheme.bodyMedium,
                    ),
                    Text(
                      'Количество: ${item.quantity}',
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '₽${item.totalPrice.toStringAsFixed(0)}',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartFooter extends StatelessWidget {
  const _CartFooter({
    required this.totalPrice,
    required this.isSubmitting,
    required this.onPlaceOrder,
  });

  final double totalPrice;
  final bool isSubmitting;
  final VoidCallback onPlaceOrder;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Итого:',
                  style: textTheme.titleLarge,
                ),
                Text(
                  '₽${totalPrice.toStringAsFixed(0)}',
                  style: textTheme.titleLarge?.copyWith(
                    color: AppColors.accentDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onPlaceOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
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
              child: isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textOnPrimary,
                      ),
                    )
                  : const Text('Заказать'),
            ),
          ),
        ],
      ),
    );
  }
}
