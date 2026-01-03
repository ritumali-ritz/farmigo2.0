import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../models/subscription_model.dart';
import '../../utils/constants.dart';

class BuyerSubscriptionsTab extends StatelessWidget {
  const BuyerSubscriptionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    if (user == null) {
      return const Center(child: Text('Login to view subscriptions'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Subscriptions')),
      body: StreamBuilder<List<SubscriptionModel>>(
        stream: DatabaseService().getBuyerSubscriptions(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No active subscriptions.'));
          }

          final subs = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subs.length,
            itemBuilder: (context, index) {
              final sub = subs[index];
              return Card(
                child: ListTile(
                  title: Text(sub.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${sub.quantityPerDay} units daily • From ${DateFormat('dd MMM').format(sub.startDate)}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('₹${sub.price * sub.quantityPerDay}/day', style: const TextStyle(fontWeight: FontWeight.bold, color: AppConstants.primaryColor)),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => _toggleStatus(context, sub),
                        child: Text(
                          sub.status == 'Active' ? 'Stop' : 'Resume',
                          style: TextStyle(color: sub.status == 'Active' ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ),
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

  void _toggleStatus(BuildContext context, SubscriptionModel sub) async {
    String newStatus = sub.status == 'Active' ? 'Stopped' : 'Active';
    await DatabaseService().updateSubscriptionStatus(sub.id, newStatus);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Subscription $newStatus')));
  }
}
