import 'product.dart';
import 'product_size.dart';

class CartItem {
  const CartItem({
    required this.product,
    required this.size,
    required this.quantity,
  });

  final Product product;
  final ProductSize size;
  final int quantity;

  double get totalPrice => size.price * quantity;
}
