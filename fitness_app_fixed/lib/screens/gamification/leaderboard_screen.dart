import 'package:flutter/material.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> tabs = ['Steps', 'CO₂ Saved', 'Streak'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget buildLeaderboardTab(List<Map<String, dynamic>> data, String type) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final entry = data[index];
        final name = entry['name'];
        final value = entry['value'];
        final initials = entry['initials'];
        final percent = entry['percent'];
        final medal = index < 3 ? ['🥇', '🥈', '🥉'][index] : '#${index + 1}';

        Color progressColor;
        if (type == 'Steps')
          progressColor = Colors.deepPurple;
        else if (type == 'CO₂ Saved')
          progressColor = Colors.green;
        else
          progressColor = Colors.orange;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (index < 3)
                    Text(medal, style: const TextStyle(fontSize: 20))
                  else
                    Text(
                      '$medal',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    child: Text(
                      initials,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    type == 'Steps'
                        ? '$value steps'
                        : type == 'CO₂ Saved'
                        ? '$value kg'
                        : '$value streak',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: percent,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 6,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dummy Data
    final stepsData = [
      {'name': 'Alex_Walker', 'value': 15240, 'initials': 'AW', 'percent': 1.0},
      {
        'name': 'Mike_Johnson',
        'value': 14890,
        'initials': 'MJ',
        'percent': 0.95,
      },
      {'name': 'Sarah_Lee', 'value': 13567, 'initials': 'SL', 'percent': 0.89},
      {'name': 'David_Kim', 'value': 12340, 'initials': 'DK', 'percent': 0.81},
      {
        'name': 'Emma_Miller',
        'value': 11890,
        'initials': 'EM',
        'percent': 0.78,
      },
    ];

    final co2Data = [
      {'name': 'Sarah_Lee', 'value': 3.2, 'initials': 'SL', 'percent': 1.0},
      {'name': 'Mike_Johnson', 'value': 2.8, 'initials': 'MJ', 'percent': 0.87},
      {'name': 'Alex_Walker', 'value': 2.1, 'initials': 'AW', 'percent': 0.66},
    ];

    final streakData = [
      {'name': 'Emma_Miller', 'value': 12, 'initials': 'EM', 'percent': 1.0},
      {'name': 'David_Kim', 'value': 8, 'initials': 'DK', 'percent': 0.67},
      {'name': 'Alex_Walker', 'value': 5, 'initials': 'AW', 'percent': 0.42},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🏆 Leaderboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(30),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black54,
              indicator: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(30),
              ),
              tabs: tabs.map((t) => Tab(text: t)).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildLeaderboardTab(stepsData, 'Steps'),
                buildLeaderboardTab(co2Data, 'CO₂ Saved'),
                buildLeaderboardTab(streakData, 'Streak'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: const [
                Icon(Icons.info_outline, size: 16, color: Colors.grey),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Updated every 24 hrs • Only pseudonymized data shown",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
