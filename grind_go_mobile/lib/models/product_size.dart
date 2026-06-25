class ProductSize {
  const ProductSize({
    required this.name,
    required this.price,
    this.productSizeId,
  });

  final String name;
  final double price;
  final int? productSizeId;
}
