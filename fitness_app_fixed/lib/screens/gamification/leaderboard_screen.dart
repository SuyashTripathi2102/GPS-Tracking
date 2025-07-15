import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  final List<Map<String, dynamic>> mockData = [
    {'name': 'You', 'completed': 3},
    {'name': 'Alex', 'completed': 2},
    {'name': 'Maria', 'completed': 1},
  ]; // Replace with DB query later

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🏆 Leaderboard")),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: mockData.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, index) {
          final user = mockData[index];
          return ListTile(
            leading: CircleAvatar(child: Text("#${index + 1}")),
            title: Text(user['name']),
            trailing: Text(
              "${user['completed']} ✔️",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }
}
