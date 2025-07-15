import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../db/activity_db_helper.dart';
import '../models/activity_model.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  List<ActivityModel> history = [];
  String selectedView = 'week';

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final db = ActivityDBHelper();
    final all = await db.fetchAll();
    setState(() => history = all);
  }

  List<BarChartGroupData> _buildChartData() {
    final bars = <BarChartGroupData>[];
    for (int i = 0; i < history.length && i < 7; i++) {
      final day = history[i];
      bars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: day.steps.toDouble(),
              color: Colors.purpleAccent,
            ),
          ],
        ),
      );
    }
    return bars;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity History')),
      body: Column(
        children: [
          ToggleButtons(
            isSelected: [
              'day',
              'week',
              'month',
            ].map((e) => e == selectedView).toList(),
            onPressed: (index) =>
                setState(() => selectedView = ['day', 'week', 'month'][index]),
            children: const [
              Padding(padding: EdgeInsets.all(8.0), child: Text('Day')),
              Padding(padding: EdgeInsets.all(8.0), child: Text('Week')),
              Padding(padding: EdgeInsets.all(8.0), child: Text('Month')),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: _buildChartData(),
                  titlesData: FlTitlesData(show: false),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
