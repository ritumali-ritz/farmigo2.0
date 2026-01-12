import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/auction_model.dart';
import '../../models/product_model.dart';
import '../../providers/auction_provider.dart';
import '../../utils/constants.dart';

class StartAuctionDialog extends StatefulWidget {
  final ProductModel product;
  const StartAuctionDialog({super.key, required this.product});

  @override
  State<StartAuctionDialog> createState() => _StartAuctionDialogState();
}

class _StartAuctionDialogState extends State<StartAuctionDialog> {
  final TextEditingController _basePriceController = TextEditingController();
  final TextEditingController _incrementController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  int _durationHours = 2;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _basePriceController.text = widget.product.price.toString();
    _incrementController.text = "10";
    _purposeController.text = "Bulk clearance of fresh ${widget.product.name}";
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.gavel_rounded, color: AppConstants.primaryColor),
          const SizedBox(width: 10),
          const Text('Start Auction'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product: ${widget.product.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _basePriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Starting Price (\u{20B9})',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_rupee),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _incrementController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Min Bid Increment (\u{20B9})',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.add_circle_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _purposeController,
              decoration: const InputDecoration(
                labelText: 'Auction Purpose / Note',
                hintText: 'e.g. Bulk sale for restaurant owners',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.info_outline),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Duration (Hours)', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _durationHours.toDouble(),
                    min: 1,
                    max: 24,
                    divisions: 23,
                    label: '$_durationHours h',
                    onChanged: (val) => setState(() => _durationHours = val.toInt()),
                    activeColor: AppConstants.primaryColor,
                  ),
                ),
                Text('$_durationHours hrs', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryColor),
          child: _isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('START LIVE NOW', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void _submit() async {
    final basePrice = double.tryParse(_basePriceController.text);
    final increment = double.tryParse(_incrementController.text);
    final purpose = _purposeController.text.trim();

    if (basePrice == null || increment == null || purpose.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final auction = AuctionModel(
        id: '', // Supabase will generate
        farmerId: widget.product.farmerId,
        productId: widget.product.id,
        startingPrice: basePrice,
        currentHighestBid: basePrice,
        minBidIncrement: increment,
        startTime: DateTime.now(),
        endTime: DateTime.now().add(Duration(hours: _durationHours)),
        status: 'active',
        purpose: purpose,
        createdAt: DateTime.now(),
      );

      await Provider.of<AuctionProvider>(context, listen: false).startAuction(auction);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Auction started successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
