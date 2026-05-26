import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartController {
  static final CartController instance = CartController._internal();
  CartController._internal();

  final ValueNotifier<Map<String, int>> items =
      ValueNotifier<Map<String, int>>({});

  final Map<String, Product> _products = {};

  // =====================
  // ADD PRODUCT
  // =====================
  void add(Product product) {
    _products[product.id] = product;

    final current = Map<String, int>.from(items.value);
    current[product.id] = (current[product.id] ?? 0) + 1;

    items.value = current;
  }

  // =====================
  // DECREASE PRODUCT
  // =====================
  void decrease(Product product) {
    final current = Map<String, int>.from(items.value);

    if (!current.containsKey(product.id)) return;

    final qty = current[product.id]! - 1;

    if (qty <= 0) {
      current.remove(product.id);
      _products.remove(product.id);
    } else {
      current[product.id] = qty;
    }

    items.value = current;
  }

  // =====================
  // REMOVE PRODUCT
  // =====================
  void remove(Product product) {
    final current = Map<String, int>.from(items.value);
    current.remove(product.id);
    _products.remove(product.id);

    items.value = current;
  }

  // =====================
  // GET PRODUCT
  // =====================
  Product? getProduct(String id) => _products[id];

  // =====================
  // TOTAL ITEMS
  // =====================
  int get totalItems =>
      items.value.values.fold(0, (a, b) => a + b);

  // =====================
  // TOTAL PRICE (SAFE)
  // =====================
  double get total {
    double sum = 0;

    items.value.forEach((id, qty) {
      final product = _products[id];
      if (product != null) {
        sum += product.priceValue * qty;
      }
    });

    return sum;
  }

  // =====================
  // CLEAR CART (checkout)
  // =====================
  void clear() {
    items.value = {};
    _products.clear();
  }
}