import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';

class TrackingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Update order status and initial location
  Future<void> startDelivery(String orderId, Position position) async {
    await _supabase.from('orders').update({
      'delivery_status': 'on_the_way',
      'delivery_latitude': position.latitude,
      'delivery_longitude': position.longitude,
    }).eq('id', orderId);
  }

  // Update farmer's live location during delivery
  Future<void> updateLiveLocation(String orderId, Position position) async {
    await _supabase.from('orders').update({
      'delivery_latitude': position.latitude,
      'delivery_longitude': position.longitude,
    }).eq('id', orderId);
  }

  // Mark order as delivered
  Future<void> completeDelivery(String orderId) async {
    await _supabase.from('orders').update({
      'delivery_status': 'delivered',
      'status': 'Delivered', // Main order status
    }).eq('id', orderId);
  }

  // Stream live location for a specific order (for Buyer)
  Stream<Map<String, dynamic>> streamOrderLocation(String orderId) {
    return _supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', orderId)
        .map((data) => data.first);
  }
}
