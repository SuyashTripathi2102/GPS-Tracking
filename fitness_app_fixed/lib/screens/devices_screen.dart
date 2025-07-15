import 'package:flutter/material.dart';
// import 'package:dotted_border/dotted_border.dart'; // Uncomment if DottedBorder is available

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "My Devices",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.purple),
            onPressed: () {
              // Navigate to BluetoothScanPage
              // Navigator.push(context, MaterialPageRoute(builder: (_) => BluetoothScanPage()));
            },
          ),
        ],
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Connected Devices",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDeviceCard(
              "Tracker 01",
              "85%",
              "Online",
              "Today, 9:15 AM",
              true,
            ),
            const SizedBox(height: 12),
            _buildDeviceCard(
              "KidsFit Band",
              "52%",
              "Offline",
              "Yesterday, 6:30 PM",
              false,
            ),
            const SizedBox(height: 20),
            // _buildAddNewDeviceCard(context), // Uncomment if DottedBorder is available
            _buildAddNewDeviceCardSimple(context),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.help_outline, color: Colors.purple),
              label: const Text(
                "How to Connect Your Tracker",
                style: TextStyle(color: Colors.purple),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(
    String name,
    String battery,
    String status,
    String time,
    bool isOnline,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFF8F8F8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Image.asset(
          "assets/images/fitness.svg",
          width: 40,
        ), // Use tracker.png if available
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.battery_full,
                  size: 16,
                  color: isOnline ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text("$battery • ", style: const TextStyle(fontSize: 12)),
                Icon(
                  Icons.circle,
                  size: 8,
                  color: isOnline ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    color: isOnline ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Last synced: $time",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: const Icon(Icons.settings),
      ),
    );
  }

  // If DottedBorder is available, use this:
  /*
  Widget _buildAddNewDeviceCard(BuildContext context) {
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: const Radius.circular(12),
      color: Colors.purple,
      strokeWidth: 1.5,
      dashPattern: [8, 4],
      child: InkWell(
        onTap: () {
          // Navigator.push(context, MaterialPageRoute(builder: (_) => BluetoothScanPage()));
        },
        child: Container(
          width: double.infinity,
          height: 90,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add_circle, size: 30, color: Colors.purple),
              SizedBox(height: 6),
              Text("Add New Device", style: TextStyle(color: Colors.purple)),
              Text("Tap to pair a new tracker", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
  */

  // Simple fallback if DottedBorder is not available
  Widget _buildAddNewDeviceCardSimple(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigator.push(context, MaterialPageRoute(builder: (_) => BluetoothScanPage()));
      },
      child: Container(
        width: double.infinity,
        height: 90,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.purple,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_circle, size: 30, color: Colors.purple),
            SizedBox(height: 6),
            Text("Add New Device", style: TextStyle(color: Colors.purple)),
            Text(
              "Tap to pair a new tracker",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
