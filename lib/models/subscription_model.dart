class SubscriptionModel {
  final String id;
  final String buyerId;
  final String farmerId;
  final String productId;
  final String productName;
  final double price;
  final int quantityPerDay;
  final String status; // Active, Paused, Stopped
  final DateTime startDate;

  SubscriptionModel({
    required this.id,
    required this.buyerId,
    required this.farmerId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantityPerDay,
    required this.status,
    required this.startDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'buyer_id': buyerId,
      'farmer_id': farmerId,
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity_per_day': quantityPerDay,
      'status': status,
      'start_date': startDate.toIso8601String(),
    };
  }

  factory SubscriptionModel.fromMap(Map<String, dynamic> map, String docId) {
    return SubscriptionModel(
      id: docId,
      buyerId: map['buyer_id'] ?? '',
      farmerId: map['farmer_id'] ?? '',
      productId: map['product_id'] ?? '',
      productName: map['product_name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantityPerDay: map['quantity_per_day'] ?? 1,
      status: map['status'] ?? 'Active',
      startDate: DateTime.parse(map['start_date'] ?? DateTime.now().toIso8601String()),
    );
  }
}
