import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/product_size.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalQuantity =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + item.totalPrice);

  void addItem({
    required Product product,
    required ProductSize size,
    required int quantity,
  }) {
    final existingIndex = _items.indexWhere(
      (item) =>
          item.product.id == product.id && item.size.name == size.name,
    );

    if (existingIndex >= 0) {
      final existing = _items[existingIndex];
      _items[existingIndex] = CartItem(
        product: existing.product,
        size: existing.size,
        quantity: existing.quantity + quantity,
      );
    } else {
      _items.add(
        CartItem(
          product: product,
          size: size,
          quantity: quantity,
        ),
      );
    }

    notifyListeners();
  }

  void removeItemAt(int index) {
    if (index < 0 || index >= _items.length) return;
    _items.removeAt(index);
    notifyListeners();
  }

  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }
}
