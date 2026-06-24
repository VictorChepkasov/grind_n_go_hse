import 'order_item_line.dart';

class Order {
  const Order({
    required this.orderId,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
    required this.items,
    this.customerName,
  });

  final int orderId;
  final String status;
  final double totalPrice;
  final DateTime createdAt;
  final String? customerName;
  final List<OrderItemLine> items;

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];

    return Order(
      orderId: (json['orderId'] as num).toInt(),
      status: json['status'] as String? ?? '',
      totalPrice: (json['totalPrice'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      customerName: json['customerName'] as String?,
      items: itemsJson
          .whereType<Map<String, dynamic>>()
          .map(OrderItemLine.fromJson)
          .toList(),
    );
  }
}
