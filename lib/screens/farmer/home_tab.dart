import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../models/order_model.dart';
import '../../utils/constants.dart';
import 'add_product_screen.dart';

class FarmerHomeTab extends StatelessWidget {
  const FarmerHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    if (user == null) return const Center(child: Text('Not logged in'));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(gradient: AppConstants.backgroundGradient),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trending Farmer Header
              Stack(
                children: [
                  Container(
                    height: 140,
                    decoration: const BoxDecoration(
                      gradient: AppConstants.primaryGradient,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Namaste,',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300, color: Colors.white70),
                                  ),
                                  Text(
                                    '${user.name}!',
                                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.add_business_outlined, color: Colors.white),
                                  onPressed: () {
                                     Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

            // Stats Cards
            StreamBuilder<List<OrderModel>>(
              stream: DatabaseService().getFarmerOrders(user.uid),
              builder: (context, snapshot) {
                int pendingCount = 0;
                double totalEarned = 0;
                if (snapshot.hasData) {
                  pendingCount = snapshot.data!.where((o) => o.status == 'Pending').length;
                  totalEarned = snapshot.data!
                      .where((o) => o.status == 'Delivered')
                      .fold(0, (sum, item) => sum + item.totalAmount);
                }

                return Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        'Pending Orders',
                        pendingCount.toString(),
                        Icons.local_shipping_outlined,
                        Colors.orange.shade100,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _statCard(
                        'Total Earned',
                        '₹${totalEarned.toInt()}',
                        Icons.payments_outlined,
                        Colors.green.shade100,
                        Colors.green,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),
            const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                _quickActionButton(
                  context,
                  'Add Product',
                  Icons.add,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen())),
                ),
                const SizedBox(width: 16),
                _quickActionButton(
                  context,
                  'Insights',
                  Icons.analytics_outlined,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Insights feature coming soon!')),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),
            const Text('Recent Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            StreamBuilder<List<OrderModel>>(
              stream: DatabaseService().getFarmerOrders(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No orders yet.');
                }
                final orders = snapshot.data!.take(5).toList();
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Order #${order.id.length > 5 ? order.id.substring(0, 5) : order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(order.buyerName, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                          _statusChip(order.status),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }

  Widget _headerIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Icon(icon, color: AppConstants.primaryColor),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _quickActionButton(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppConstants.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color = Colors.grey;
    if (status == 'Delivered') color = Colors.green;
    if (status == 'Pending') color = Colors.orange;
    if (status == 'Accepted') color = Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
