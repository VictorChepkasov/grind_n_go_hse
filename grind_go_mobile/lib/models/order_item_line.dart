class OrderItemLine {
  const OrderItemLine({
    required this.containId,
    required this.productSizeId,
    required this.productName,
    required this.sizeName,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  final int containId;
  final int productSizeId;
  final String productName;
  final String sizeName;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  factory OrderItemLine.fromJson(Map<String, dynamic> json) {
    return OrderItemLine(
      containId: (json['containId'] as num).toInt(),
      productSizeId: (json['productSizeId'] as num).toInt(),
      productName: json['productName'] as String? ?? '',
      sizeName: json['sizeName'] as String? ?? '',
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      lineTotal: (json['lineTotal'] as num).toDouble(),
    );
  }
}
