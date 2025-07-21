import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'dart:math' as Math;

class DashboardDualCircleScreen extends StatefulWidget {
  const DashboardDualCircleScreen({super.key});

  @override
  State<DashboardDualCircleScreen> createState() =>
      _DashboardDualCircleScreenState();
}

class _DashboardDualCircleScreenState extends State<DashboardDualCircleScreen> {
  int _pagerPage = 0;
  late final PageController _pagerController;

  @override
  void initState() {
    super.initState();
    _pagerController = PageController();
  }

  @override
  void dispose() {
    _pagerController.dispose();
    super.dispose();
  }

  // Example user data (replace with real data integration)
  final int steps = 4200;
  final int stepTarget = 5000;
  final int coins = 18;
  final double distance = 3.7;
  final int calories = 220;
  final int level = 2; // Level 1-5

  Color getLevelColor(int level, bool isDark) {
    switch (level) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.purple;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.red;
      default:
        return isDark ? Colors.white : Colors.black;
    }
  }

  LinearGradient getLevelGradient(int level) {
    // Always return a dark green gradient for this preview
    return const LinearGradient(
      colors: [Color(0xFF0F2B17), Color(0xFF183D23)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final levelColor = getLevelColor(level, isDark);
    final textColor = Colors.white;
    final fadedText = Colors.white70;
    final shadow = [
      Shadow(
        color: Colors.black.withOpacity(0.5),
        blurRadius: 4,
        offset: Offset(0, 1),
      ),
    ];
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final topHeight = 280.0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_outlined, color: levelColor),
            onPressed: () {},
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Horizontally scrollable dashboard section in a dark green card
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 6,
              color: const Color(0xFF183D23),
              child: SizedBox(
                height: topHeight,
                child: PageView(
                  controller: _pagerController,
                  onPageChanged: (i) => setState(() => _pagerPage = i),
                  children: [
                    // Page 1: Dummy data
                    Container(
                      width: screenWidth,
                      height: topHeight,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(36),
                          bottomRight: Radius.circular(36),
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.dashboard,
                              size: 60,
                              color: Colors.green,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Welcome!',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'This is a dummy page. Swipe to see your stats.',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Page 2: Big circle and stats (no vertical scroll)
                    Container(
                      width: screenWidth,
                      height: topHeight,
                      color: Colors.transparent,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Big circle
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 4),
                            child: SizedBox(
                              width: 200,
                              height: 200,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularPercentIndicator(
                                    radius: 90,
                                    lineWidth: 12,
                                    percent: (coins / 50).clamp(0.0, 1.0),
                                    backgroundColor: Colors.white12,
                                    progressColor: Colors.greenAccent,
                                    circularStrokeCap: CircularStrokeCap.round,
                                  ),
                                  CircularPercentIndicator(
                                    radius: 75,
                                    lineWidth: 12,
                                    percent: (steps / stepTarget).clamp(
                                      0.0,
                                      1.0,
                                    ),
                                    backgroundColor: Colors.white24,
                                    progressColor: Colors.white,
                                    circularStrokeCap: CircularStrokeCap.round,
                                    center: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '$steps',
                                          style: GoogleFonts.poppins(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'of $stepTarget',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Coin icon at top center of outer circle
                                  Positioned(
                                    top: 9,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.greenAccent,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.attach_money,
                                          size: 10,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Shoe icon at top center of inner circle
                                  Positioned(
                                    top: 24,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.directions_walk,
                                          size: 10,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Checkmark at end of coin arc if coins target achieved
                                  if (coins >= 50)
                                    _ArcEndCheckmark(
                                      radius: 90,
                                      percent: 1.0,
                                      color: Colors.greenAccent,
                                    ),
                                  // Checkmark at end of step arc if step target achieved
                                  if (steps >= stepTarget)
                                    _ArcEndCheckmark(
                                      radius: 75,
                                      percent: 1.0,
                                      color: Colors.white,
                                    ),
                                ],
                              ),
                            ),
                          ),
                          // Stats on the right
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 12,
                                left: 4,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.attach_money,
                                        color: Colors.greenAccent,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '$coins',
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.greenAccent,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'coins',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.purpleAccent,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${distance.toStringAsFixed(1)}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purpleAccent,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'km',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.local_fire_department,
                                        color: Colors.orangeAccent,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '$calories',
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orangeAccent,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'cal',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Page 3: Friends card (as in your screenshot)
                    Container(
                      width: screenWidth,
                      height: topHeight,
                      decoration: BoxDecoration(
                        color: Colors.green[900]?.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.directions_walk,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.emoji_events,
                                color: Colors.amber,
                                size: 32,
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.flag,
                                color: Colors.greenAccent,
                                size: 32,
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.track_changes,
                                color: Colors.orange,
                                size: 32,
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Add friends, compete and stay updated',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Staying fit is easier with your friends/family. A little friendly competition will spur you on!',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.greenAccent,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 10,
                              ),
                            ),
                            onPressed: () {},
                            child: const Text('Find Friends'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Dots indicator below the card
            _DashboardPagerDots(page: _pagerPage),
            // Rest of the dashboard content (ads, cards, etc.)
            Container(
              width: double.infinity,
              color: theme.scaffoldBackgroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  // Today's Summary Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today's Summary",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Activity Cards Row
                        Row(
                          children: [
                            Expanded(
                              child: _ActivityCard(
                                icon: Icons.directions_run,
                                title: 'Active Time',
                                value: '45 min',
                                color: Colors.blue,
                                theme: theme,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ActivityCard(
                                icon: Icons.timer,
                                title: 'Standing',
                                value: '8h 30m',
                                color: Colors.green,
                                theme: theme,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Weekly Progress
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.dark
                                ? Colors.grey[850]
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Weekly Progress',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: List.generate(7, (index) {
                                  final dayNames = [
                                    'M',
                                    'T',
                                    'W',
                                    'T',
                                    'F',
                                    'S',
                                    'S',
                                  ];
                                  final progress = [
                                    0.8,
                                    0.9,
                                    0.7,
                                    0.95,
                                    0.6,
                                    0.85,
                                    0.75,
                                  ];
                                  return Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                          dayNames[index],
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color:
                                                theme.brightness ==
                                                    Brightness.dark
                                                ? Colors.white70
                                                : Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          width: 8,
                                          height: 40 * progress[index],
                                          decoration: BoxDecoration(
                                            color: Colors.greenAccent,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Quick Actions
                        Text(
                          'Quick Actions',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _QuickActionButton(
                                icon: Icons.add,
                                label: 'Start Workout',
                                color: Colors.greenAccent,
                                theme: theme,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _QuickActionButton(
                                icon: Icons.analytics,
                                label: 'View Progress',
                                color: Colors.blue,
                                theme: theme,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Recent Activities
                        Text(
                          'Recent Activities',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ActivityItem(
                          icon: Icons.directions_walk,
                          title: 'Morning Walk',
                          subtitle: '3.2 km • 32 min',
                          time: '2 hours ago',
                          color: Colors.green,
                          theme: theme,
                        ),
                        const SizedBox(height: 8),
                        _ActivityItem(
                          icon: Icons.fitness_center,
                          title: 'Strength Training',
                          subtitle: '45 min • 320 cal',
                          time: 'Yesterday',
                          color: Colors.orange,
                          theme: theme,
                        ),
                        const SizedBox(height: 8),
                        _ActivityItem(
                          icon: Icons.directions_bike,
                          title: 'Cycling',
                          subtitle: '12.5 km • 48 min',
                          time: '2 days ago',
                          color: Colors.blue,
                          theme: theme,
                        ),
                        const SizedBox(height: 16),
                        // Achievements Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple.withOpacity(0.1),
                                Colors.blue.withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.purple.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.emoji_events,
                                    color: Colors.amber,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Recent Achievements',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: theme.brightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _AchievementItem(
                                title: 'Step Master',
                                description: 'Reached 10,000 steps for 7 days',
                                icon: Icons.directions_walk,
                                theme: theme,
                              ),
                              const SizedBox(height: 8),
                              _AchievementItem(
                                title: 'Early Bird',
                                description: 'Completed workout before 8 AM',
                                icon: Icons.wb_sunny,
                                theme: theme,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Health Metrics
                        Text(
                          'Health Metrics',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _HealthMetricCard(
                                icon: Icons.favorite,
                                title: 'Heart Rate',
                                value: '72',
                                unit: 'bpm',
                                color: Colors.red,
                                theme: theme,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _HealthMetricCard(
                                icon: Icons.air,
                                title: 'Sleep',
                                value: '7.5',
                                unit: 'hrs',
                                color: Colors.indigo,
                                theme: theme,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Weather & Motivation
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange.withOpacity(0.1),
                                Colors.yellow.withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.wb_sunny,
                                color: Colors.orange,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Perfect Weather for Exercise!',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            theme.brightness == Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '22°C • Sunny • Great day for outdoor activities',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color:
                                            theme.brightness == Brightness.dark
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;
  final bool isOnGradient;
  final List<Shadow>? shadow;
  final Color accent;

  const _StatRow({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
    this.isOnGradient = false,
    this.shadow,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: accent, width: 2.2),
            color: Colors.transparent,
          ),
          child: Center(
            child: Icon(icon, color: accent, size: 20, shadows: shadow),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: accent,
            shadows: shadow,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: theme.brightness == Brightness.dark
                ? Colors.white.withOpacity(0.7)
                : Colors.black.withOpacity(0.7),
            shadows: shadow,
          ),
        ),
      ],
    );
  }
}

class _PageDot extends StatelessWidget {
  final bool isActive;
  const _PageDot({required this.isActive});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white38,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final ThemeData theme;

  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? Colors.grey[850]
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: theme.brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final ThemeData theme;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;
  final ThemeData theme;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? Colors.grey[850]
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: theme.brightness == Brightness.dark
                  ? Colors.white54
                  : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementItem extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final ThemeData theme;

  const _AchievementItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.amber, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HealthMetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String unit;
  final Color color;
  final ThemeData theme;

  const _HealthMetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? Colors.grey[850]
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArcEndCheckmark extends StatelessWidget {
  final double radius;
  final double percent; // 0.0 to 1.0
  final Color color;

  const _ArcEndCheckmark({
    required this.radius,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // End angle in radians (start at top, clockwise)
    final double angle = -3.14159 / 2 + 2 * 3.14159 * percent;
    return Positioned(
      left: radius + radius * 0.85 * Math.cos(angle) - 12,
      top: radius + radius * 0.85 * Math.sin(angle) - 12,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Icon(Icons.check, size: 16, color: Colors.white),
      ),
    );
  }
}

class _DashboardInfoPager extends StatefulWidget {
  @override
  State<_DashboardInfoPager> createState() => _DashboardInfoPagerState();
}

class _DashboardInfoPagerState extends State<_DashboardInfoPager> {
  int _page = 0;
  final _controller = PageController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView(
            controller: _controller,
            onPageChanged: (i) => setState(() => _page = i),
            children: [
              // Page 1: Placeholder
              Center(
                child: Text(
                  'Welcome to your Dashboard!',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
              // Page 2: Placeholder
              Center(
                child: Text(
                  'Track your progress and earn rewards.',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
              // Page 3: Friends/Competition card
              Container(
                decoration: BoxDecoration(
                  color: Colors.green[900]?.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(18),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_walk,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                        const SizedBox(width: 8),
                        Icon(Icons.flag, color: Colors.greenAccent, size: 32),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.track_changes,
                          color: Colors.orange,
                          size: 32,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Add friends, compete and stay updated',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Staying fit is easier with your friends/family. A little friendly competition will spur you on!',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                      ),
                      onPressed: () {},
                      child: const Text('Find Friends'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _page == i ? Colors.greenAccent : Colors.white24,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardHorizontalPager extends StatelessWidget {
  final int coins;
  final int steps;
  final int stepTarget;
  final double distance;
  final int calories;
  final bool isDark;
  final PageController controller;
  final ValueChanged<int> onPageChanged;
  const _DashboardHorizontalPager({
    required this.coins,
    required this.steps,
    required this.stepTarget,
    required this.distance,
    required this.calories,
    required this.isDark,
    required this.controller,
    required this.onPageChanged,
  });
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final topHeight = 300.0;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 6,
      color: const Color(0xFF183D23),
      child: SizedBox(
        height: 300,
        child: PageView(
          controller: controller,
          onPageChanged: onPageChanged,
          children: [
            // Page 1: Dummy data
            Container(
              width: screenWidth,
              height: topHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.dashboard, size: 60, color: Colors.green),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome!',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This is a dummy page. Swipe to see your stats.',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            // Page 2: Big circle and stats (no vertical scroll)
            Container(
              width: screenWidth,
              height: topHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Big circle
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularPercentIndicator(
                            radius: 60,
                            lineWidth: 8,
                            percent: (coins / 50).clamp(0.0, 1.0),
                            backgroundColor: Colors.white12,
                            progressColor: Colors.greenAccent,
                            circularStrokeCap: CircularStrokeCap.round,
                          ),
                          CircularPercentIndicator(
                            radius: 50,
                            lineWidth: 8,
                            percent: (steps / stepTarget).clamp(0.0, 1.0),
                            backgroundColor: Colors.white24,
                            progressColor: Colors.white,
                            circularStrokeCap: CircularStrokeCap.round,
                            center: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${steps}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'of ${stepTarget}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Coin icon at top center of outer circle
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.attach_money,
                                  size: 10,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          // Shoe icon at top center of inner circle
                          Positioned(
                            top: 14,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.directions_walk,
                                  size: 5,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          // Checkmark at end of coin arc if coins target achieved
                          if (coins >= 50)
                            _ArcEndCheckmark(
                              radius: 60,
                              percent: 1.0,
                              color: Colors.greenAccent,
                            ),
                          // Checkmark at end of step arc if step target achieved
                          if (steps >= stepTarget)
                            _ArcEndCheckmark(
                              radius: 50,
                              percent: 1.0,
                              color: Colors.white,
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Stats on the right
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16, left: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.attach_money,
                                color: Colors.greenAccent,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${coins}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.greenAccent,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'coins',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.purpleAccent,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${distance.toStringAsFixed(1)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purpleAccent,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'km',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                color: Colors.orangeAccent,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${calories}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orangeAccent,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'cal',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Page 3: Friends card (as in your screenshot)
            Container(
              width: screenWidth,
              height: topHeight,
              decoration: BoxDecoration(
                color: Colors.green[900]?.withOpacity(0.95),
                borderRadius: BorderRadius.circular(18),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions_walk,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                      const SizedBox(width: 8),
                      Icon(Icons.flag, color: Colors.greenAccent, size: 32),
                      const SizedBox(width: 8),
                      Icon(Icons.track_changes, color: Colors.orange, size: 32),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Add friends, compete and stay updated',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Staying fit is easier with your friends/family. A little friendly competition will spur you on!',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('Find Friends'),
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

// Dots indicator widget
class _DashboardPagerDots extends StatelessWidget {
  final int page;
  const _DashboardPagerDots({required this.page});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          3,
          (i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: page == i ? Colors.greenAccent : Colors.white24,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
