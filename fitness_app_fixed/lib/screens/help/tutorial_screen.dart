import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(title: "Welcome", body: "Track your fitness easily."),
        PageViewModel(
          title: "Connect Devices",
          body: "Pair your fitness trackers.",
        ),
        PageViewModel(
          title: "Earn Achievements",
          body: "Stay motivated with gamification.",
        ),
      ],
      onDone: () => Navigator.pushReplacementNamed(context, '/home'),
      showSkipButton: true,
      skip: const Text("Skip"),
      next: const Icon(Icons.arrow_forward),
      done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
