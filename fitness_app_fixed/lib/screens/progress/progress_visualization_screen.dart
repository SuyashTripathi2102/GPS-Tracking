import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ProgressVisualizationScreen extends StatefulWidget {
  const ProgressVisualizationScreen({super.key});

  @override
  State<ProgressVisualizationScreen> createState() =>
      _ProgressVisualizationScreenState();
}

class _ProgressVisualizationScreenState
    extends State<ProgressVisualizationScreen> {
  String selectedMetric = 'Steps';
  String selectedRange = '7 Days';

  final List<String> metrics = ['Steps', 'Distance', 'CO₂'];
  final List<String> ranges = ['7 Days', '14 Days', '30 Days'];

  final Map<String, List<double>> sampleData = {
    'Steps': [2500, 4000, 3000, 3500, 4200, 4700, 5100],
    'Distance': [1.5, 2.3, 2.0, 2.4, 2.6, 3.0, 3.2],
    'CO₂': [0.3, 0.4, 0.35, 0.36, 0.42, 0.48, 0.50],
  };

  List<String> getLabels() {
    final now = DateTime.now();
    return List.generate(sampleData[selectedMetric]!.length, (index) {
      final date = now.subtract(
        Duration(days: sampleData[selectedMetric]!.length - index - 1),
      );
      return DateFormat('E').format(date);
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = sampleData[selectedMetric]!;

    return Scaffold(
      appBar: AppBar(title: const Text('Progress Over Time')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                DropdownButton<String>(
                  value: selectedMetric,
                  onChanged: (value) {
                    setState(() => selectedMetric = value!);
                  },
                  items: metrics
                      .map(
                        (metric) => DropdownMenuItem(
                          value: metric,
                          child: Text(metric),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(width: 20),
                DropdownButton<String>(
                  value: selectedRange,
                  onChanged: (value) {
                    setState(() => selectedRange = value!);
                  },
                  items: ranges
                      .map(
                        (range) =>
                            DropdownMenuItem(value: range, child: Text(range)),
                      )
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BarChart(
                BarChartData(
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < getLabels().length) {
                            return Text(getLabels()[index]);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(data.length, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data[index],
                          width: 16,
                          color: Colors.deepPurple,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
