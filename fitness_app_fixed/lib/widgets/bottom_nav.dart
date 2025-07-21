import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SalomonBottomBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        SalomonBottomBarItem(
          icon: const Icon(Icons.home, size: 22),
          title: const Text("Home", style: TextStyle(fontSize: 11)),
          selectedColor: const Color(0xFF6C63FF),
        ),
        SalomonBottomBarItem(
          icon: Icon(Icons.directions_walk, size: 22),
          title: const Text("Walk", style: TextStyle(fontSize: 11)),
          selectedColor: const Color(0xFF6C63FF),
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.insights, size: 22),
          title: const Text("Progress", style: TextStyle(fontSize: 11)),
          selectedColor: const Color(0xFF6C63FF),
        ),
        SalomonBottomBarItem(
          icon: ColorFiltered(
            colorFilter: ColorFilter.mode(
              Theme.of(context).iconTheme.color ?? Colors.white,
              BlendMode.srcIn,
            ),
            child: Image.asset(
              'assets/icons/tablet-android.png',
              width: 22,
              height: 22,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.watch,
                size: 22,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
          ),
          title: const Text("Devices", style: TextStyle(fontSize: 11)),
          selectedColor: const Color(0xFF6C63FF),
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.person, size: 22),
          title: const Text("Profile", style: TextStyle(fontSize: 11)),
          selectedColor: const Color(0xFF6C63FF),
        ),
      ],
    );
  }
}
