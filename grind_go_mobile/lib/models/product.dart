import 'product_size.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.sizes,
    required this.description,
    this.imageAsset,
  });

  final int id;
  final String name;
  final List<ProductSize> sizes;
  final String description;
  final String? imageAsset;

  double get basePrice =>
      sizes.isEmpty ? 0 : sizes.map((s) => s.price).reduce((a, b) => a < b ? a : b);
}
