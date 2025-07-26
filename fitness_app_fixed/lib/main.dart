import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'utils/notification_helper.dart';
import 'screens/home/app_root.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/theme_screen.dart';
import 'screens/devices/device_screen.dart';
import 'screens/devices/bluetooth_scan_page.dart';
import 'theme/theme.dart';
import 'screens/home/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // Add other providers here if needed
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'FitTrack',
      theme: CustomTheme.lightTheme,
      darkTheme: CustomTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const OnboardingWrapper(),
        '/signup': (context) => const SignupScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/onboarding': (context) => const OnboardingWrapper(),
        '/home': (context) => const AppRoot(),
        '/theme': (context) => const ThemeScreen(),
        '/onboarding/theme': (context) =>
            const ThemeScreen(), // <-- Added missing route
      },
    );
  }
}
