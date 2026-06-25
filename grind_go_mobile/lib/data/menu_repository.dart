import '../models/product.dart';
import '../models/product_size.dart';
import 'api_client.dart';

class MenuRepository {
  MenuRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<Product>> fetchProducts() async {
    final json = await _client.getJson('/api/menu');
    final categories = json['categories'] as List<dynamic>? ?? [];
    final products = <Product>[];

    for (final category in categories) {
      if (category is! Map<String, dynamic>) continue;
      final items = category['products'] as List<dynamic>? ?? [];
      for (final item in items) {
        if (item is Map<String, dynamic>) {
          products.add(_mapProduct(item));
        }
      }
    }

    return products;
  }

  Product _mapProduct(Map<String, dynamic> json) {
    final sizesJson = json['sizes'] as List<dynamic>? ?? [];

    return Product(
      id: (json['productId'] as num).toInt(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      hasPhoto: json['hasPhoto'] as bool? ?? false,
      sizes: sizesJson
          .whereType<Map<String, dynamic>>()
          .map(_mapSize)
          .toList(),
    );
  }

  ProductSize _mapSize(Map<String, dynamic> json) {
    final sizeName = json['sizeName'] as String? ?? '';
    return ProductSize(
      productSizeId: (json['productSizeId'] as num?)?.toInt(),
      name: _formatSizeName(sizeName),
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }

  String _formatSizeName(String sizeName) {
    if (sizeName.isEmpty) return sizeName;
    return sizeName[0].toUpperCase() + sizeName.substring(1);
  }
}
