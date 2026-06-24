import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/menu_repository.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';
import '../widgets/help_fab.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Product>>? _productsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productsFuture ??= context.read<MenuRepository>().fetchProducts();
  }

  void _loadProducts() {
    setState(() {
      _productsFuture = context.read<MenuRepository>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.surface,
      floatingActionButton: const HelpFab(),
      floatingActionButtonLocation: const HelpFabLocation(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text(
                'Grind & Go',
                style: textTheme.headlineLarge,
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return _MenuError(
                      message: snapshot.error.toString(),
                      onRetry: _loadProducts,
                    );
                  }

                  final products = snapshot.data ?? [];
                  if (products.isEmpty) {
                    return Center(
                      child: Text(
                        'Меню пока пусто',
                        style: textTheme.bodyLarge,
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  ProductDetailScreen(product: product),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuError extends StatelessWidget {
  const _MenuError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Не удалось загрузить меню',
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}
