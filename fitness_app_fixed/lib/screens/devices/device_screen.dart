import 'package:flutter/material.dart';
import '../../database/device_database.dart';
import '../../models/device_model.dart';
import 'bluetooth_scan_page.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  List<DeviceModel> _devices = [];

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    final devices = await DeviceDatabase().getDevices();
    setState(() {
      // Always set to empty list if null
      _devices = devices ?? [];
    });
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
      appBar: AppBar(
        title: const Text("My Devices"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _navigateToScanPage,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Connected Devices",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Always show the device list (sample or real)
            ...devicesToShow.map(_buildDeviceCard).toList(),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InkWell(
                onTap: _navigateToScanPage,
                child: dottedBorderBox(),
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 12),
              child: Text(
                "📘 How to Connect Your Tracker",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
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
