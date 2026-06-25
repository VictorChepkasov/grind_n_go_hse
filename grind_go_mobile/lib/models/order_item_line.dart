class OrderItemLine {
  const OrderItemLine({
    required this.productSizeId,
    required this.productName,
    required this.sizeName,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  final int productSizeId;
  final String productName;
  final String sizeName;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  factory OrderItemLine.fromJson(Map<String, dynamic> json) {
    return OrderItemLine(
      productSizeId: (json['productSizeId'] as num).toInt(),
      productName: json['productName'] as String? ?? '',
      sizeName: json['sizeName'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      lineTotal: (json['lineTotal'] as num?)?.toDouble() ?? 0,
    );
  }

  String get formattedSizeName {
    if (sizeName.isEmpty) return sizeName;
    return sizeName[0].toUpperCase() + sizeName.substring(1);
  }
}
