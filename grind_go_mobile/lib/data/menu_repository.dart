import '../models/product.dart';
import '../models/product_size.dart';
import 'api_client.dart';

class MenuRepository {
  MenuRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Product>> fetchProducts() async {
    final response = await _apiClient.get('/api/menu');
    final data = await _apiClient.decodeJson(response);

    final categories = data['categories'] as List<dynamic>? ?? [];
    final products = <Product>[];

    for (final category in categories) {
      if (category is! Map<String, dynamic>) continue;
      final categoryProducts = category['products'] as List<dynamic>? ?? [];

      for (final item in categoryProducts) {
        if (item is! Map<String, dynamic>) continue;
        products.add(_mapProduct(item));
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
      sizes: sizesJson
          .whereType<Map<String, dynamic>>()
          .map(
            (size) => ProductSize(
              id: (size['productSizeId'] as num).toInt(),
              name: size['sizeName'] as String? ?? '',
              price: (size['price'] as num).toDouble(),
            ),
          )
          .toList(),
    );
  }
}
