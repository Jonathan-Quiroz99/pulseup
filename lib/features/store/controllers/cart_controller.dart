import '../models/product.dart';

class CartController {
  static final CartController instance = CartController._internal();
  CartController._internal();

  final Map<String, int> _items = {};
  final Map<String, Product> _products = {};

  Map<String, int> get items => _items;

  void add(Product product) {
    _products[product.id] = product;
    _items[product.id] = (_items[product.id] ?? 0) + 1;
  }

  void remove(Product product) {
    if (!_items.containsKey(product.id)) return;

    final qty = _items[product.id]! - 1;

    if (qty <= 0) {
      _items.remove(product.id);
      _products.remove(product.id);
    } else {
      _items[product.id] = qty;
    }
  }

  double get total {
    double sum = 0;
    _items.forEach((id, qty) {
      sum += (_products[id]?.precio ?? 0) * qty;
    });
    return sum;
  }

  int get totalItems {
    return _items.values.fold(0, (a, b) => a + b);
  }

  void clear() {
    _items.clear();
    _products.clear();
  }
}