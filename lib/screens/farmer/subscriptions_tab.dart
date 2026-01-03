import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../models/subscription_model.dart';

class FarmerSubscriptionsTab extends StatelessWidget {
  const FarmerSubscriptionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    if (user == null) return const Center(child: Text('Error: Not logged in'));

    return Scaffold(
      appBar: AppBar(title: const Text('Buyer Subscriptions')),
      body: StreamBuilder<List<SubscriptionModel>>(
        stream: DatabaseService().getFarmerSubscriptions(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No subscriptions yet.'));
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
                  subtitle: Text('${sub.quantityPerDay} units daily • Status: ${sub.status}'),
                  trailing: Text('₹${sub.price * sub.quantityPerDay}/day'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
