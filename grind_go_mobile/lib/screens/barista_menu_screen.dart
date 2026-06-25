import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_config.dart';
import '../core/api_exception.dart';
import '../core/app_messenger.dart';
import '../data/barista_product_repository.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/product_photo.dart';

class BaristaMenuScreen extends StatefulWidget {
  const BaristaMenuScreen({super.key});

  @override
  State<BaristaMenuScreen> createState() => _BaristaMenuScreenState();
}

class _BaristaMenuScreenState extends State<BaristaMenuScreen> {
  final _repository = BaristaProductRepository();

  List<Product>? _products;
  String? _error;
  bool _loading = true;
  final Set<int> _updatingProductIds = {};

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final products = await _repository.fetchProducts(token: token);
      if (!mounted) return;
      setState(() {
        _products = products;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Не удалось загрузить меню.';
        _loading = false;
      });
    }
  }

  Future<void> _toggleAvailability(Product product, bool isAvailable) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    setState(() {
      _updatingProductIds.add(product.id);
      _products = _products
          ?.map(
            (item) => item.id == product.id
                ? item.copyWith(isAvailable: isAvailable)
                : item,
          )
          .toList();
    });

    try {
      await _repository.setAvailability(
        token: token,
        productId: product.id,
        isAvailable: isAvailable,
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _products = _products
            ?.map(
              (item) => item.id == product.id
                  ? item.copyWith(isAvailable: !isAvailable)
                  : item,
            )
            .toList();
      });
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _products = _products
            ?.map(
              (item) => item.id == product.id
                  ? item.copyWith(isAvailable: !isAvailable)
                  : item,
            )
            .toList();
      });
      _showMessage('Не удалось обновить доступность товара.');
    } finally {
      if (mounted) {
        setState(() => _updatingProductIds.remove(product.id));
      }
    }
  }

  void _showMessage(String message) {
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final token = context.watch<AuthProvider>().token;
    final photoHeaders = token == null
        ? null
        : <String, String>{'Authorization': 'Bearer $token'};

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Меню',
                style: textTheme.headlineLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                'Отключите позиции, которых сейчас нет в наличии.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(child: _buildBody(textTheme, photoHeaders)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(TextTheme textTheme, Map<String, String>? photoHeaders) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _loadMenu,
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    final products = _products ?? [];

    if (products.isEmpty) {
      return Center(
        child: Text(
          'Меню пока пустое',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMenu,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.68,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final isUpdating = _updatingProductIds.contains(product.id);

          return _BaristaProductCard(
            product: product,
            photoHeaders: photoHeaders,
            isUpdating: isUpdating,
            onAvailabilityChanged: (value) =>
                _toggleAvailability(product, value),
          );
        },
      ),
    );
  }
}

class _BaristaProductCard extends StatelessWidget {
  const _BaristaProductCard({
    required this.product,
    required this.photoHeaders,
    required this.isUpdating,
    required this.onAvailabilityChanged,
  });

  final Product product;
  final Map<String, String>? photoHeaders;
  final bool isUpdating;
  final ValueChanged<bool> onAvailabilityChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isAvailable = product.isAvailable;

    return Material(
      color: isAvailable ? AppColors.surfaceMuted : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isAvailable
            ? BorderSide.none
            : BorderSide(
                color: AppColors.textSecondary.withValues(alpha: 0.25),
              ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Opacity(
                      opacity: isAvailable ? 1 : 0.45,
                      child: ProductPhoto(
                        product: product,
                        iconSize: 48,
                        photoUrl: baristaProductPhotoUrl(product.id),
                        headers: photoHeaders,
                      ),
                    ),
                  ),
                  if (!isAvailable)
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Нет',
                          style: textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleLarge?.copyWith(
                color: isAvailable
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '₽${product.basePrice.toStringAsFixed(0)}',
              style: textTheme.labelLarge?.copyWith(
                color: isAvailable
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Доступен',
                  style: textTheme.labelMedium,
                ),
                if (isUpdating)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Switch.adaptive(
                    value: isAvailable,
                    activeTrackColor: AppColors.success,
                    onChanged: onAvailabilityChanged,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
