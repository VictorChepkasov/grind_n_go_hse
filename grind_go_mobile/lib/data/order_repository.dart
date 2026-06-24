import '../models/cart_item.dart';
import '../models/order.dart';
import 'api_client.dart';

class OrderRepository {
  OrderRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<int> createOrder(List<CartItem> items) async {
    final response = await _apiClient.post(
      '/api/orders',
      body: {
        'items': items
            .map(
              (item) => {
                'productSizeId': item.size.id,
                'quantity': item.quantity,
              },
            )
            .toList(),
      },
    );

    final data = await _apiClient.decodeJson(response);
    return (data['orderId'] as num).toInt();
  }

  Future<List<Order>> fetchBaristaQueue() async {
    final response = await _apiClient.get('/api/orders/queue');
    final data = await _apiClient.decodeJsonList(response);
    return data.map(Order.fromJson).toList();
  }

  Future<Order> updateOrderStatus(int orderId, String status) async {
    final response = await _apiClient.patch(
      '/api/orders/$orderId/status',
      body: {'status': status},
    );

    final data = await _apiClient.decodeJson(response);
    return Order.fromJson(data);
  }
}
