class OrderModel {
  final String id;
  final String buyerId;
  final String farmerId;
  final List<OrderItem> items;
  final double totalAmount;
  final String status; // Pending, Accepted, Shipped, Delivered, Cancelled
  final String deliveryAddress;
  final DateTime createdAt;
  final String buyerName;
  final String buyerPhone;

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.farmerId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.deliveryAddress,
    required this.createdAt,
    required this.buyerName,
    required this.buyerPhone,
  });

  Map<String, dynamic> toMap() {
    return {
      'buyer_id': buyerId,
      'farmer_id': farmerId,
      'items': items.map((e) => e.toMap()).toList(),
      'total_amount': totalAmount,
      'status': status,
      'delivery_address': deliveryAddress,
      'created_at': createdAt.toIso8601String(),
      'buyer_name': buyerName,
      'buyer_phone': buyerPhone,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String docId) {
    return OrderModel(
      id: docId,
      buyerId: map['buyer_id'] ?? '',
      farmerId: map['farmer_id'] ?? '',
      items: (map['items'] as List).map((e) => OrderItem.fromMap(e)).toList(),
      totalAmount: (map['total_amount'] ?? 0).toDouble(),
      status: map['status'] ?? 'Pending',
      deliveryAddress: map['delivery_address'] ?? '',
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      buyerName: map['buyer_name'] ?? '',
      buyerPhone: map['buyer_phone'] ?? '',
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String unit;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.unit,
  });

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'unit': unit,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['product_id'] ?? '',
      productName: map['product_name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
      unit: map['unit'] ?? 'kg',
    );
  }
}
