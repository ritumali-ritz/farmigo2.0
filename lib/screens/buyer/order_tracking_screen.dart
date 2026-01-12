import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/order_model.dart';
import '../../services/tracking_service.dart';
import '../../utils/constants.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  final String farmerName;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    required this.farmerName,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  GoogleMapController? _mapController;
  final TrackingService _trackingService = TrackingService();
  Marker? _farmerMarker;
  
  // Default position if no location yet (India center or similar)
  static const LatLng _center = LatLng(20.5937, 78.9629);

  void _updateMarker(double lat, double lng) {
    setState(() {
      _farmerMarker = Marker(
        markerId: const MarkerId('farmer_location'),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: "${widget.farmerName} is here"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      );
    });

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, lng),
          zoom: 17,
          tilt: 45,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Track Delivery", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _trackingService.streamOrderLocation(widget.orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final orderData = snapshot.data;
          if (orderData == null) {
            return const Center(child: Text("Order not found"));
          }

          final lat = orderData['delivery_latitude'] as double?;
          final lng = orderData['delivery_longitude'] as double?;
          final status = orderData['delivery_status'] as String?;

          if (lat != null && lng != null) {
            // Update marker position whenever stream emits
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateMarker(lat, lng);
            });
          }

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: lat != null && lng != null ? LatLng(lat, lng) : _center,
                  zoom: 15,
                  tilt: 45,
                ),
                onMapCreated: (controller) => _mapController = controller,
                markers: _farmerMarker != null ? {_farmerMarker!} : {},
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                tiltGesturesEnabled: true,
              ),
              
              // Status Overlay
              Positioned(
                bottom: 24,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppConstants.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.local_shipping_rounded, color: AppConstants.primaryColor),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getStatusText(status),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                Text(
                                  "Delivery by ${widget.farmerName}",
                                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (status == 'on_the_way') ...[
                        const SizedBox(height: 20),
                        const LinearProgressIndicator(
                          backgroundColor: Color(0xFFE5E7EB),
                          valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'on_the_way': return "On the way!";
      case 'picking_up': return "Picking up items...";
      case 'delivered': return "Delivered!";
      default: return "Order is being prepared";
    }
  }
}
