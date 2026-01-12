import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../models/product_model.dart';
import '../../utils/constants.dart';
import 'add_product_screen.dart';
import '../../widgets/start_auction_dialog.dart';

class FarmerProductsTab extends StatelessWidget {
  const FarmerProductsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    if (user == null) return const Center(child: Text('Error: Farmer not logged in'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
            },
          ),
        ],
      ),
      body: StreamBuilder<List<ProductModel>>(
        stream: DatabaseService().getFarmerProducts(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products added yet. Click + to add.'));
          }

          final products = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                child: ListTile(
                  leading: product.images.isNotEmpty
                      ? CircleAvatar(
                          radius: 25,
                          backgroundImage: product.images[0].startsWith('http')
                              ? NetworkImage(product.images[0])
                              : AssetImage(product.images[0]) as ImageProvider,
                        )
                      : const CircleAvatar(
                          radius: 25,
                          child: Icon(Icons.image_outlined),
                        ),
                  title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('₹${product.price}/${product.unit} • Stock: ${product.stockQuantity}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: product.isAvailable,
                        onChanged: (val) {
                          DatabaseService().updateProduct(ProductModel(
                            id: product.id,
                            farmerId: product.farmerId,
                            name: product.name,
                            description: product.description,
                            price: product.price,
                            unit: product.unit,
                            stockQuantity: product.stockQuantity,
                            category: product.category,
                            images: product.images,
                            isAvailable: val,
                            isDailySubscriptionAvailable: product.isDailySubscriptionAvailable,
                          ));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.gavel_rounded, color: AppConstants.primaryColor),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => StartAuctionDialog(product: product),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, product.id),
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

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              DatabaseService().deleteProduct(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
