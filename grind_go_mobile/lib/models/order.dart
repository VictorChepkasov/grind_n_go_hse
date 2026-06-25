import 'order_item_line.dart';

class Order {
  const Order({
    required this.id,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
    required this.items,
    this.clientName,
  });

  final int id;
  final String status;
  final double totalPrice;
  final DateTime createdAt;
  final String? clientName;
  final List<OrderItemLine> items;

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];

    return Order(
      id: (json['orderId'] as num).toInt(),
      status: json['status'] as String? ?? '',
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      clientName: json['clientName'] as String?,
      items: itemsJson
          .whereType<Map<String, dynamic>>()
          .map(OrderItemLine.fromJson)
          .toList(),
    );
  }
}
