import '../models/cart_item.dart';
import '../models/order.dart';
import 'api_client.dart';

class OrderRepository {
  OrderRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<Order> createOrder({
    required String token,
    required List<CartItem> items,
  }) async {
    final json = await _client.postJson(
      '/api/orders',
      {
        'items': items
            .map(
              (item) => {
                'productSizeId': item.size.productSizeId,
                'quantity': item.quantity,
              },
            )
            .toList(),
      },
      token: token,
    );

    return Order.fromJson(json);
  }

  Future<List<Order>> fetchBaristaQueue({required String token}) async {
    final list = await _client.getJsonList('/api/orders/queue', token: token);
    return list
        .whereType<Map<String, dynamic>>()
        .map(Order.fromJson)
        .toList();
  }

  Future<Order> updateOrderStatus({
    required String token,
    required int orderId,
    required String status,
  }) async {
    final json = await _client.patchJson(
      '/api/orders/$orderId/status',
      {'status': status},
      token: token,
    );

    return Order.fromJson(json);
  }
}
