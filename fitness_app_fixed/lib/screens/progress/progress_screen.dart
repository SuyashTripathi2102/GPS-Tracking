import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/db/db_helper.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<Map<String, dynamic>> sessions = [];
  String selectedRange = 'This Week';
  String selectedActivity = 'Cycling';
  final List<String> timeFilters = ['This Week', 'This Month', 'All Time'];
  final List<String> activities = ['Cycling', 'Walking', 'Running'];

  @override
  void initState() {
    super.initState();
    migrateAndLoadSessions();
  }

  Future<void> migrateAndLoadSessions() async {
    await DBHelper.migrateOldSessions();
    await loadSessions();
  }

  Future<void> loadSessions() async {
    final data = await DBHelper.getAllSessions();
    // Add static demo sessions at the top
    final staticSessions = [
      {
        'distance': 5.10,
        'calories': 120,
        'timestamp': '2025-07-18T14:51:00',
        'status': 'Completed',
      },
      {
        'distance': 0.00,
        'calories': 0,
        'timestamp': '2025-07-17T06:30:00',
        'status': 'Incomplete',
      },
      {
        'distance': 3.20,
        'calories': 90,
        'timestamp': '2025-07-16T07:15:00',
        'status': 'Completed',
      },
      {
        'distance': 2.80,
        'calories': 70,
        'timestamp': '2025-07-15T17:45:00',
        'status': 'Indoor Activity',
      },
      {
        'distance': 0.00,
        'calories': 0,
        'timestamp': '2025-07-14T08:00:00',
        'status': 'Incomplete',
      },
    ];
      setState(() {
      sessions = [...staticSessions, ...data];
    });
    print('Loaded sessions: $sessions');
  }

  double getTotalDistance() {
    return sessions.fold(0.0, (sum, s) => sum + (s['distance'] ?? 0));
  }

  double getTotalCalories() {
    final total = sessions.fold(0.0, (sum, s) => sum + (s['calories'] ?? 0));
    // If all calories are 0, show a static value for demo
    if (total == 0) return 320;
    return total;
  }

  String getDistanceDelta() => '+2.1 km from last week';
  String getCaloriesDelta() => '+120 from last week';

  List<BarChartGroupData> getWeeklyChartData() {
    final Map<String, List<double>> data = {
      'Cycling': [1, 2, 3, 2, 1, 2, 1],
      'Walking': [2, 2, 1, 3, 2, 4, 2],
      'Running': [1, 3, 2, 4, 2, 1, 1],
    };
    final values = data[selectedActivity]!;
    return List.generate(
      7,
      (i) => BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: values[i],
            color: selectedActivity == 'Cycling'
                ? const Color(0xFF6C63FF)
                : selectedActivity == 'Walking'
                ? const Color(0xFFB388FF)
                : const Color(0xFF4CAF50),
            width: 18,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final totalDistance = getTotalDistance();
    final totalCalories = getTotalCalories();
    final pastelRed = const Color(0xFFFF6B81);
    final pastelYellow = const Color(0xFFFFE066);
    final pastelGreen = const Color(0xFF4CAF50);
    final pastelPurple = const Color(0xFFB388FF);
    final pastelBlue = const Color(0xFF6C63FF);
    final pastelBg = isDark ? const Color(0xFF23272F) : const Color(0xFFFFF7ED);
    final cardBg = isDark ? const Color(0xFF2D313A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF222B45);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF6B7280);
    final borderColor = isDark ? Colors.white12 : const Color(0xFFDFE2E7);

    return Scaffold(
      backgroundColor: pastelBg,
      appBar: AppBar(
        backgroundColor: pastelBg,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Progress ',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  color: textColor,
                ),
              ),
              Text(
                'Journey',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  color: pastelGreen,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  isDark ? Icons.wb_sunny : Icons.nightlight_round,
                  color: pastelYellow,
                ),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Track how far you've come!",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                  color: subTextColor,
                ),
              ),
              const SizedBox(height: 18),
              // Time Filters
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: timeFilters.map((filter) {
                  final isSelected = selectedRange == filter;
                  return ChoiceChip(
                    label: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: isSelected ? Colors.black : textColor,
                        ),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: pastelYellow,
                    backgroundColor: Colors.transparent,
                    side: BorderSide(
                      color: isSelected ? pastelYellow : borderColor,
                      width: 2,
                    ),
                    onSelected: (_) => setState(() => selectedRange = filter),
                    elevation: 0,
                    pressElevation: 0,
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      icon: Icons.directions_walk,
                      color: pastelRed,
                      title: 'Distance',
                      value: '${totalDistance.toStringAsFixed(1)} km',
                      delta: getDistanceDelta(),
                      bg: cardBg,
                      textColor: textColor,
                      subTextColor: subTextColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _summaryCard(
                      icon: Icons.local_fire_department,
                      color: pastelYellow,
                      title: 'Calories',
                      value: '${totalCalories.toStringAsFixed(0)}',
                      delta: getCaloriesDelta(),
                      bg: cardBg,
                      textColor: textColor,
                      subTextColor: subTextColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // Journey Badges
              Text(
                'Your Journey',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _journeyBadge(
                        icon: Icons.flag,
                        iconBg: pastelGreen,
                        title: 'Beginner',
                        status: 'Completed',
                        statusColor: pastelGreen,
                        textColor: textColor,
                        fontFamily: 'Poppins',
                        borderColor: borderColor,
                      ),
                      const SizedBox(width: 16),
                      _journeyBadge(
                        icon: Icons.fitness_center,
                        iconBg: pastelRed,
                        title: '10 Sessions',
                        status: 'In Progress',
                        statusColor: pastelRed,
                        textColor: textColor,
                        fontFamily: 'Poppins',
                        borderColor: borderColor,
                      ),
                      const SizedBox(width: 16),
                      _journeyBadge(
                        icon: Icons.flash_on,
                        iconBg: pastelYellow,
                        title: '25km Distance',
                        status: 'Coming Up',
                        statusColor: borderColor,
                        textColor: textColor,
                        fontFamily: 'Poppins',
                        borderColor: borderColor,
                      ),
                      const SizedBox(width: 16),
                      _journeyBadge(
                        icon: Icons.local_fire_department,
                        iconBg: pastelPurple,
                        title: '5 Day Streak',
                        status: 'Coming Up',
                        statusColor: borderColor,
                        textColor: textColor,
                        fontFamily: 'Poppins',
                        borderColor: borderColor,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Weekly Activity
              Text(
                'Weekly Activity',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: activities.map((a) {
                          final isSelected = selectedActivity == a;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 2,
                                ),
                                child: Text(
                                  a,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: isSelected
                                        ? Colors.white
                                        : textColor,
                                  ),
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: a == 'Cycling'
                                  ? pastelBlue
                                  : a == 'Walking'
                                  ? pastelPurple
                                  : pastelGreen,
                              backgroundColor: Colors.transparent,
                              side: BorderSide(
                                color: isSelected
                                    ? (a == 'Cycling'
                                          ? pastelBlue
                                          : a == 'Walking'
                                          ? pastelPurple
                                          : pastelGreen)
                                    : borderColor,
                                width: 2,
                              ),
                              onSelected: (_) =>
                                  setState(() => selectedActivity = a),
                              elevation: 0,
                              pressElevation: 0,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 140,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 5,
                          barGroups: getWeeklyChartData(),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                getTitlesWidget: (value, meta) {
                                  if (value % 1 != 0)
                                    return const SizedBox.shrink();
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Text(
                                      '${value.toInt()}km',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: subTextColor,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final days = [
                                    'Mon',
                                    'Tue',
                                    'Wed',
                                    'Thu',
                                    'Fri',
                                    'Sat',
                                    'Sun',
                                  ];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      days[value.toInt() % 7],
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: subTextColor,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Session List
              Text(
                'Your Sessions',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              if (sessions.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No sessions found.',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              else
                ...sessions
                    .map(
                      (s) => _sessionCard(
                        s,
                        pastelBlue,
                        pastelRed,
                        pastelGreen,
                        pastelPurple,
                        cardBg,
                        textColor,
                        subTextColor,
                      ),
                    )
                    .toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required String delta,
    required Color bg,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.13),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: textColor,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            delta,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: 13,
              color: subTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _badgeCard(
    String title,
    String subtitle,
    Color color,
    Color bg,
    Color textColor,
  ) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.emoji_events, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: textColor,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: 13,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _journeyBadge({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String status,
    required Color statusColor,
    required Color textColor,
    required String fontFamily,
    required Color borderColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.13),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontFamily: fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: statusColor == borderColor
                  ? textColor.withOpacity(0.7)
                  : statusColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sessionCard(
    Map<String, dynamic> s,
    Color cycling,
    Color running,
    Color completed,
    Color walking,
    Color bg,
    Color textColor,
    Color subTextColor,
  ) {
    final id = s['id'] != null ? 'Session #${s['id']}' : 'Session';
    final date =
        (s['timestamp'] != null && s['timestamp'].toString().isNotEmpty)
        ? DateFormat(
            'dd MMM, hh:mm a',
          ).format(DateTime.tryParse(s['timestamp']) ?? DateTime.now())
        : '-';
    final distance = s['distance'] != null
        ? s['distance'].toStringAsFixed(2)
        : '-';
    final status = (s['status'] ?? 'Completed').toString();
    final color = status == 'Completed'
        ? completed
        : status == 'Running'
        ? running
        : status == 'Walking'
        ? walking
        : cycling;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 2),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.directions_run, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  id,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    color: subTextColor,
                  ),
                ),
                Text(
                  '$distance km  $status',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
