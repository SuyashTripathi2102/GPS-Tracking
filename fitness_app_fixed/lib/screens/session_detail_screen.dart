import 'package:flutter/material.dart';

class SessionDetailScreen extends StatelessWidget {
  final int sessionId;

  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    // Static placeholder data
    const sessionDate = '2024-05-01 10:00';
    const distance = '3.42 km';
    const duration = '00:42:15';
    const steps = '4,500';
    const coins = '4.28';

    return Scaffold(
      appBar: AppBar(title: const Text('Session Detail')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Session ID: #',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '$sessionId',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                SizedBox(width: 8),
                Text(sessionDate),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.directions_walk, size: 20),
                SizedBox(width: 8),
                Text('Distance: $distance'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.timer, size: 20),
                SizedBox(width: 8),
                Text('Duration: $duration'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.directions_run, size: 20),
                SizedBox(width: 8),
                Text('Steps: $steps'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.monetization_on, size: 20),
                SizedBox(width: 8),
                Text('Coins: $coins'),
              ],
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to History'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
