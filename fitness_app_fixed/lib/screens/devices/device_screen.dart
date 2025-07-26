import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_border/dotted_border.dart' show BorderType;
import '../../database/device_database.dart';
import '../../models/device_model.dart';
import 'bluetooth_scan_page.dart';
// import 'package:health_band_plugin/health_band_plugin.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/db/db_helper.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  List<DeviceModel> _devices = [];
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    _loadDevices();
    _startAutoSync();
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  void _startAutoSync() {
    // Immediately sync once, then every 5 minutes
    _syncHealthData();
    _syncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _syncHealthData(),
    );
  }

  Future<void> _syncHealthData() async {
    // TODO: Implement health data fetch from new plugin or mock
    final healthData = null;
    if (healthData != null) {
      try {
        final data = json.decode(healthData);
        await DBHelper.insertSession({
          'activityType': data['activityType'] ?? 'Unknown',
          'distance': data['distance'] ?? 0.0,
          'calories': data['calories'] ?? 0.0,
          'duration': data['duration'] ?? 0,
          'timestamp': data['timestamp'] ?? DateTime.now().toIso8601String(),
          'heartRate': data['heartRate'] ?? 0,
          'co2': data['co2'] ?? 0.0,
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session auto-synced from band!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Auto-sync failed: $e')));
        }
      }
    }
  }

  Future<void> _loadDevices() async {
    final devices = await DeviceDatabase().getDevices();
    setState(() {
      // Always set to empty list if null
      _devices = devices ?? [];
    });
  }

  Future<void> _requestBluetoothPermissions() async {
    await [
      Permission.bluetooth,
      Permission.locationWhenInUse,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
  }

  Widget _buildDeviceCard(DeviceModel device) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        leading: Image.asset(
          "assets/icons/tablet-android.png",
          width: 40,
          height: 40,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.watch, size: 32),
        ),
        title: Text(
          device.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              "Battery: ${device.batteryLevel}%",
              style: const TextStyle(fontSize: 13),
            ),
            Text(
              "Last synced: ${device.lastSyncTime}",
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.circle,
              color: device.isOnline ? Colors.green : Colors.grey,
              size: 12,
            ),
            const SizedBox(height: 4),
            Text(
              device.isOnline ? "Online" : "Offline",
              style: TextStyle(
                color: device.isOnline ? Colors.green : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToScanPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BluetoothScanPage()),
    );
    _loadDevices(); // reload after scan
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pastelPurple = theme.colorScheme.primary;
    final pastelBlue = theme.colorScheme.primary;
    final pastelBg = theme.scaffoldBackgroundColor;
    final cardBg = theme.cardColor;
    final fadedText = theme.textTheme.bodySmall?.color ?? Colors.grey;
    final fadedIcon = theme.dividerColor ?? Colors.grey.shade300;
    // Always show at least one sample device for demo if no real devices
    final devicesToShow = (_devices.isEmpty)
        ? [
            DeviceModel(
              id: 1,
              name: 'Tracker 01',
              deviceId: 'SAMPLE-DEVICE-01',
              batteryLevel: 85,
              lastSyncTime: 'Today, 9:15 AM',
              isOnline: true,
            ),
          ]
        : _devices;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          "My Devices",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8),
            child: FloatingActionButton(
              onPressed: _navigateToScanPage,
              backgroundColor: Theme.of(context).colorScheme.primary,
              elevation: 2,
              mini: true,
              child: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Connected Devices",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...devicesToShow
                  .map(
                    (device) =>
                        _modernDeviceCard(device, pastelBlue, pastelPurple),
                  )
                  .toList(),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: InkWell(
                  onTap: _navigateToScanPage,
                  borderRadius: BorderRadius.circular(18),
                  child: DottedBorder(
                    options: RoundedRectDottedBorderOptions(
                      color: theme.colorScheme.primary,
                      strokeWidth: 1.5,
                      dashPattern: [6, 4],
                      radius: const Radius.circular(18),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(
                                0.12,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              Icons.add,
                              size: 32,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Add New Device",
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Tap to pair a new tracker",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Icon(
                      Icons.menu_book,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "How to Connect Your Tracker",
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modernDeviceCard(
    DeviceModel device,
    Color pastelBlue,
    Color pastelPurple,
  ) {
    // Improved device card layout for better alignment
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : pastelBlue.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white12
                    : theme.colorScheme.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                "assets/icons/tablet-android.png",
                width: 32,
                height: 32,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.watch, size: 32, color: pastelBlue),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          device.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            fontFamily: 'Poppins',
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.circle,
                            color: device.isOnline ? Colors.green : Colors.grey,
                            size: 10,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            device.isOnline ? "Online" : "Offline",
                            style: TextStyle(
                              color: device.isOnline
                                  ? Colors.green
                                  : Colors.grey,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              fontFamily: 'Poppins',
                              // Always readable
                              shadows: isDark
                                  ? [Shadow(color: Colors.black, blurRadius: 2)]
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.battery_full, color: Colors.green, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        "Battery: ",
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white54 : Colors.black87,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        "${device.batteryLevel}%",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Last synced row (fix wrapping)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.access_time, color: pastelPurple, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last synced:',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white54 : Colors.black87,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            Text(
                              device.lastSyncTime,
                              style: TextStyle(
                                fontSize: 14,
                                color: pastelPurple,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _availableSlotCard(ThemeData theme, Color fadedIcon, Color fadedText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: fadedIcon,
          width: 1.2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.devices_other, size: 32, color: fadedIcon),
          const SizedBox(height: 8),
          Text(
            "Available Slot",
            style: TextStyle(
              color: fadedText,
              fontWeight: FontWeight.w600,
              fontSize: 15,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Ready for new device",
            style: TextStyle(
              fontSize: 12,
              color: fadedText,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

Widget dottedBorderBox() {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      border: Border.all(
        color: Colors.purple,
        width: 1.5,
        style: BorderStyle.solid,
      ),
      borderRadius: BorderRadius.circular(16),
      color: Colors.purple.shade50.withOpacity(0.2),
    ),
    child: Column(
      children: const [
        Icon(Icons.add_circle, size: 32, color: Colors.purple),
        SizedBox(height: 8),
        Text(
          "Add New Device",
          style: TextStyle(color: Colors.purple, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 4),
        Text("Tap to pair a new tracker", style: TextStyle(fontSize: 12)),
      ],
    ),
  );
}
