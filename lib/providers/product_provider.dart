import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/database_service.dart';

class ProductProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  List<ProductModel> _products = [];
  bool _isLoading = false;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;

  void fetchProducts({String? category}) {
    _isLoading = true;
    _db.getAllProducts(category: category).listen((productList) {
      _products = productList;
      _isLoading = false;
      notifyListeners();
    });
  }

  // search products
  List<ProductModel> searchProducts(String query) {
    return _products
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
