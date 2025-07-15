import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SessionMapScreen extends StatelessWidget {
  final List<LatLng> route;
  const SessionMapScreen({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Route Map")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: route.isNotEmpty ? route.first : const LatLng(0, 0),
          zoom: 16,
        ),
        polylines: {
          Polyline(
            polylineId: const PolylineId("route"),
            points: route,
            color: Colors.blue,
            width: 5,
          ),
        },
        markers: {
          if (route.isNotEmpty)
            Marker(markerId: const MarkerId("start"), position: route.first),
          if (route.length > 1)
            Marker(markerId: const MarkerId("end"), position: route.last),
        },
      ),
    );
  }
}
