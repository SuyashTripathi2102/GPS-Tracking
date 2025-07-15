import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CircleIndicator extends StatelessWidget {
  final String label;
  final double percent; // 0.0 – 1.0
  final Color color;

  const CircleIndicator({
    super.key,
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 80,
          lineWidth: 10,
          percent: percent.clamp(0, 1),
          center: Text(
            '${(percent * 100).toInt()}%',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          progressColor: color,
          backgroundColor: color.withOpacity(0.2),
          circularStrokeCap: CircularStrokeCap.round,
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
