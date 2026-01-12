import 'package:geolocator/geolocator.dart';
import '../models/order_model.dart';
import '../services/location_service.dart';

class LogisticsService {
  final LocationService _locationService = LocationService();

  // Simple Greedy approach to sort orders by distance from current location
  Future<List<OrderModel>> optimizeRoute(Position currentPosition, List<OrderModel> orders) async {
    List<OrderModel> optimizedOrders = List.from(orders);
    
    // In a real TSP we'd do more, but for a few deliveries, 
    // sorting by distance from the 'current' point repeatedly works well.
    List<OrderModel> sorted = [];
    Position referencePoint = currentPosition;

    while (optimizedOrders.isNotEmpty) {
      double minDistance = double.infinity;
      OrderModel? nearestOrder;

      for (var order in optimizedOrders) {
        // We'd ideally have LatLng for the delivery address.
        // For now, if no coordinates are in the order, we move to next.
        // In a production app, we would geocode the addresses first.
        if (order.deliveryLatitude != null && order.deliveryLongitude != null) {
          double distance = Geolocator.distanceBetween(
            referencePoint.latitude,
            referencePoint.longitude,
            order.deliveryLatitude!,
            order.deliveryLongitude!,
          );

          if (distance < minDistance) {
            minDistance = distance;
            nearestOrder = order;
          }
        }
      }

      if (nearestOrder != null) {
        sorted.add(nearestOrder);
        optimizedOrders.remove(nearestOrder);
        // Move reference point to the last delivered location
        referencePoint = Position(
          latitude: nearestOrder.deliveryLatitude!,
          longitude: nearestOrder.deliveryLongitude!,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      } else {
        // If some orders couldn't be geocoded/don't have coords, just add them at the end
        sorted.addAll(optimizedOrders);
        break;
      }
    }

    return sorted;
  }
}
