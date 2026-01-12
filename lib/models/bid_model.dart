class BidModel {
  final String id;
  final String auctionId;
  final String buyerId;
  final double amount;
  final DateTime createdAt;

  BidModel({
    required this.id,
    required this.auctionId,
    required this.buyerId,
    required this.amount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'auction_id': auctionId,
      'buyer_id': buyerId,
      'amount': amount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory BidModel.fromMap(Map<String, dynamic> map, String docId) {
    return BidModel(
      id: docId,
      auctionId: map['auction_id'] ?? '',
      buyerId: map['buyer_id'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
