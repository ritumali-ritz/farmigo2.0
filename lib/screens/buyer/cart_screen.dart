import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../services/database_service.dart';
import '../../services/location_service.dart';
import '../../services/notification_service.dart';
import '../../models/order_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/language_provider.dart';
import 'dart:ui';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _addressController = TextEditingController();
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null && user.address != null) {
      _addressController.text = user.address!;
    }
  }

  Future<void> _fetchLocation() async {
    setState(() => _isLocating = true);
    try {
      Position? position = await LocationService().getCurrentLocation();
      if (position != null) {
        String address = await LocationService().getAddressFromLatLng(position.latitude, position.longitude);
        setState(() {
          _addressController.text = address;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLocating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(langProvider.translate('cart'))),
      body: cart.items.isEmpty
          ? Center(child: Text(langProvider.translate('cart_empty')))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items.values.toList()[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: item.productImage.isNotEmpty 
                              ? (item.productImage.startsWith('http') 
                                  ? NetworkImage(item.productImage) 
                                  : AssetImage(item.productImage) as ImageProvider)
                              : null,
                          child: item.productImage.isEmpty ? const Icon(Icons.image_outlined) : null,
                        ),
                        title: Text(item.productName),
                        subtitle: Text('₹${item.price} x ${item.quantity}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(onPressed: () => cart.removeSingleItem(item.productId), icon: const Icon(Icons.remove)),
                            IconButton(onPressed: () => cart.removeItem(item.productId), icon: const Icon(Icons.delete, color: Colors.red)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                    boxShadow: [BoxShadow(color: isDark ? Colors.black26 : Colors.black12, blurRadius: 10)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(langProvider.translate('delivery_address'), style: const TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _addressController,
                              decoration: InputDecoration(hintText: langProvider.translate('enter_address_hint')),
                            ),
                          ),
                          IconButton(
                            onPressed: _isLocating ? null : _fetchLocation,
                            icon: _isLocating 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.my_location, color: AppConstants.primaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${langProvider.translate('total')}:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('₹${cart.totalAmount}', style: const TextStyle(fontSize: 20, color: AppConstants.primaryColor, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _placeOrder(context, cart, userProvider, langProvider),
                        child: Text(langProvider.translate('place_order_cod')),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

   void _placeOrder(BuildContext context, CartProvider cart, UserProvider userProvider, LanguageProvider langProvider) async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide an address')));
      return;
    }

    if (userProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login to place order')));
      return;
    }

    // Creating order
    // In a real app, you might want to group items by farmerId if there are multiple farmers
    // For this simple ver, we'll assume products can be from any farmer.
    // If multiple farmers, we should create multiple orders.
    
    Map<String, List<OrderItem>> farmerOrders = {};
    for (var item in cart.items.values) {
      if (!farmerOrders.containsKey(item.farmerId)) {
        farmerOrders[item.farmerId] = [];
      }
      farmerOrders[item.farmerId]!.add(OrderItem(
        productId: item.productId,
        productName: item.productName,
        price: item.price,
        quantity: item.quantity,
        unit: item.unit,
      ));
    }

    for (var entry in farmerOrders.entries) {
      double total = entry.value.fold(0, (sum, item) => sum + (item.price * item.quantity));
      OrderModel order = OrderModel(
        id: '',
        buyerId: userProvider.user!.uid,
        farmerId: entry.key,
        items: entry.value,
        totalAmount: total,
        status: 'Pending',
        deliveryAddress: _addressController.text,
        createdAt: DateTime.now(),
        buyerName: userProvider.user!.name,
        buyerPhone: userProvider.user!.phone,
      );
      await DatabaseService().placeOrder(order);
      // Notify Farmer (In-app feed)
      await NotificationService().sendNotification(
          entry.key, 'New Order Received', 'You have a new order from ${userProvider.user!.name}');
      
      // Notify Buyer (Local Push Notification Simulation)
      await NotificationService().showLocalNotification(
        title: 'Order Placed Successfully! 🚀',
        body: 'Your order for ${entry.value.length} items has been sent. Track it in My Orders.',
      );
    }

    cart.clear();
    if (context.mounted) {
      _showSuccessDialog(context, langProvider);
    }
  }

  void _showSuccessDialog(BuildContext context, LanguageProvider langProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: AppConstants.primaryColor,
                      size: 60,
                    ),
                  ).animate().scale(duration: 500.ms, curve: Curves.elasticOut).shimmer(delay: 500.ms),
                  const SizedBox(height: 24),
                  Text(
                    langProvider.translate('order_placed'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                  const SizedBox(height: 12),
                  Text(
                    langProvider.translate('order_success_msg'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Go back home
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 0,
                      ),
                      child: Text(
                        langProvider.translate('awesome'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.9, 0.9)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
