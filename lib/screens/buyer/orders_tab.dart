import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../models/order_model.dart';
import '../../utils/constants.dart';

class BuyerOrdersTab extends StatelessWidget {
  const BuyerOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    if (user == null) {
      return const Center(child: Text('Login to view orders'));
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Orders'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Past'),
            ],
            indicatorColor: AppConstants.primaryColor,
            labelColor: AppConstants.primaryColor,
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: TabBarView(
          children: [
            _OrderList(userId: user.uid, type: 'Active'),
            _OrderList(userId: user.uid, type: 'Past'),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final String userId;
  final String type;

  const _OrderList({required this.userId, required this.type});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<OrderModel>>(
      stream: DatabaseService().getBuyerOrders(userId, type: type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('No $type orders found', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          );
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
                        Text('Order #${order.id.length > 5 ? order.id.substring(0, 5) : order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        _buildStatusChip(order.status),
                      ],
                    ),
                    const SizedBox(height: 8),
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
                        const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('₹${order.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppConstants.primaryColor)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Address: ${order.deliveryAddress}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Pending': color = Colors.orange; break;
      case 'Accepted': color = Colors.blue; break;
      case 'Shipped': color = Colors.purple; break;
      case 'Delivered': color = Colors.green; break;
      case 'Cancelled': color = Colors.red; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color)),
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
