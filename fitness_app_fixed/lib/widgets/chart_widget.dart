import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartWidget extends StatelessWidget {
  final String period;

  const ChartWidget({super.key, required this.period});

  List<_ChartData> _generateData(String metric) {
    // Replace with SQLite data fetch in production
    final now = DateTime.now();
    final base = now.subtract(Duration(days: 6));
    return List.generate(7, (i) {
      final date = base.add(Duration(days: i));
      return _ChartData(
        date,
        (i + 1) *
            (metric == 'steps'
                ? 1000
                : metric == 'distance'
                ? 0.8
                : 0.3),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildChartCard("Steps", Colors.deepPurple, _generateData("steps")),
        const SizedBox(height: 24),
        _buildChartCard(
          "Distance (km)",
          Colors.teal,
          _generateData("distance"),
        ),
        const SizedBox(height: 24),
        _buildChartCard("CO₂ Saved (kg)", Colors.orange, _generateData("co2")),
      ],
    );
  }

  Widget _buildChartCard(String title, Color color, List<_ChartData> data) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(),
                series: <CartesianSeries<_ChartData, DateTime>>[
                  LineSeries<_ChartData, DateTime>(
                    dataSource: data,
                    xValueMapper: (datum, _) => datum.date,
                    yValueMapper: (datum, _) => datum.value,
                    color: color,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartData {
  final DateTime date;
  final double value;

  _ChartData(this.date, this.value);
}
