import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_colors.dart';
import '../widgets/help_fab.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemCount: mockProducts.length,
                itemBuilder: (context, index) {
                  final product = mockProducts[index];
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
