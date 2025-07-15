import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // sample data – replace with your providers/SQLite calls
    final steps = 7500.0, targetSteps = 10000.0;
    final distance = 5.2, targetDistance = 10.0;
    final calories = 320.0, targetCalories = 500.0;

    final modules = [
      {'icon': Icons.favorite, 'label': 'Heart Rate', 'value': '72 bpm'},
      {'icon': Icons.hotel, 'label': 'Sleep', 'value': '7h 20m'},
      {'icon': Icons.run_circle, 'label': 'Sports Records', 'value': 'No data'},
      {
        'icon': Icons.sentiment_satisfied,
        'label': 'Mood Tracking',
        'value': 'No data',
      },
      {'icon': Icons.opacity, 'label': 'Blood Oxygen', 'value': 'No data'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Health Tracker Overview',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Three summary cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _OverviewCard(
                    label: 'Steps',
                    value: '${steps.toInt()}',
                    percent: steps / targetSteps,
                    color: const Color(0xFF7A5CF5),
                  ),
                  _OverviewCard(
                    label: 'Distance',
                    value: '${distance.toStringAsFixed(1)} km',
                    percent: distance / targetDistance,
                    color: const Color(0xFF7A5CF5),
                  ),
                  _OverviewCard(
                    label: 'Kcal',
                    value: '${calories.toInt()}',
                    percent: calories / targetCalories,
                    color: const Color(0xFF7A5CF5),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              // Health Modules label
              Text(
                'Health Modules',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              // Modules grid
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 3,
                children: modules.map((mod) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          mod['icon'] as IconData,
                          color: const Color(0xFF7A5CF5),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mod['label'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                mod['value'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
              // Edit Data Card button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: const Color(0xFF7A5CF5),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: Text(
                    'Edit Data Card',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String label, value;
  final double percent;
  final Color color;
  const _OverviewCard({
    required this.label,
    required this.value,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 64) / 3,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularPercentIndicator(
            radius: 40,
            lineWidth: 6,
            percent: percent.clamp(0, 1),
            center: Icon(
              label == 'Kcal'
                  ? Icons.local_fire_department
                  : label == 'Distance'
                  ? Icons.place
                  : Icons.directions_walk,
              size: 24,
              color: color,
            ),
            progressColor: color,
            backgroundColor: color.withOpacity(0.2),
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
