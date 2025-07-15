import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../activity/exercise_screen.dart';
import '../history_screen.dart';
import '../../widgets/bottom_nav.dart';
import '../devices/device_screen.dart';

class AppRoot extends StatefulWidget {
  static final GlobalKey<_AppRootState> appRootKey = GlobalKey<_AppRootState>();
  const AppRoot({super.key});

  /// Call this from anywhere to switch tabs
  static void switchToTab(int index) {
    final state = appRootKey.currentState;
    state?._onNavTapped(index);
  }

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onNavTapped(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: AppRoot.appRootKey,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          HomeScreen(),
          ExerciseScreen(),
          HistoryScreen(),
          DeviceScreen(), // Use the real Devices page
          const _MockScreen(title: 'Leaderboard'),
          const _MockScreen(title: 'Profile'),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTapped,
      ),
    );
  }
}

class _MockScreen extends StatelessWidget {
  final String title;
  const _MockScreen({required this.title});
  @override
  Widget build(BuildContext context) {
    return Center(child: Text(title, style: const TextStyle(fontSize: 24)));
  }
}
