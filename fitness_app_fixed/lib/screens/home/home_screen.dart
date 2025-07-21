import 'package:flutter/material.dart';
import '../../widgets/overview_card.dart';
import '../../widgets/module_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app_fixed/widgets/challenge_card.dart';
import 'package:fitness_app_fixed/data/database/challenge_db.dart';
import 'package:fitness_app_fixed/services/notification_service.dart';
import 'package:fitness_app_fixed/screens/sticker_album.dart';
import 'package:fitness_app_fixed/screens/gamification/leaderboard_screen.dart';
import 'package:fitness_app_fixed/screens/dashboard/dashboard_dualcircle_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Health Tracker Overview',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.remove_red_eye_outlined, // Preview icon
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            tooltip: 'Preview New Dashboard',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DashboardDualCircleScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_none_outlined,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.orange),
            onPressed: () async {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final dialogTextColor = isDark ? Colors.white : Colors.black;
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Row(
                    children: [
                      const Icon(Icons.logout, color: Colors.orange),
                      SizedBox(width: 8),
                      const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  content: Text(
                    'Are you sure you want to logout?',
                    style: TextStyle(
                      color: dialogTextColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: dialogTextColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              );
              if (shouldLogout == true) {
                await FirebaseAuth.instance.signOut();
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        const Text(
                          'Success',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                    content: Text(
                      'Logout successful!',
                      style: TextStyle(
                        color: dialogTextColor,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'OK',
                          style: TextStyle(
                            color: dialogTextColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Cards Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                OverviewCard(
                  icon: Icons.directions_walk,
                  label: 'Steps',
                  value: '7,500',
                  color: Colors.purple,
                  isSteps: true,
                  progress: 0.75, // 75% of target
                ),
                OverviewCard(
                  icon: Icons.map,
                  label: 'Distance',
                  value: '5.2 km',
                  color: Colors.blue,
                ),
                OverviewCard(
                  icon: Icons.local_fire_department,
                  label: 'Kcal',
                  value: '320',
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Health Modules',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.7,
              children: const [
                ModuleCard(
                  icon: Icons.favorite,
                  label: 'Heart Rate',
                  data: '72 bpm',
                  color: Colors.pink,
                ),
                ModuleCard(
                  icon: Icons.bedtime,
                  label: 'Sleep',
                  data: '7 Hr 20 Min',
                  color: Colors.indigo,
                ),
                ModuleCard(
                  icon: Icons.sports_basketball,
                  label: 'Sports Records',
                  data: 'No data',
                  color: Colors.orange,
                ),
                ModuleCard(
                  icon: Icons.mood,
                  label: 'Mood Tracking',
                  data: 'No data',
                  color: Colors.amber,
                ),
                ModuleCard(
                  icon: Icons.bloodtype,
                  label: 'Blood Oxygen',
                  data: 'No data',
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9F71F2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "Edit Data Card",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // After Edit Data Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "🎯 Today's Fun Challenges",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ChallengeCard(
                    title: "Walk like an animal!",
                    subtitle: "Take 300 steps like your favorite animal",
                    reward: "Lion Sticker",
                    status: ChallengeStatus.ready,
                    color: const Color(0xFFFFF6D6), // pastel yellow
                    icon: Icons.pets,
                    onPressed: () async {
                      await ChallengeDB.saveChallenge({
                        'id': 'walk_animal',
                        'title': 'Walk like an animal!',
                        'subtitle': 'Take 300 steps like your favorite animal',
                        'reward': 'Lion Sticker',
                        'status': 'done',
                      });
                      await NotificationService.showCompletedNotification(
                        'Walk like an animal!',
                      );
                    },
                  ),
                  ChallengeCard(
                    title: "Color Run!",
                    subtitle: "Run until you collect 3 colors",
                    reward: "Rainbow Sticker",
                    status: ChallengeStatus.done,
                    color: const Color(0xFFD6F5E6), // pastel green
                    icon: Icons.color_lens,
                    onPressed: null,
                  ),
                  ChallengeCard(
                    title: "Rocket Boost!",
                    subtitle: "Sprint for 1 minute to earn turbo power",
                    reward: "Rocket Sticker",
                    status: ChallengeStatus.ready,
                    color: const Color(0xFFE6E6FA), // pastel blue/lavender
                    icon: Icons.rocket_launch,
                    onPressed: () async {
                      await ChallengeDB.saveChallenge({
                        'id': 'rocket_boost',
                        'title': 'Rocket Boost!',
                        'subtitle': 'Sprint for 1 minute to earn turbo power',
                        'reward': 'Rocket Sticker',
                        'status': 'done',
                      });
                      await NotificationService.showCompletedNotification(
                        'Rocket Boost!',
                      );
                    },
                  ),
                  ChallengeCard(
                    title: "Sneaker Swap!",
                    subtitle:
                        "Do 5 jumping jacks to switch shoes\nComplete 2 more challenges to unlock!",
                    reward: "Sneaker Sticker",
                    status: ChallengeStatus.locked,
                    color: const Color(0xFFF2F2F2), // pastel grey
                    icon: Icons.lock,
                    onPressed: null,
                  ),
                  const SizedBox(height: 18),
                  // Sticker Album Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: theme.brightness == Brightness.dark
                              ? Colors.black26
                              : Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.emoji_events,
                              color: theme.brightness == Brightness.dark
                                  ? Colors.amber[200]
                                  : Color(0xFFFFB300),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Your Sticker Album",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _StickerIconBox(
                              emoji: '🌈',
                              color: Color(0xFFD6F5E6),
                            ),
                            const SizedBox(width: 12),
                            _StickerIconBox(
                              emoji: '⭐',
                              color: Color(0xFFFFF6D6),
                            ),
                            const SizedBox(width: 12),
                            _StickerIconBox(
                              emoji: '🎯',
                              color: Color(0xFFE6E6FA),
                            ),
                            const SizedBox(width: 12),
                            _StickerIconBox(
                              emoji: '?',
                              color: Color(0xFFF2F2F2),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LeaderboardScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFB39DDB),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "View More Achievements",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
    );
  }
}

class _StickerIconBox extends StatelessWidget {
  final String emoji;
  final Color color;
  const _StickerIconBox({Key? key, required this.emoji, required this.color})
    : super(key: key);
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? color.withOpacity(0.22) : color;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.black12,
          width: 1.2,
        ),
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(
            fontSize: 22,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
