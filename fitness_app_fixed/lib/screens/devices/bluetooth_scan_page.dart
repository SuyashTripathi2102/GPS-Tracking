import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/device_model.dart';
import '../../database/device_database.dart';
import 'dart:math';
import 'dart:async'; // Added for StreamSubscription

class BluetoothScanPage extends StatefulWidget {
  const BluetoothScanPage({Key? key}) : super(key: key);

  @override
  State<BluetoothScanPage> createState() => _BluetoothScanPageState();
}

class _BluetoothScanPageState extends State<BluetoothScanPage> {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  final List<DiscoveredDevice> _devices = [];
  Stream<DiscoveredDevice>? _scanStream;
  Stream<ConnectionStateUpdate>? _connectionStream;
  DiscoveredDevice? _connectedDevice;
  BleStatus _bleStatus = BleStatus.unknown;
  bool _isScanning = false;
  bool _isSyncing = false;
  String? _connectionStatus;

  // Store subscriptions to cancel in dispose
  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;
  StreamSubscription<BleStatus>? _bleStatusSubscription;

  @override
  void initState() {
    super.initState();
    _bleStatusSubscription = _ble.statusStream.listen((status) {
      if (!mounted) return;
      setState(() {
        _bleStatus = status;
      });
    });
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    _bleStatusSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startScan() async {
    if (_bleStatus != BleStatus.ready) {
      _showDialog("Bluetooth is Off", "Please enable Bluetooth first.");
      return;
    }
    final permission = await Permission.location.request();
    if (!permission.isGranted) {
      _showDialog(
        "Permission Denied",
        "Location permission is needed to scan.",
      );
      return;
    }
    if (!mounted) return;
    setState(() {
      _devices.clear();
      _isScanning = true;
      _connectionStatus = null;
    });
    _scanStream = _ble
        .scanForDevices(withServices: [], scanMode: ScanMode.lowLatency)
        .distinct((a, b) => a.id == b.id);
    _scanSubscription = _scanStream!.listen(
      (device) {
        if (!mounted) return;
        if (_devices.indexWhere((d) => d.id == device.id) == -1) {
          setState(() => _devices.add(device));
        }
      },
      onDone: () {
        if (!mounted) return;
        setState(() => _isScanning = false);
      },
    );
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _isScanning = false);
    });
  }

  void _connectToDevice(DiscoveredDevice device) {
    if (!mounted) return;
    setState(() {
      _connectionStatus = "Connecting to ${device.name}...";
    });
    _connectionStream = _ble.connectToDevice(id: device.id);
    _connectionSubscription = _connectionStream!.listen(
      (update) async {
        if (!mounted) return;
        setState(() => _connectionStatus = update.connectionState.toString());
        if (update.connectionState == DeviceConnectionState.connected) {
          if (!mounted) return;
          setState(() => _connectedDevice = device);
          _simulateSync();
          _showDeviceInfoDialog(device);
        }
      },
      onError: (e) {
        if (!mounted) return;
        setState(() => _connectionStatus = "Connection failed: $e");
      },
    );
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && _connectedDevice?.id != device.id) {
        setState(() => _connectionStatus = "Connection timeout");
      }
    });
  }

  void _simulateSync() {
    setState(() => _isSyncing = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _isSyncing = false);
    });
  }

  void _showDeviceInfoDialog(DiscoveredDevice device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(device.name.isNotEmpty ? device.name : 'Unknown Device'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Device ID: ${device.id}"),
            const SizedBox(height: 8),
            Text("RSSI: ${device.rssi}"),
            const SizedBox(height: 8),
            if (_isSyncing)
              Row(
                children: const [
                  CircularProgressIndicator(strokeWidth: 2),
                  SizedBox(width: 8),
                  Text("Syncing data..."),
                ],
              )
            else
              const Text("Synced successfully!"),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Save Device"),
            onPressed: () async {
              // Simulate battery and last sync
              final battery = 50 + Random().nextInt(50);
              final now = DateTime.now();
              final lastSync =
                  "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour}:${now.minute.toString().padLeft(2, '0')}";
              final model = DeviceModel(
                name: device.name.isNotEmpty ? device.name : 'Unknown Device',
                deviceId: device.id,
                batteryLevel: battery,
                lastSyncTime: lastSync,
                isOnline: true,
              );
              await DeviceDatabase().insertDevice(model);
              if (mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Pop scan page
              }
            },
          ),
          TextButton(
            child: const Text("Settings"),
            onPressed: () {
              Navigator.pop(context);
              _showSettingsPanel(device);
            },
          ),
          TextButton(
            child: const Text("Close"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showSettingsPanel(DiscoveredDevice device) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          children: [
            Center(
              child: Container(
                height: 5,
                width: 60,
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Device Settings",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text("Sync Now"),
              onTap: () {
                Navigator.pop(context);
                _simulateSync();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("Remove Device"),
              onTap: () {
                setState(() => _connectedDevice = null);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Devices')),
      body: Column(
        children: [
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isScanning ? null : _startScan,
            icon: const Icon(Icons.search),
            label: const Text("Start Scan"),
          ),
          if (_connectionStatus != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                _connectionStatus!,
                style: const TextStyle(color: Colors.blue),
              ),
            ),
          if (_isScanning) const CircularProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (context, i) {
                final device = _devices[i];
                return ListTile(
                  leading: const Icon(Icons.bluetooth),
                  title: Text(
                    device.name.isNotEmpty ? device.name : 'Unknown Device',
                  ),
                  subtitle: Text("ID: ${device.id}"),
                  trailing: _connectedDevice?.id == device.id
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  onTap: () => _connectToDevice(device),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
