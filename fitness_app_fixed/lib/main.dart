import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_provider.dart';
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

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider('system')),
        // Add other providers here if needed
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _notificationsInitialized = false;

  @override
  Widget build(BuildContext context) {
    // Only initialize notifications once, after the first frame and when context is available
    if (!_notificationsInitialized && navigatorKey.currentContext != null) {
      _notificationsInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await NotificationHelper.initialize(navigatorKey.currentContext!);
        await NotificationHelper.scheduleDefaultDailyReminder();
      });
    }

    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'FitTrack',
      theme: themeProvider.themeData,
      darkTheme: themeProvider.darkThemeData,
      themeMode: themeProvider.themeMode,
      home: const OnboardingWrapper(),
      routes: {
        '/login': (context) => const OnboardingWrapper(),
        '/signup': (context) => const SignupScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/onboarding': (context) => const OnboardingWrapper(),
        '/home': (context) => const AppRoot(),
        '/theme': (context) => const ThemeScreen(),
      },
    );
  }
}
