import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Help & Tutorial')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Welcome to the Fitness App!\n',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Getting Started:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text('• Track your activities using the GPS tracker.'),
          const Text('• View your progress and stats on the dashboard.'),
          const Text('• Earn achievements and compete on the leaderboard.'),
          const SizedBox(height: 16),
          const Text(
            'Tips:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text('• Set reminders to stay active.'),
          const Text('• Customize your profile and theme.'),
          const Text('• Use the high-contrast mode for better visibility.'),
          const SizedBox(height: 16),
          const Text(
            'Accessibility:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text('• The app supports font scaling and screen readers.'),
          const Text('• All buttons and images have semantic labels.'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }
}
