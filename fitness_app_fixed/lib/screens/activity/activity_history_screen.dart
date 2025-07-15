import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../services/database_helper.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  String view = 'day';
  List<ActivityData> activityList = [];

  @override
  void initState() {
    super.initState();
    _loadActivityData();
  }

  Future<void> _loadActivityData() async {
    final list = await DatabaseHelper.instance.getAllActivityData();
    setState(() {
      activityList = list;
    });
  }

  List<FlSpot> _generateSpots(String type) {
    final data = activityList.take(7).toList();
    return List.generate(data.length, (index) {
      double value = 0;
      if (type == 'steps') value = data[index].steps.toDouble();
      if (type == 'distance') value = data[index].distance;
      if (type == 'time') value = data[index].activeMinutes.toDouble();
      return FlSpot(index.toDouble(), value);
    });
  }

  List<String> _generateLabels() {
    final formatter = DateFormat('E');
    return activityList.take(7).map((e) => formatter.format(e.date)).toList();
  }

  Widget _buildChart(String label, String type) {
    final spots = _generateSpots(type);
    final labels = _generateLabels();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          int idx = value.toInt();
                          return Text(
                            idx >= 0 && idx < labels.length ? labels[idx] : '',
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      dotData: FlDotData(show: false),
                      barWidth: 3,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ['day', 'week', 'month'].map((v) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ChoiceChip(
            label: Text(v.toUpperCase()),
            selected: view == v,
            onSelected: (selected) {
              if (selected) {
                setState(() => view = v);
              }
            },
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity History')),
      body: Column(
        children: [
          const SizedBox(height: 12),
          _buildViewSelector(),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: [
                _buildChart('Steps', 'steps'),
                _buildChart('Distance (km)', 'distance'),
                _buildChart('Active Time (min)', 'time'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityData {
  final DateTime date;
  final int steps;
  final double distance;
  final int activeMinutes;

  ActivityData({
    required this.date,
    required this.steps,
    required this.distance,
    required this.activeMinutes,
  });
}
