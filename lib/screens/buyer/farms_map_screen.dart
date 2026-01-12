import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import 'product_detail_screen.dart';

class FarmsMapScreen extends StatefulWidget {
  const FarmsMapScreen({super.key});

  @override
  State<FarmsMapScreen> createState() => _FarmsMapScreenState();
}

class _FarmsMapScreenState extends State<FarmsMapScreen> {
  GoogleMapController? _mapController;
  final DatabaseService _dbService = DatabaseService();

  // Default position: India center
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(20.5937, 78.9629),
    zoom: 5,
    tilt: 45, // 3D Tilt
  );

  Set<Marker> _buildMarkers(List<UserModel> farmers) {
    return farmers.where((f) => f.latitude != null && f.longitude != null).map((farmer) {
      return Marker(
        markerId: MarkerId(farmer.uid),
        position: LatLng(farmer.latitude!, farmer.longitude!),
        infoWindow: InfoWindow(
          title: farmer.name,
          snippet: farmer.address ?? 'Organic Farm',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        onTap: () {
          // Could navigate to a farm details page or show a bottom sheet
        },
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Discover Local Farms",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: _dbService.getFarmers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final farmers = snapshot.data ?? [];
          final markers = _buildMarkers(farmers);

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: _initialPosition,
                onMapCreated: (controller) => _mapController = controller,
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                zoomControlsEnabled: false,
                tiltGesturesEnabled: true,
                rotateGesturesEnabled: true,
              ),
              
              // Bottom Card for Farm List (Horizontal)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 120,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: farmers.length,
                    itemBuilder: (context, index) {
                      final farmer = farmers[index];
                      return GestureDetector(
                        onTap: () {
                          if (farmer.latitude != null) {
                            _mapController?.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: LatLng(farmer.latitude!, farmer.longitude!),
                                  zoom: 16,
                                  tilt: 45,
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 250,
                          margin: const EdgeInsets.only(right: 16),
                          padding: const EdgeInsets.all(16),
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
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppConstants.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.storefront_rounded, color: AppConstants.primaryColor),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      farmer.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      farmer.address ?? "Organic Farm",
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
