import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme { light, dark, system }

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  AppTheme _selectedTheme = AppTheme.system;

  ThemeProvider() {
    loadTheme();
  }

  ThemeMode get themeMode => _themeMode;
  AppTheme get selectedTheme => _selectedTheme;

  void setTheme(AppTheme theme) async {
    _selectedTheme = theme;
    switch (theme) {
      case AppTheme.light:
        _themeMode = ThemeMode.light;
        break;
      case AppTheme.dark:
        _themeMode = ThemeMode.dark;
        break;
      case AppTheme.system:
      default:
        _themeMode = ThemeMode.system;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('app_theme', theme.toString());
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString('app_theme') ?? 'AppTheme.system';
    setTheme(
      AppTheme.values.firstWhere(
        (e) => e.toString() == themeStr,
        orElse: () => AppTheme.system,
      ),
    );
  }
}
