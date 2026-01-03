import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/cart_model.dart';
import '../models/subscription_model.dart';
import '../models/banner_model.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Products
  Future<void> addProduct(ProductModel product) async {
    // Note: Supabase generates ID if not provided, but model has ID. 
    // If ID is empty/new, we might want to let Supabase generate it, but simplified here to upsert or just insert with generated ID logic elsewhere.
    // Assuming product.id is already generated or we don't care about it matching exactly if it's new.
    // Actually, usually we omit ID for new inserts to let DB generate UUID.
    final data = product.toMap();
    if (product.id.isEmpty) {
      data.remove('id');
    }
    await _supabase.from('products').insert(data);
  }

  Future<void> updateProduct(ProductModel product) async {
    await _supabase.from('products').update(product.toMap()).eq('id', product.id);
  }

  Future<void> deleteProduct(String productId) async {
    await _supabase.from('products').delete().eq('id', productId);
  }

  Stream<List<ProductModel>> getFarmerProducts(String farmerId) {
    return _supabase
        .from('products')
        .stream(primaryKey: ['id'])
        .eq('farmer_id', farmerId)
        .map((data) => data
            .map((map) => ProductModel.fromMap(map, map['id']))
            .toList());
  }

  Stream<List<ProductModel>> getAllProducts({String? category}) {
    // Stream all available products first
    return _supabase
        .from('products')
        .stream(primaryKey: ['id'])
        .eq('is_available', true)
        .map((data) {
          var products = data.map((map) => ProductModel.fromMap(map, map['id'])).toList();
          
          if (category != null && category != 'All') {
            products = products.where((p) => p.category == category).toList();
          }
          return products;
        });
  }

  // Orders
  Future<void> placeOrder(OrderModel order) async {
    print('DEBUG: Placing order for farmer ${order.farmerId} with status ${order.status}');
    final data = order.toMap();
    if (order.id.isEmpty) {
      data.remove('id');
    }
    await _supabase.from('orders').insert(data);
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _supabase.from('orders').update({'status': status}).eq('id', orderId);
  }

  Stream<List<OrderModel>> getFarmerOrders(String farmerId) {
    return _supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('farmer_id', farmerId)
        .map((data) {
          print('DEBUG: Farmer Orders Snapshot: ${data.length} docs found for $farmerId');
          var orders = data
            .map((map) => OrderModel.fromMap(map, map['id']))
            .toList();
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return orders;
        });
  }

  Stream<List<OrderModel>> getBuyerOrders(String buyerId, {String type = 'Active'}) {
    return _supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('buyer_id', buyerId)
        .map((data) {
            print('DEBUG: Buyer Orders Snapshot: ${data.length} total orders found for $buyerId');
            var orders = data
            .map((map) => OrderModel.fromMap(map, map['id']))
            .where((order) {
              print('DEBUG: Filtering order ${order.id} status: ${order.status} for type: $type');
              if (type == 'Active') {
                return ['Pending', 'Accepted', 'Shipped'].contains(order.status);
              } else {
                return ['Delivered', 'Cancelled'].contains(order.status);
              }
            })
            .toList();
            
            orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return orders;
        });
  }

  // Subscriptions
  Future<void> addSubscription(SubscriptionModel sub) async {
    final data = sub.toMap();
    if (sub.id.isEmpty) {
      data.remove('id');
    }
    await _supabase.from('subscriptions').insert(data);
  }

  Future<void> updateSubscriptionStatus(String subId, String status) async {
    await _supabase.from('subscriptions').update({'status': status}).eq('id', subId);
  }

  Stream<List<SubscriptionModel>> getFarmerSubscriptions(String farmerId) {
    return _supabase
        .from('subscriptions')
        .stream(primaryKey: ['id'])
        .eq('farmer_id', farmerId)
        .map((data) => data
            .map((map) => SubscriptionModel.fromMap(map, map['id']))
            .toList());
  }

  Stream<List<SubscriptionModel>> getBuyerSubscriptions(String buyerId) {
    return _supabase
        .from('subscriptions')
        .stream(primaryKey: ['id'])
        .eq('buyer_id', buyerId)
        .map((data) => data
            .map((map) => SubscriptionModel.fromMap(map, map['id']))
            .toList());
  }

  // Cart (Stored in Supabase 'carts' table which behaves like a document store here)
  Future<void> updateCart(String userId, List<CartItem> items) async {
    // Upsert the cart row for this user.
    // Assuming 'id' of the cart row is the userId, or there is a 'userId' column unique constraint.
    // Based on previous code: .doc(userId).set(...) implies userId is the key.
    // Supabase table 'carts' should have primary key 'id' = userId or distinct 'user_id' column.
    // Code below assumes table 'carts' has 'id' (text) as primary key which matches userId.
    
    await _supabase.from('carts').upsert({
      'id': userId,
      'items': items.map((e) => e.toMap()).toList(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<CartItem>> getCart(String userId) async {
    try {
      final data = await _supabase.from('carts').select().eq('id', userId).maybeSingle();
      if (data != null) {
        List items = data['items'] ?? [];
        return items.map((e) => CartItem.fromMap(e)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching cart: $e');
      return [];
    }
  }

  // Banners
  Stream<List<BannerModel>> getBanners() {
    return _supabase.from('banners').stream(primaryKey: ['id']).map((data) => data
        .map((map) => BannerModel.fromMap(map, map['id']))
        .toList());
  }
}

