import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(ProductModel product) {
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existing) => CartItem(
          productId: existing.productId,
          farmerId: existing.farmerId,
          productName: existing.productName,
          productImage: existing.productImage,
          price: existing.price,
          quantity: existing.quantity + 1,
          unit: existing.unit,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id,
        () => CartItem(
          productId: product.id,
          farmerId: product.farmerId,
          productName: product.name,
          productImage: product.images.isNotEmpty ? product.images[0] : '',
          price: product.price,
          quantity: 1,
          unit: product.unit,
        ),
      );
    }
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existing) => CartItem(
          productId: existing.productId,
          farmerId: existing.farmerId,
          productName: existing.productName,
          productImage: existing.productImage,
          price: existing.price,
          quantity: existing.quantity - 1,
          unit: existing.unit,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
