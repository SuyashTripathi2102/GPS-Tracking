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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _pagerPage = 0;
  late final PageController _pagerController;

  // Example user data (replace with real data integration)
  final int steps = 4200;
  final int stepTarget = 5000;
  final double co2Value = 12.3; // Example CO2 value
  final double distance = 3.7;
  final int calories = 220;

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
          maxLines: 2,
          overflow: TextOverflow.visible,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontSize: 19,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_none_outlined,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  final theme = Theme.of(context);
                  final bgColor = theme.colorScheme.background;
                  final textColor = theme.textTheme.bodyLarge?.color;
                  return AlertDialog(
                    backgroundColor: bgColor,
                    title: Row(
                      children: [
                        Icon(Icons.notifications, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Notifications',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    content: SizedBox(
                      width: 300,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.directions_walk,
                              color: Colors.purple,
                            ),
                            title: Text(
                              'You reached 5,000 steps!',
                              style: TextStyle(color: textColor),
                            ),
                            subtitle: Text(
                              'Today, 10:00 AM',
                              style: TextStyle(
                                color: textColor?.withOpacity(0.7),
                              ),
                            ),
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.emoji_events,
                              color: Colors.amber,
                            ),
                            title: Text(
                              'New badge earned: Step Master',
                              style: TextStyle(color: textColor),
                            ),
                            subtitle: Text(
                              'Yesterday, 8:30 PM',
                              style: TextStyle(
                                color: textColor?.withOpacity(0.7),
                              ),
                            ),
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.local_fire_department,
                              color: Colors.redAccent,
                            ),
                            title: Text(
                              'You burned 300 kcal!',
                              style: TextStyle(color: textColor),
                            ),
                            subtitle: Text(
                              'Yesterday, 7:00 PM',
                              style: TextStyle(
                                color: textColor?.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Close',
                          style: TextStyle(color: textColor),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
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
            // Replace Overview Cards Row with the new dashboard pager
            LayoutBuilder(
              builder: (context, constraints) {
                return DashboardHorizontalPager(
                  co2Value: co2Value, // Pass CO2 value instead of coins
                  steps: steps,
                  stepTarget: stepTarget,
                  distance: distance,
                  calories: calories,
                  isDark: theme.brightness == Brightness.dark,
                  controller: _pagerController,
                  onPageChanged: (i) => setState(() => _pagerPage = i),
                  width: constraints.maxWidth,
                  useMargin: false,
                );
              },
            ),
            DashboardPagerDots(page: _pagerPage),
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
                  icon: Icons.nightlight_round,
                  label: 'Sleep',
                  data: '7 Hr 20 Min',
                  color: Colors.indigo,
                ),
                ModuleCard(
                  icon: Icons.eco,
                  label: 'CO₂',
                  data: '12.3 kg CO₂',
                  color: Colors.blue,
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
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      final theme = Theme.of(context);
                      final bgColor = theme.colorScheme.background;
                      final textColor = theme.textTheme.bodyLarge?.color;
                      // Demo: local state for modules
                      return StatefulBuilder(
                        builder: (context, setState) {
                          List<Map<String, dynamic>> modules = [
                            {'icon': Icons.eco, 'label': 'Eco-Friendly'},
                            {'icon': Icons.nature, 'label': 'Carbon Footprint'},
                            {
                              'icon': Icons.sports_basketball,
                              'label': 'Sports Records',
                            },
                            {'icon': Icons.mood, 'label': 'Mood Tracking'},
                            {'icon': Icons.bloodtype, 'label': 'Blood Oxygen'},
                          ];
                          List<Map<String, dynamic>> availableModules = [
                            {'icon': Icons.water_drop, 'label': 'Hydration'},
                            {'icon': Icons.monitor_heart, 'label': 'ECG'},
                            {'icon': Icons.fitness_center, 'label': 'Strength'},
                          ];
                          int? selectedReplaceIndex;
                          String? selectedAddLabel;
                          return AlertDialog(
                            backgroundColor: bgColor,
                            title: Row(
                              children: [
                                Icon(Icons.edit, color: Color(0xFF9F71F2)),
                                SizedBox(width: 8),
                                Text(
                                  'Edit Data Card',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                            content: SizedBox(
                              width:
                                  MediaQuery.of(context).size.width *
                                  0.9, // Increased width for readability
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Your Modules:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...modules.asMap().entries.map((entry) {
                                      int idx = entry.key;
                                      var mod = entry.value;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 2,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              mod['icon'],
                                              color: theme.colorScheme.primary,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Tooltip(
                                                message: mod['label'],
                                                child: Text(
                                                  mod['label'],
                                                  style: TextStyle(
                                                    color: textColor,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.swap_horiz,
                                                    color: Colors.blue,
                                                  ),
                                                  tooltip: 'Replace',
                                                  onPressed: () {
                                                    setState(() {
                                                      selectedReplaceIndex =
                                                          idx;
                                                    });
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                  tooltip: 'Remove',
                                                  onPressed: () {
                                                    setState(() {
                                                      modules.removeAt(idx);
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                    const Divider(),
                                    if (selectedReplaceIndex == null) ...[
                                      Text(
                                        'Add Module:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      DropdownButton<String>(
                                        value: selectedAddLabel,
                                        hint: Text('Select module'),
                                        items: availableModules.map((mod) {
                                          return DropdownMenuItem<String>(
                                            value: mod['label'],
                                            child: Row(
                                              children: [
                                                Icon(
                                                  mod['icon'],
                                                  color:
                                                      theme.colorScheme.primary,
                                                ),
                                                SizedBox(width: 8),
                                                Text(mod['label']),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          setState(() {
                                            selectedAddLabel = val;
                                          });
                                        },
                                      ),
                                      ElevatedButton(
                                        onPressed: selectedAddLabel == null
                                            ? null
                                            : () {
                                                final mod = availableModules
                                                    .firstWhere(
                                                      (m) =>
                                                          m['label'] ==
                                                          selectedAddLabel,
                                                    );
                                                setState(() {
                                                  modules.add(mod);
                                                  selectedAddLabel = null;
                                                });
                                              },
                                        child: Text('Add'),
                                      ),
                                    ] else ...[
                                      Text(
                                        'Replace with:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      DropdownButton<String>(
                                        value: selectedAddLabel,
                                        hint: Text('Select module'),
                                        items: availableModules.map((mod) {
                                          return DropdownMenuItem<String>(
                                            value: mod['label'],
                                            child: Row(
                                              children: [
                                                Icon(
                                                  mod['icon'],
                                                  color:
                                                      theme.colorScheme.primary,
                                                ),
                                                SizedBox(width: 8),
                                                Text(mod['label']),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          setState(() {
                                            selectedAddLabel = val;
                                          });
                                        },
                                      ),
                                      ElevatedButton(
                                        onPressed: selectedAddLabel == null
                                            ? null
                                            : () {
                                                final mod = availableModules
                                                    .firstWhere(
                                                      (m) =>
                                                          m['label'] ==
                                                          selectedAddLabel,
                                                    );
                                                setState(() {
                                                  modules[selectedReplaceIndex!] =
                                                      mod;
                                                  selectedReplaceIndex = null;
                                                  selectedAddLabel = null;
                                                });
                                              },
                                        child: Text('Replace'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            selectedReplaceIndex = null;
                                            selectedAddLabel = null;
                                          });
                                        },
                                        child: Text('Cancel'),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  'Close',
                                  style: TextStyle(color: textColor),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
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
