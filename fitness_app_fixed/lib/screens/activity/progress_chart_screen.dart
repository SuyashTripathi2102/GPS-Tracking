import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/database_helper.dart';

class ProgressChartScreen extends StatefulWidget {
  final String type;
  const ProgressChartScreen({super.key, required this.type});

  @override
  State<ProgressChartScreen> createState() => _ProgressChartScreenState();
}

class _ProgressChartScreenState extends State<ProgressChartScreen> {
  List<FlSpot> points = [];
  List<String> labels = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final data = await DatabaseHelper.instance.getAllActivities();

    List<FlSpot> temp = [];
    List<String> tempLabels = [];

    for (int i = 0; i < data.length; i++) {
      final entry = data[i];
      double value = (entry[widget.type.toLowerCase()] ?? 0).toDouble();
      temp.add(FlSpot(i.toDouble(), value));
      tempLabels.add(entry['date'].toString().substring(5, 10));
    }

    setState(() {
      points = temp;
      labels = tempLabels;
    });
  }

  @override
  Widget build(BuildContext context) {
    return points.isEmpty
        ? const Center(child: Text('No data'))
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        int index = value.toInt();
                        return Text(index < labels.length ? labels[index] : '');
                      },
                      interval: 1,
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: points,
                    isCurved: true,
                    color: Colors.deepPurple,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          );
  }
}
