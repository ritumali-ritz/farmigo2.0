import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../services/notification_service.dart';
import '../../models/order_model.dart';
import '../../utils/constants.dart';

class FarmerOrdersTab extends StatelessWidget {
  const FarmerOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    if (user == null) return const Center(child: Text('Error: Not logged in'));

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Orders')),
      body: StreamBuilder<List<OrderModel>>(
        stream: DatabaseService().getFarmerOrders(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders received yet.'));
          }

          final orders = snapshot.data!;
          return ListView.builder(
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
                    ],
                  ),
                ),
              );
            },
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
