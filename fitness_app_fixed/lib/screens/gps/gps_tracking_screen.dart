import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/firestore_service.dart';
import '../../utils/snackbar_helper.dart';

class GpsTrackingScreen extends StatefulWidget {
  const GpsTrackingScreen({super.key});

  @override
  State<GpsTrackingScreen> createState() => _GpsTrackingScreenState();
}

class _GpsTrackingScreenState extends State<GpsTrackingScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  List<LatLng> _path = [];
  StreamSubscription<Position>? _positionStream;
  double _distanceMeters = 0.0;
  bool _tracking = false;

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  void _startTracking() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied)
      return;

    _path.clear();
    _distanceMeters = 0;
    _tracking = true;

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position position) {
          final current = LatLng(position.latitude, position.longitude);
          setState(() {
            if (_path.isNotEmpty) {
              _distanceMeters += Geolocator.distanceBetween(
                _path.last.latitude,
                _path.last.longitude,
                current.latitude,
                current.longitude,
              );
            }
            _path.add(current);
          });
        });
  }

  void _stopTracking() async {
    _positionStream?.cancel();
    setState(() {
      _tracking = false;
    });

    if (_path.isEmpty) {
      SnackbarHelper.showInfo(context, 'No location data to save');
      setState(() {});
      return;
    }

    // Prepare GPS data for save/upload
    final gpsData = {
      'userId': 'user123', // Replace with actual user id from FirebaseAuth
      'latitude': _path.last.latitude,
      'longitude': _path.last.longitude,
      'distance': _distanceMeters,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Upload to Firestore
    try {
      await FirestoreService().uploadGpsData(gpsData);
      SnackbarHelper.showSuccess(context, 'GPS data synced to cloud!');
    } catch (e) {
      SnackbarHelper.showError(context, 'Failed to sync GPS data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GPS Tracking')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(28.644800, 77.216721), // Default
              zoom: 15,
            ),
            myLocationEnabled: true,
            polylines: {
              if (_path.length > 1)
                Polyline(
                  polylineId: const PolylineId('path'),
                  points: _path,
                  color: Colors.blue,
                  width: 5,
                ),
            },
            onMapCreated: (GoogleMapController controller) {
              _mapController.complete(controller);
            },
          ),
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(blurRadius: 4, color: Colors.black12),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Distance:  [0m${(_distanceMeters / 1000).toStringAsFixed(2)} km',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Start'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(120, 48),
                            ),
                            onPressed: _tracking ? null : _startTracking,
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.stop),
                            label: const Text('Stop'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(120, 48),
                            ),
                            onPressed: _tracking ? _stopTracking : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
