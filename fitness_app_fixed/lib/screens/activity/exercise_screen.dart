import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../helpers/db_helper.dart';
import '../home/app_root.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  List<LatLng> _pathPoints = [];
  double _distance = 0;
  bool _isTracking = false;
  bool _isPaused = false;
  int? _sessionId;
  final String userId = 'user001';
  late DateTime _startTime;
  int _seconds = 0;
  Timer? _timer;
  String _mode = 'Walk';
  StreamSubscription<Position>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    await Permission.locationWhenInUse.request();
    final pos = await Geolocator.getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _currentPosition = LatLng(pos.latitude, pos.longitude);
    });
  }

  void _startSession() async {
    _startTime = DateTime.now();
    _sessionId = await DBHelper.insertSession(
      userId: userId,
      startTime: _startTime.toIso8601String(),
    );
    _pathPoints = [];
    _distance = 0;
    _seconds = 0;
    setState(() {
      _isTracking = true;
      _isPaused = false;
    });
    _listenLocation();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isTracking && !_isPaused && mounted) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  void _pauseSession() {
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeSession() {
    setState(() {
      _isPaused = false;
    });
  }

  void _stopSession() async {
    final endTime = DateTime.now().toIso8601String();
    await DBHelper.updateSession(
      sessionId: _sessionId!,
      endTime: endTime,
      distance: _distance,
    );
    _timer?.cancel();
    setState(() {
      _isTracking = false;
      _isPaused = false;
      _seconds = 0;
    });
  }

  void _listenLocation() {
    _locationSubscription?.cancel();
    _locationSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 5,
          ),
        ).listen((Position pos) async {
          if (!_isTracking || _isPaused) return;
          final newPoint = LatLng(pos.latitude, pos.longitude);
          if (_pathPoints.isNotEmpty) {
            final dist = Distance().as(
              LengthUnit.Meter,
              _pathPoints.last,
              newPoint,
            );
            _distance += dist;
          }
          if (!mounted) return;
          setState(() {
            _pathPoints.add(newPoint);
            _currentPosition = newPoint;
          });
          await DBHelper.insertGPS(
            sessionId: _sessionId!,
            lat: newPoint.latitude,
            lng: newPoint.longitude,
            timestamp: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
          );
          _mapController.move(newPoint, _mapController.camera.zoom);
        });
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get _coins =>
      (_distance / 1000) * 1.25; // 1000 steps = 1.25 coins (example)

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition ?? LatLng(35.8997, 14.5146),
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://a.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
              ),
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition!,
                      width: 48,
                      height: 48,
                      child: Image.asset(
                        'assets/icons/pin.png',
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.location_pin, size: 32),
                      ),
                    ),
                  ],
                ),
              if (_pathPoints.length > 1)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _pathPoints,
                      strokeWidth: 4,
                      color: Colors.deepPurple,
                    ),
                  ],
                ),
            ],
          ),
          // Add tracker icon button to top right
          Positioned(
            top: 40,
            right: 16,
            child: Column(
              children: [
                IconButton(
                  icon: Image.asset(
                    'assets/icons/tablet-android.png',
                    width: 32,
                    height: 32,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.watch, size: 28),
                  ),
                  onPressed: () {
                    AppRoot.switchToTab(3); // Switch to Devices tab
                  },
                  tooltip: 'Tracker',
                ),
                const SizedBox(height: 12),
                IconButton(
                  icon: Image.asset(
                    'assets/icons/gps-tracker.png',
                    width: 32,
                    height: 32,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.my_location, size: 28),
                  ),
                  onPressed: () {
                    if (_currentPosition != null) {
                      _mapController.move(_currentPosition!, 15.0);
                    }
                  },
                  tooltip: 'Center on my location',
                ),
              ],
            ),
          ),
          // Step-to-coin info bar
          Positioned(
            bottom: 180,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black87 : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.info_outline, size: 18),
                    SizedBox(width: 8),
                    Text('1000 steps = 1.25 coins'),
                  ],
                ),
              ),
            ),
          ),
          // Bottom sheet controls and stats
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Colors.black : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tabs
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.center, // Remove this
                    children: [
                      Expanded(
                        child: _TabIconLabel(
                          icon: Icons.directions_walk,
                          label: 'Walk',
                          selected: _mode == 'Walk',
                          onTap: () => setState(() => _mode = 'Walk'),
                          isDark: isDark,
                        ),
                      ),
                      Expanded(
                        child: _TabIconLabel(
                          icon: Icons.directions_run,
                          label: 'Run',
                          selected: _mode == 'Run',
                          onTap: () => setState(() => _mode = 'Run'),
                          isDark: isDark,
                        ),
                      ),
                      Expanded(
                        child: _TabIconLabel(
                          icon: Icons.directions_bike,
                          label: 'Cycle',
                          selected: _mode == 'Cycle',
                          onTap: () => setState(() => _mode = 'Cycle'),
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatBox(
                        label: 'Kilometers',
                        value: (_distance / 1000).toStringAsFixed(2),
                      ),
                      _StatBox(label: 'Time', value: _formatTime(_seconds)),
                      _StatBox(
                        label: 'Coins',
                        value: _coins.toStringAsFixed(2),
                        color: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Steps
                  Text(
                    '${(_distance * 1.312).toInt()}', // rough steps estimate
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const Text('Steps'),
                  const SizedBox(height: 18),
                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (_isTracking)
                        _CircleButton(
                          icon: Icons.stop,
                          label: 'End Activity',
                          color: Colors.red,
                          onTap: _stopSession,
                        ),
                      GestureDetector(
                        onTap: () {
                          if (!_isTracking) {
                            _startSession();
                          } else if (_isPaused) {
                            _resumeSession();
                          } else {
                            _pauseSession();
                          }
                        },
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.green,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 32,
                              ),
                              SizedBox(height: 2),
                              Text(
                                'GO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      _CircleButton(
                        icon: Icons.camera_alt,
                        label: 'Photo',
                        color: Colors.grey[800],
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _StatBox({required this.label, required this.value, this.color});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color:
                color ??
                (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;
  const _CircleButton({
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 24,
            backgroundColor: color ?? Colors.grey[800],
            child: Icon(icon, color: Colors.white),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _TabIconLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;
  const _TabIconLabel({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6), // was 12
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 8,
        ), // was 10
        decoration: BoxDecoration(
          color: selected
              ? Colors.green
              : (isDark ? Colors.grey[900] : Colors.grey[200]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black87),
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black87),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
