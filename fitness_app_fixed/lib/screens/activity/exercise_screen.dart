import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/db/db_helper.dart';
import '../home/app_root.dart';
import 'dart:ui' as ui;

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
  double _mapRotation = 0.0;
  bool _mapReady = false;

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
    print('Stopping session. Distance: $_distance');
    if (_distance == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No movement detected. Session not saved.'),
          ),
        );
      }
      _timer?.cancel();
      setState(() {
        _isTracking = false;
        _isPaused = false;
        _seconds = 0;
      });
      return;
    }
    final endTime = DateTime.now().toIso8601String();
    await DBHelper.insertSession({
      'distance': _distance / 1000, // convert meters to km
      'timestamp': endTime,
      'status': 'Completed',
    });
    final all = await DBHelper.getAllSessions();
    print('All sessions after insert: $all');
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
          print('Location update received: ${pos.latitude}, ${pos.longitude}');
          if (!_isTracking || _isPaused) return;
          final newPoint = LatLng(pos.latitude, pos.longitude);
          if (_pathPoints.isNotEmpty) {
            final dist = Distance().as(
              LengthUnit.Meter,
              _pathPoints.last,
              newPoint,
            );
            _distance += dist;
            print('Distance updated: $_distance');
          }
          if (!mounted) return;
          setState(() {
            _pathPoints.add(newPoint);
            _currentPosition = newPoint;
          });
          if (_mapReady) {
            _mapController.move(newPoint, _mapController.camera.zoom);
          }
        });
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get co2Value => _distance * 0.21; // Example: 0.21 kg CO2 per km

  Widget _compassButton(String label, double degrees) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: () {
          _mapController.rotate(degrees * 3.1415926535 / 180);
        },
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.8),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pastelGreen = const Color(0xFF4CAF50);
    final pastelRed = const Color(0xFFFF6B81);
    final pastelBlue = const Color(0xFF6C63FF);
    final pastelYellow = const Color(0xFFFFE066);
    final pastelPurple = const Color(0xFFB388FF);
    final pastelBg = isDark ? const Color(0xFF23272F) : const Color(0xFFF8F9FB);
    final cardBg = isDark ? const Color(0xFF2D313A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF222B45);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF6B7280);
    final borderColor = isDark ? Colors.white12 : const Color(0xFFDFE2E7);
    return Scaffold(
      backgroundColor: pastelBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Map section
              SizedBox(
                height: 260,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter:
                            _currentPosition ?? LatLng(35.8997, 14.5146),
                        initialZoom: 15.0,
                        onMapReady: () {
                          setState(() {
                            _mapReady = true;
                          });
                        },
                        onPositionChanged: (pos, hasGesture) {
                          setState(() {
                            _mapRotation = pos.rotation;
                          });
                        },
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
                    // Compass overlay (custom needle)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: GestureDetector(
                        onTap: () {
                          if (_mapReady) {
                            _mapController.rotate(0);
                            setState(() {
                              _mapRotation = 0;
                            });
                          }
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: CustomPaint(
                            painter: _CompassPainter(rotation: _mapRotation),
                          ),
                        ),
                      ),
                    ),
                    // Map controls (tracker/device, center location)
                    Positioned(
                      top: 16,
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
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    contentPadding: const EdgeInsets.fromLTRB(
                                      24,
                                      24,
                                      24,
                                      16,
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.watch,
                                              size: 32,
                                              color: Colors.blueAccent,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Device Info',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 18),
                                        Text(
                                          'Device: Smart Band',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Battery: 85%',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Status: Connected',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Poppins',
                                            color: Colors.green,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Model: X100 Pro',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text(
                                          'Close',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
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
                  ],
                ),
              ),
              // Dashboard section
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  children: [
                    // Tabs
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          _modeTab(
                            icon: Icons.directions_walk,
                            label: 'Walk',
                            selected: _mode == 'Walk',
                            color: pastelGreen,
                            onTap: () => setState(() => _mode = 'Walk'),
                          ),
                          const SizedBox(width: 8),
                          _modeTab(
                            icon: Icons.directions_run,
                            label: 'Run',
                            selected: _mode == 'Run',
                            color: pastelRed,
                            onTap: () => setState(() => _mode = 'Run'),
                          ),
                          const SizedBox(width: 8),
                          _modeTab(
                            icon: Icons.directions_bike,
                            label: 'Cycle',
                            selected: _mode == 'Cycle',
                            color: pastelBlue,
                            onTap: () => setState(() => _mode = 'Cycle'),
                          ),
                        ],
                      ),
                    ),
                    // Stats
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _statCard(
                            value: (_distance / 1000).toStringAsFixed(2),
                            label: 'Kilometers',
                            color: pastelGreen,
                          ),
                          _statCard(
                            value: _formatTime(_seconds),
                            label: 'Time',
                            color: pastelRed,
                          ),
                          _statCard(
                            value: co2Value.toStringAsFixed(2),
                            label: 'kg CO₂',
                            color: Colors.lightBlueAccent,
                            icon: Icons.eco,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Steps Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${(_distance * 1.312).toInt()}',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                fontSize: 48,
                                color: _mode == 'Walk'
                                    ? pastelGreen
                                    : _mode == 'Run'
                                    ? pastelRed
                                    : pastelBlue,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Steps',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.directions_walk,
                                  color: pastelGreen,
                                  size: 22,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: pastelGreen,
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: pastelGreen,
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: pastelGreen,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Goal: 5,000 steps',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: subTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Action Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  width: 64,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF23272F)
                                        : const Color(0xFFF1F3F6),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[700],
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Photo',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          if (!_isTracking)
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _startSession();
                                  },
                                  child: Container(
                                    width: 64,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF4CAF50),
                                          Color(0xFF6C63FF),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'GO',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xFF4CAF50),
                                  ),
                                ),
                              ],
                            ),
                          if (_isTracking)
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: _stopSession,
                                  child: Container(
                                    width: 64,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: pastelRed,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.stop_rounded,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'END',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: pastelRed,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Motivational Text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Every step counts. Let\'s go!',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          color: subTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeTab({
    required IconData icon,
    required String label,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: selected ? color : Colors.white,
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? Colors.white : color, size: 22),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: selected ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required String value,
    required String label,
    required Color color,
    IconData? icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF23272F) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFDFE2E7),
          width: 1.5,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 2),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: color,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 4),
                Icon(icon, color: color, size: 18),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: const Color(0xFF6B7280),
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

