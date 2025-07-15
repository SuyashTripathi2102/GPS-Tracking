import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/database_helper.dart';
import 'dart:async';
import '../../utils/notification_helper.dart';

class GpsTrackingScreen extends StatefulWidget {
  const GpsTrackingScreen({super.key});

  @override
  State<GpsTrackingScreen> createState() => _GpsTrackingScreenState();
}

class _GpsTrackingScreenState extends State<GpsTrackingScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  bool tracking = false;
  StreamSubscription<Position>? _positionStream;
  List<LatLng> _route = [];
  double _totalDistance = 0;
  DateTime? _startTime;

  Future<void> _startTracking() async {
    var permission = await Permission.location.request();
    if (!permission.isGranted) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _startTime = DateTime.now();
    _route = [LatLng(position.latitude, position.longitude)];
    _currentPosition = _route.first;
    tracking = true;

    setState(() {});

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 10,
          ),
        ).listen((Position pos) {
          final newPoint = LatLng(pos.latitude, pos.longitude);
          _route.add(newPoint);

          if (_route.length >= 2) {
            final last = _route[_route.length - 2];
            _totalDistance += Geolocator.distanceBetween(
              last.latitude,
              last.longitude,
              newPoint.latitude,
              newPoint.longitude,
            );
          }

          setState(() {
            _currentPosition = newPoint;
          });

          _mapController?.animateCamera(CameraUpdate.newLatLng(newPoint));
        });
  }

  Future<void> _stopTracking() async {
    _positionStream?.cancel();
    final duration = DateTime.now().difference(_startTime!).inSeconds;
    final routeString = _route
        .map((p) => '${p.latitude},${p.longitude}')
        .join('|');
    double distanceKm = _totalDistance / 1000;
    double co2 = distanceKm * 150; // in grams
    double calories = distanceKm * 55;
    print("Calories: $calories");
    print("CO₂ Saved: $co2 g");
    await DatabaseHelper.instance.insertGpsSession(
      distance: distanceKm,
      duration: duration,
      route: routeString,
      co2: co2,
      calories: calories,
    );
    // Trigger goal achievement notification if distance >= 5km
    if (distanceKm >= 5) {
      // ignore: use_build_context_synchronously
      await NotificationHelper.showGoalAchievement(goal: '5km walk');
    }
    setState(() {
      tracking = false;
      _route.clear();
      _totalDistance = 0;
      _startTime = null;
      _currentPosition = null;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Session saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Outdoor Activity')),
      body: tracking && _currentPosition != null
          ? Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: 16,
                  ),
                  myLocationEnabled: true,
                  onMapCreated: (controller) => _mapController = controller,
                ),
                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: ElevatedButton(
                    onPressed: _stopTracking,
                    child: const Text('Stop & Save'),
                  ),
                ),
              ],
            )
          : Center(
              child: ElevatedButton(
                onPressed: _startTracking,
                child: const Text('GO'),
              ),
            ),
    );
  }
}
