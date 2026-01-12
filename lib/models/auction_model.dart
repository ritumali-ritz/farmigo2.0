import 'package:intl/intl.dart';

class AuctionModel {
  final String id;
  final String farmerId;
  final String productId;
  final double startingPrice;
  final double currentHighestBid;
  final double minBidIncrement;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // active, completed, cancelled
  final String purpose; // Why is this auction done?
  final String? winnerId;
  final DateTime createdAt;

  AuctionModel({
    required this.id,
    required this.farmerId,
    required this.productId,
    required this.startingPrice,
    required this.currentHighestBid,
    required this.minBidIncrement,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.purpose,
    this.winnerId,
    required this.createdAt,
  });

  bool get isActive => status == 'active' && endTime.isAfter(DateTime.now());

  String get timeLeft {
    final difference = endTime.difference(DateTime.now());
    if (difference.isNegative) return "Ended";
    
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    final seconds = difference.inSeconds.remainder(60);
    
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'farmer_id': farmerId,
      'product_id': productId,
      'starting_price': startingPrice,
      'current_highest_bid': currentHighestBid,
      'min_bid_increment': minBidIncrement,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': status,
      'purpose': purpose,
      'winner_id': winnerId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AuctionModel.fromMap(Map<String, dynamic> map, String docId) {
    return AuctionModel(
      id: docId,
      farmerId: map['farmer_id'] ?? '',
      productId: map['product_id'] ?? '',
      startingPrice: (map['starting_price'] ?? 0).toDouble(),
      currentHighestBid: (map['current_highest_bid'] ?? 0).toDouble(),
      minBidIncrement: (map['min_bid_increment'] ?? 1).toDouble(),
      startTime: DateTime.parse(map['start_time'] ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(map['end_time'] ?? DateTime.now().toIso8601String()),
      status: map['status'] ?? 'active',
      purpose: map['purpose'] ?? 'Market Sale',
      winnerId: map['winner_id'],
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
