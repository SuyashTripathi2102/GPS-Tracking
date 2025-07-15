import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode;
  ThemeProvider(String theme)
    : _themeMode = theme == 'dark'
          ? ThemeMode.dark
          : theme == 'light'
          ? ThemeMode.light
          : ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setTheme(String theme) {
    print('ThemeProvider: setTheme called with value: ' + theme);
    _themeMode = theme == 'dark'
        ? ThemeMode.dark
        : theme == 'light'
        ? ThemeMode.light
        : ThemeMode.system;
    notifyListeners();
  }

  bool _isHighContrast = false;
  double _fontScale = 1.0;

  bool get isHighContrast => _isHighContrast;
  double get fontScale => _fontScale;

  void setHighContrast(bool value) {
    _isHighContrast = value;
    notifyListeners();
  }

  void setFontScale(double scale) {
    _fontScale = scale;
    notifyListeners();
  }

  ThemeData get themeData {
    if (_isHighContrast) {
      final base = _themeMode == ThemeMode.dark
          ? ThemeData.dark()
          : ThemeData.light();
      return base.copyWith(
        colorScheme: base.colorScheme.copyWith(
          primary: Colors.black,
          secondary: Colors.yellow,
          background: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.white,
        textTheme: base.textTheme.apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
          fontSizeFactor: _fontScale,
        ),
      );
    }
    return _themeMode == ThemeMode.dark ? customDarkTheme : customTheme;
  }

  ThemeData get darkThemeData => customDarkTheme;
}

final ThemeData customTheme = ThemeData.light().copyWith(
  scaffoldBackgroundColor: const Color(0xFFF9F9FB),
  primaryColor: const Color(0xFF6C63FF),
  cardColor: Colors.white,
  appBarTheme: const AppBarTheme(
    color: Colors.white,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w600,
      fontSize: 20,
      fontFamily: 'Poppins',
    ),
  ),
  textTheme: ThemeData.light().textTheme.copyWith(
    headlineMedium: ThemeData.light().textTheme.headlineMedium?.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.black,
      fontFamily: 'Poppins',
    ),
    titleMedium: ThemeData.light().textTheme.titleMedium?.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.black,
      fontFamily: 'Poppins',
    ),
    bodyMedium: ThemeData.light().textTheme.bodyMedium?.copyWith(
      fontSize: 14,
      color: Colors.black87,
      fontFamily: 'Poppins',
    ),
    labelLarge: ThemeData.light().textTheme.labelLarge?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      fontFamily: 'Poppins',
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF6C63FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      textStyle: ThemeData.light().textTheme.labelLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
        color: Colors.white,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  ),
  tabBarTheme: TabBarThemeData(
    labelColor: const Color(0xFF6C63FF),
    unselectedLabelColor: Colors.grey,
    labelStyle: ThemeData.light().textTheme.labelLarge?.copyWith(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: ThemeData.light().textTheme.labelLarge?.copyWith(
      fontFamily: 'Poppins',
    ),
  ),
);

final ThemeData customDarkTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: const Color(0xFF181829),
  primaryColor: const Color(0xFF7A5CF5),
  cardColor: const Color(0xFF23234A),
  appBarTheme: const AppBarTheme(
    color: Color(0xFF23234A),
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
      fontSize: 20,
      fontFamily: 'Poppins',
    ),
  ),
  textTheme: ThemeData.dark().textTheme.copyWith(
    headlineMedium: ThemeData.dark().textTheme.headlineMedium?.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontFamily: 'Poppins',
    ),
    titleMedium: ThemeData.dark().textTheme.titleMedium?.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      fontFamily: 'Poppins',
    ),
    bodyMedium: ThemeData.dark().textTheme.bodyMedium?.copyWith(
      fontSize: 14,
      color: Colors.white70,
      fontFamily: 'Poppins',
    ),
    labelLarge: ThemeData.dark().textTheme.labelLarge?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      fontFamily: 'Poppins',
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF7A5CF5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      textStyle: ThemeData.dark().textTheme.labelLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
        color: Colors.white,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF23234A),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  ),
  tabBarTheme: TabBarThemeData(
    labelColor: const Color(0xFF7A5CF5),
    unselectedLabelColor: Colors.grey,
    labelStyle: ThemeData.dark().textTheme.labelLarge?.copyWith(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: ThemeData.dark().textTheme.labelLarge?.copyWith(
      fontFamily: 'Poppins',
    ),
  ),
);
