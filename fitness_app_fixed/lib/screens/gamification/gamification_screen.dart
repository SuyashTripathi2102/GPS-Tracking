import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';

class GamificationScreen extends StatelessWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gamification"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Achievements"),
            _buildMedalsGrid(),
            const SizedBox(height: 20),
            _buildSectionTitle("Challenges"),
            _buildChallengesList(),
            const SizedBox(height: 20),
            _buildSectionTitle("Leaderboard"),
            _buildLeaderboard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMedalsGrid() {
    final medals = [
      {"icon": FontAwesomeIcons.medal, "label": "1000 Steps", "lottie": true},
      {"icon": FontAwesomeIcons.running, "label": "5km Run"},
      {"icon": FontAwesomeIcons.bolt, "label": "Consistency"},
      {"icon": FontAwesomeIcons.heartbeat, "label": "Healthy Heart"},
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: medals.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final medal = medals[index];
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.deepPurple.shade50,
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (medal["lottie"] == true)
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Lottie.asset('assets/animations/medal.json'),
                )
              else
                FaIcon(
                  medal["icon"] as IconData,
                  size: 32,
                  color: Colors.deepPurple,
                ),
              const SizedBox(height: 10),
              Text(
                medal["label"] as String,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChallengesList() {
    final challenges = [
      {"title": "10k Step Challenge", "desc": "Walk 10,000 steps in a day"},
      {"title": "7-Day Streak", "desc": "Stay active 7 days in a row"},
      {
        "title": "Burn 500 kcal",
        "desc": "Complete activities to burn 500 kcal",
      },
    ];

    return Column(
      children: challenges.map((challenge) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.flag, color: Colors.orange),
            title: Text(challenge["title"] as String),
            subtitle: Text(challenge["desc"] as String),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLeaderboard() {
    final leaderboard = [
      {"name": "Alice", "score": 12000},
      {"name": "Bob", "score": 9500},
      {"name": "Charlie", "score": 8500},
    ];

    return Column(
      children: leaderboard.asMap().entries.map((entry) {
        final i = entry.key + 1;
        final user = entry.value;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.deepPurple,
            child: Text("$i", style: const TextStyle(color: Colors.white)),
          ),
          title: Text(user["name"] as String),
          trailing: Text(
            "${user["score"]} pts",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }).toList(),
    );
  }
}
