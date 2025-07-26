import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../onboarding/onboarding_screen.dart';
import 'app_root.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 2500), _navigateNext);
  }

  void _navigateNext() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingWrapper()),
        (route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AppRoot()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Always use the dark logo for splash, regardless of theme
    const logoAsset = 'assets/images/logo_dark.png';
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Image.asset(
          logoAsset,
          width: MediaQuery.of(context).size.width * 0.7,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
