import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../services/notification_service.dart';
import '../../models/order_model.dart';
import '../../utils/constants.dart';
import '../../services/tracking_service.dart';
import '../../services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../../services/logistics_service.dart';

class FarmerOrdersTab extends StatefulWidget {
  const FarmerOrdersTab({super.key});

  @override
  State<FarmerOrdersTab> createState() => _FarmerOrdersTabState();
}

class _FarmerOrdersTabState extends State<FarmerOrdersTab> {
  final TrackingService _trackingService = TrackingService();
  final LocationService _locationService = LocationService();
  final LogisticsService _logisticsService = LogisticsService();
  StreamSubscription<Position>? _locationSubscription;
  String? _trackingOrderId;
  List<OrderModel>? _optimizedOrders;

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  void _optimizeAndSort(List<OrderModel> orders) async {
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      final sorted = await _logisticsService.optimizeRoute(position, orders);
      setState(() {
        _optimizedOrders = sorted;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Routes optimized for the nearest deliveries!')),
      );
    }
  }

  void _startTracking(String orderId) async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        await _trackingService.startDelivery(orderId, position);
        setState(() {
          _trackingOrderId = orderId;
        });

        // Start listening to location updates
        _locationSubscription = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position position) {
          _trackingService.updateLiveLocation(orderId, position);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Delivery started. Live tracking active!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting delivery: $e')),
      );
    }
  }

  void _stopTracking(String orderId) async {
    await _locationSubscription?.cancel();
    await _trackingService.completeDelivery(orderId);
    setState(() {
      _trackingOrderId = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Delivery completed!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    if (user == null) return const Center(child: Text('Error: Not logged in'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: DatabaseService().getFarmerOrders(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders received yet.'));
          }

          final orders = _optimizedOrders ?? snapshot.data!;
          final activeOrders = snapshot.data!.where((o) => o.status == 'Accepted' || o.status == 'Shipped').toList();

          return Column(
            children: [
              if (activeOrders.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _optimizeAndSort(activeOrders),
                      icon: const Icon(Icons.bolt, color: Colors.orange),
                      label: const Text('Optimize My Route'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Order #${order.id.substring(0, 5)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                _buildStatusDropdown(context, order),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Customer: ${order.buyerName} (${order.buyerPhone})', style: const TextStyle(fontWeight: FontWeight.w500)),
                            Text(DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            const Divider(),
                            ...order.items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${item.productName} x ${item.quantity}'),
                                  Text('₹${item.price * item.quantity}'),
                                ],
                              ),
                            )),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total to collect', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('₹${order.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppConstants.primaryColor)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Address: ${order.deliveryAddress}', style: const TextStyle(fontSize: 12)),
                            if (order.status == 'Accepted' || order.status == 'Shipped') ...[
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _trackingOrderId == order.id
                                      ? () => _stopTracking(order.id)
                                      : () => _startTracking(order.id),
                                  icon: Icon(_trackingOrderId == order.id ? Icons.check_circle : Icons.local_shipping),
                                  label: Text(_trackingOrderId == order.id ? 'Complete Delivery' : 'Start Delivery'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _trackingOrderId == order.id ? Colors.green : AppConstants.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusDropdown(BuildContext context, OrderModel order) {
    return DropdownButton<String>(
      value: order.status,
      underline: Container(),
      icon: const Icon(Icons.arrow_drop_down, color: AppConstants.primaryColor),
      onChanged: (String? newValue) {
        if (newValue != null) {
          DatabaseService().updateOrderStatus(order.id, newValue);
          NotificationService().sendNotification(
            order.buyerId, 
            'Order Status Updated', 
            'Your order #${order.id.substring(0, 5)} is now $newValue'
          );
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order status updated to $newValue')));
        }
      },
      items: AppConstants.orderStatuses.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: TextStyle(color: _getStatusColor(value), fontWeight: FontWeight.bold, fontSize: 12)),
        );
      }).toList(),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending': return Colors.orange;
      case 'Accepted': return Colors.blue;
      case 'Shipped': return Colors.purple;
      case 'Delivered': return Colors.green;
      case 'Cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}
