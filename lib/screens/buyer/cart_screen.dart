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

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: cart.items.isEmpty
          ? const Center(child: Text('Your cart is empty!'))
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
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _addressController,
                              decoration: const InputDecoration(hintText: 'Enter address or fetch live'),
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
                          const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('₹${cart.totalAmount}', style: const TextStyle(fontSize: 20, color: AppConstants.primaryColor, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _placeOrder(context, cart, userProvider),
                        child: const Text('Place Order (COD)'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _placeOrder(BuildContext context, CartProvider cart, UserProvider userProvider) async {
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
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order placed successfully!')));
  }
}
