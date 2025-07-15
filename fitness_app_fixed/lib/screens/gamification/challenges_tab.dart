import 'package:flutter/material.dart';

class ChallengesTab extends StatelessWidget {
  const ChallengesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final challenges = [
      {
        'title': '7-Day Streak',
        'desc': 'Walk every day for 7 days',
        'progress': 0.7,
      },
      {
        'title': 'Distance Champ',
        'desc': 'Walk 50km in 30 days',
        'progress': 0.45,
      },
      {'title': 'Eco Hero', 'desc': 'Save 5kg CO₂ in a month', 'progress': 0.2},
    ];

    return ListView.builder(
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(challenge['desc'] as String),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: challenge['progress'] as double),
              ],
            ),
          ),
        );
      },
    );
  }
}
