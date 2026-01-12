import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/auction_model.dart';
import '../../models/bid_model.dart';
import '../../models/product_model.dart';
import '../../providers/auction_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class BiddingArenaScreen extends StatefulWidget {
  final String auctionId;
  const BiddingArenaScreen({super.key, required this.auctionId});

  @override
  State<BiddingArenaScreen> createState() => _BiddingArenaScreenState();
}

class _BiddingArenaScreenState extends State<BiddingArenaScreen> {
  final TextEditingController _bidController = TextEditingController();
  final DatabaseService _db = DatabaseService();
  ProductModel? _product;
  bool _isProductLoading = true;
  bool _isPlacingBid = false;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  void _loadProduct() async {
    try {
      final auctionProvider = Provider.of<AuctionProvider>(context, listen: false);
      final auction = await auctionProvider.streamAuction(widget.auctionId).first;
      if (auction != null) {
        final product = await _db.getProductById(auction.productId);
        if (mounted) {
          setState(() {
            _product = product;
            _isProductLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isProductLoading = false);
      }
    } catch (e) {
      print('DEBUG: Error loading product for auction: $e');
      if (mounted) setState(() => _isProductLoading = false);
    }
  }

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  void _placeBid(double currentPrice, double minIncrement) async {
    final amountText = _bidController.text.trim();
    if (amountText.isEmpty) return;

    final amount = double.tryParse(amountText);
    if (amount == null) return;

    if (amount <= currentPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bid must be higher than current price (\u{20B9}${currentPrice.toStringAsFixed(2)})')),
      );
      return;
    }

    if (amount < currentPrice + minIncrement) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Minimum next bid: \u{20B9}${(currentPrice + minIncrement).toStringAsFixed(2)}')),
      );
      return;
    }

    setState(() => _isPlacingBid = true);
    try {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user == null) throw 'You must be logged in to bid.';
      
      print('DEBUG: Placing bid of $amount for auction ${widget.auctionId} by user ${user.uid}');
      
      await Provider.of<AuctionProvider>(context, listen: false).placeBid(
        widget.auctionId,
        user.uid,
        amount,
      );
      _bidController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bid placed successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isPlacingBid = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auctionProvider = Provider.of<AuctionProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: StreamBuilder<AuctionModel?>(
        stream: auctionProvider.streamAuction(widget.auctionId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
          }

          final auction = snapshot.data!;
          
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: const Color(0xFF0F172A),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_product != null && _product!.images.isNotEmpty)
                        Image.network(_product!.images[0], fit: BoxFit.cover)
                      else if (_isProductLoading)
                        const Center(child: CircularProgressIndicator(color: Colors.white24))
                      else
                        Container(color: Colors.grey[900]),
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Color(0xFF0F172A)],
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 60),
                            Text(
                              _product?.name.toUpperCase() ?? 'LIVE AUCTION',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'LIVE BIDDING',
                              style: TextStyle(
                                color: AppConstants.primaryColor.withOpacity(0.8),
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4,
                                fontSize: 12,
                              ),
                            ).animate(onPlay: (controller) => controller.repeat())
                             .shimmer(duration: 2.seconds, color: Colors.white),
                            const SizedBox(height: 10),
                            Text(
                              '\u{20B9}${auction.currentHighestBid.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -2,
                              ),
                            ).animate(key: ValueKey(auction.currentHighestBid))
                             .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 200.ms)
                             .shimmer(delay: 200.ms),
                            Text(
                              'Current Highest Bid',
                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.info_outline, color: AppConstants.primaryColor, size: 18),
                                const SizedBox(width: 8),
                                Text('Auction Purpose', style: TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              auction.purpose,
                              style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _statItem(Icons.timer_outlined, 'Ends In', auction.timeLeft),
                          _statItem(Icons.trending_up, 'Start Price', '\u{20B9}${auction.startingPrice}'),
                          _statItem(Icons.add_circle_outline, 'Min Inc', '\u{20B9}${auction.minBidIncrement}'),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Recent Bids',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      StreamBuilder<List<BidModel>>(
                        stream: auctionProvider.streamBids(widget.auctionId),
                        builder: (context, bidSnapshot) {
                          if (!bidSnapshot.hasData) return const SizedBox();
                          final bids = bidSnapshot.data!;
                          
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: bids.length,
                            itemBuilder: (context, index) {
                              final bid = bids[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: index == 0 ? AppConstants.primaryColor.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: index == 0 ? AppConstants.primaryColor : Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.white.withOpacity(0.1),
                                      child: const Icon(Icons.person, color: Colors.white70),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Buyer ID: ...${bid.buyerId.substring(bid.buyerId.length - 4)}',
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          DateFormat('hh:mm:ss a').format(bid.createdAt),
                                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Text(
                                      '\u{20B9}${bid.amount.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        color: index == 0 ? AppConstants.primaryColor : Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1);
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomSheet: Container(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, -5)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _bidController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'Enter bid amount...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  fillColor: Colors.white.withOpacity(0.05),
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.currency_rupee, color: AppConstants.primaryColor),
                ),
              ),
            ),
            const SizedBox(width: 16),
            StreamBuilder<AuctionModel?>(
              stream: auctionProvider.streamAuction(widget.auctionId),
              builder: (context, snapshot) {
                final auction = snapshot.data;
                return ElevatedButton(
                  onPressed: _isPlacingBid || auction == null ? null : () => _placeBid(auction.currentHighestBid, auction.minBidIncrement),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isPlacingBid 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('BID NOW', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppConstants.primaryColor, size: 24),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
