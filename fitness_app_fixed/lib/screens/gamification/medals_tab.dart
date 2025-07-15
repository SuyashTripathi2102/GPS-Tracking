import 'package:flutter/material.dart';

class MedalsTab extends StatelessWidget {
  const MedalsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final medals = [
      {
        'name': 'Starter',
        'desc': 'Completed first walk',
        'icon': Icons.emoji_events,
      },
      {'name': 'Explorer', 'desc': 'Walked 10km total', 'icon': Icons.explore},
      {'name': 'Green Warrior', 'desc': 'Saved 1kg CO₂', 'icon': Icons.eco},
    ];

    return ListView.builder(
      itemCount: medals.length,
      itemBuilder: (context, index) {
        final medal = medals[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            leading: Icon(
              medal['icon'] as IconData,
              size: 36,
              color: Colors.amber,
            ),
            title: Text(
              medal['name'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(medal['desc'] as String),
          ),
        );
      },
    );
  }
}
