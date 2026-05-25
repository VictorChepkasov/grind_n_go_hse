class Product {
  const Product({
    required this.id,
    required this.name,
    required this.basePrice,
    required this.description,
    this.imageAsset,
  });

  final int id;
  final String name;
  final double basePrice;
  final String description;
  final String? imageAsset;
}
