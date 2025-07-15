import 'package:flutter/material.dart';

class LeaderboardTab extends StatelessWidget {
  const LeaderboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final leaders = [
      {'name': 'Alice', 'steps': 30500, 'rank': 1},
      {'name': 'Bob', 'steps': 28000, 'rank': 2},
      {'name': 'You', 'steps': 24500, 'rank': 3},
    ];

    return ListView.builder(
      itemCount: leaders.length,
      itemBuilder: (context, index) {
        final leader = leaders[index];
        return ListTile(
          leading: CircleAvatar(child: Text(leader['rank'].toString())),
          title: Text(leader['name'] as String),
          trailing: Text('${leader['steps']} steps'),
        );
      },
    );
  }
}
