import 'product_size.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.sizes,
    required this.description,
    this.hasPhoto = false,
    this.imageAsset,
    this.isAvailable = true,
  });

  final int id;
  final String name;
  final List<ProductSize> sizes;
  final String description;
  final bool hasPhoto;
  final String? imageAsset;
  final bool isAvailable;

  double get basePrice =>
      sizes.isEmpty ? 0 : sizes.map((s) => s.price).reduce((a, b) => a < b ? a : b);

  Product copyWith({bool? isAvailable}) {
    return Product(
      id: id,
      name: name,
      sizes: sizes,
      description: description,
      hasPhoto: hasPhoto,
      imageAsset: imageAsset,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
