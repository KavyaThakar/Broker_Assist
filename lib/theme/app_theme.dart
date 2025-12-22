// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF0A3D62); // Navy Dark Blue
  static const Color accentGreen = Color(0xFF1DD1A1); // Mint Green
  static const Color lightBackground = Color(0xFFF4F6F9);
  static const Color cardColor = Colors.white;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // ----------- COLORS -----------
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: accentGreen,
        surface: Colors.white,
      ),

      // ----------- APP BAR -----------
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // ----------- BUTTONS -----------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: const BorderSide(color: primaryBlue, width: 1.3),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      // ----------- TEXT FIELDS -----------
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryBlue, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),

      // ----------- FIXED CARD THEME -----------
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ----------- TEXT STYLE -----------
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: primaryBlue,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          color: Colors.black87,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          color: Colors.black54,
        ),
      ),

      // ----------- LIST TILE -----------
      listTileTheme: const ListTileThemeData(
        iconColor: primaryBlue,
      ),
    );
  }
}
