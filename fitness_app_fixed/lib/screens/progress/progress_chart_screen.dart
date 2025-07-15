import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/db_service.dart';

class ProgressChartScreen extends StatefulWidget {
  const ProgressChartScreen({super.key});

  @override
  State<ProgressChartScreen> createState() => _ProgressChartScreenState();
}

class _ProgressChartScreenState extends State<ProgressChartScreen> {
  List<FlSpot> stepData = [];
  List<FlSpot> distanceData = [];
  List<FlSpot> co2Data = [];

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    final data = await DBService().fetchActivityRecords();

    setState(() {
      stepData = data
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), e.value['steps'].toDouble()))
          .toList();
      distanceData = data
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), e.value['distance'].toDouble()))
          .toList();
      co2Data = data
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), e.value['co2'].toDouble()))
          .toList();
    });
  }

  LineChartData _buildChartData(String label, List<FlSpot> spots, Color color) {
    return LineChartData(
      gridData: FlGridData(show: true),
      borderData: FlBorderData(show: true),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: color,
          barWidth: 3,
          belowBarData: BarAreaData(show: true, color: color.withOpacity(0.2)),
        ),
      ],
    );
  }

  Widget _buildCard(String title, List<FlSpot> spots, Color color) {
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 200,
              child: LineChart(_buildChartData(title, spots, color)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Progress Charts")),
      body: ListView(
        children: [
          _buildCard("Steps", stepData, Colors.blue),
          _buildCard("Distance", distanceData, Colors.green),
          _buildCard("CO₂ Reduction", co2Data, Colors.purple),
        ],
      ),
    );
  }
}