class _CompassPainter extends CustomPainter {
  final double rotation;
  _CompassPainter({this.rotation = 0});
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final center = Offset(size.width / 2, size.height / 2);
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-rotation); // negative to match map rotation
    canvas.translate(-center.dx, -center.dy);
    final radius = size.width / 2 - 4;
    final paintCircle = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final paintBorder = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    // Draw circle
    canvas.drawCircle(center, radius, paintCircle);
    canvas.drawCircle(center, radius, paintBorder);
    // Draw needle (red - north)
    final paintNeedleRed = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    final paintNeedleGray = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.fill;
    final pathRed = ui.Path()
      ..moveTo(center.dx, center.dy - radius + 6)
      ..lineTo(center.dx - 8, center.dy)
      ..lineTo(center.dx + 8, center.dy)
      ..close();
    final pathGray = ui.Path()
      ..moveTo(center.dx, center.dy + radius - 6)
      ..lineTo(center.dx - 8, center.dy)
      ..lineTo(center.dx + 8, center.dy)
      ..close();
    canvas.drawPath(pathRed, paintNeedleRed);
    canvas.drawPath(pathGray, paintNeedleGray);
    // Draw center dot
    final paintDot = Paint()..color = Colors.grey.shade600;
    canvas.drawCircle(center, 3, paintDot);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
