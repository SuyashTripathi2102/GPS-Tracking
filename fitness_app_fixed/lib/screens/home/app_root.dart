import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../activity/exercise_screen.dart';
import '../progress/progress_screen.dart';
import '../../widgets/bottom_nav.dart';
import '../devices/device_screen.dart';
import '../profile_screen.dart';
// If you have a real LeaderboardScreen, import it here, otherwise keep the mock for now.
// import '../leaderboard/leaderboard_screen.dart';

class AppRoot extends StatefulWidget {
  final int initialTab;
  const AppRoot({Key? key, this.initialTab = 0}) : super(key: key);

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    _pageController = PageController(initialPage: _currentIndex);
  }

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
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          HomeScreen(),
          ExerciseScreen(),
          ProgressScreen(), // <-- Use the new ProgressScreen here
          DeviceScreen(),
          ProfileScreen(),
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
