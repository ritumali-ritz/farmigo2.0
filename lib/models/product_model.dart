class ProductModel {
  final String id;
  final String farmerId;
  final String name;
  final String description;
  final double price;
  final String unit; // e.g., kg, dozen, liter
  final int stockQuantity;
  final String category;
  final List<String> images;
  final bool isAvailable;
  final bool isDailySubscriptionAvailable;

  ProductModel({
    required this.id,
    required this.farmerId,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.stockQuantity,
    required this.category,
    required this.images,
    this.isAvailable = true,
    this.isDailySubscriptionAvailable = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'farmer_id': farmerId,  // snake_case for database
      'name': name,
      'description': description,
      'price': price,
      'unit': unit,
      'stock_quantity': stockQuantity,  // snake_case for database
      'category': category,
      'images': images,
      'is_available': isAvailable,  // snake_case for database
      'is_daily_subscription_available': isDailySubscriptionAvailable,  // snake_case for database
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map, String docId) {
    return ProductModel(
      id: docId,
      farmerId: map['farmer_id'] ?? '',  // snake_case from database
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      unit: map['unit'] ?? 'kg',
      stockQuantity: map['stock_quantity'] ?? 0,  // snake_case from database
      category: map['category'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      isAvailable: map['is_available'] ?? true,  // snake_case from database
      isDailySubscriptionAvailable: map['is_daily_subscription_available'] ?? false,  // snake_case from database
    );
  }
}
