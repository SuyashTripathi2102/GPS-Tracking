import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTheme {
  static Color primary = const Color(0xFF7A5CF5);
  static Color accent = const Color(0xFFFFBD4A);
  static Color background = const Color(0xFFF5F3FF);
  static Color card = Colors.white;
  static Color darkText = const Color(0xFF2B2B2B);

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.light(
      primary: primary,
      secondary: accent,
      background: background,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: darkText,
      elevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        color: darkText,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primary,
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        shadowColor: primary.withOpacity(0.5),
      ),
    ),
    cardTheme: CardThemeData(
      color: card,
      shadowColor: Colors.black26,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    ),
  );
}
