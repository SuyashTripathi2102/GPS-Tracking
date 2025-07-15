import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'gender_screen.dart';
import '../home/home_screen.dart';
import '../auth/login_screen.dart';
import 'whats_new_screen.dart';
import 'theme_screen.dart';
import '../auth/signup_screen.dart';
import '../auth/forgot_password_screen.dart';

class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({super.key});

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  bool? isOnboarded;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkAuthAndOnboarding();
  }

  Future<void> checkAuthAndOnboarding() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        isOnboarded = null;
        isLoading = false;
      });
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final onboarded = prefs.getBool('onboarded_${user.uid}') ?? false;
    setState(() {
      isOnboarded = onboarded;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F8FF),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF7A5CF5)),
        ),
      );
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return LoginScreen(
        onSignup: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SignupScreen()),
        ),
        onForgotPassword: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
        ),
      );
    }
    if (isOnboarded == false) {
      return const GenderScreen();
    }
    // Always use AppRoot for home navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, '/home');
    });
    return const SizedBox.shrink();
  }
}
