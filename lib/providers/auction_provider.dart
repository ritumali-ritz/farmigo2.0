import 'package:flutter/material.dart';
import '../models/auction_model.dart';
import '../models/bid_model.dart';
import '../services/database_service.dart';

class AuctionProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  
  List<AuctionModel> _activeAuctions = [];
  bool _isLoading = false;

  List<AuctionModel> get activeAuctions => _activeAuctions;
  bool get isLoading => _isLoading;

  void fetchActiveAuctions() {
    _isLoading = true;
    _db.getActiveAuctions().listen((auctions) {
      _activeAuctions = auctions;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> startAuction(AuctionModel auction) async {
    await _db.createAuction(auction);
  }

  Future<void> placeBid(String auctionId, String buyerId, double amount) async {
    await _db.placeBid(auctionId, buyerId, amount);
  }

  Stream<AuctionModel?> streamAuction(String auctionId) {
    return _db.streamAuctionById(auctionId);
  }

  Stream<List<BidModel>> streamBids(String auctionId) {
    return _db.streamAuctionBids(auctionId);
  }
}
