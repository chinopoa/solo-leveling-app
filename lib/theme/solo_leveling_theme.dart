import 'package:flutter/material.dart';

/// Solo Leveling inspired dark theme with glowing cyan accents
class SoloLevelingTheme {
  // Core colors
  static const Color primaryCyan = Color(0xFF00FFFF);
  static const Color primaryBlue = Color(0xFF0080FF);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color shadowPurple = Color(0xFF7C3AED);

  // Background colors
  static const Color backgroundDark = Color(0xFF0A0A0F);
  static const Color backgroundCard = Color(0xFF12121A);
  static const Color backgroundElevated = Color(0xFF1A1A24);

  // Status colors
  static const Color hpRed = Color(0xFFEF4444);
  static const Color mpBlue = Color(0xFF3B82F6);
  static const Color xpGold = Color(0xFFF59E0B);
  static const Color fatigueOrange = Color(0xFFF97316);
  static const Color successGreen = Color(0xFF22C55E);

  // Stat colors
  static const Color strColor = Color(0xFFEF4444); // Red
  static const Color agiColor = Color(0xFF22C55E); // Green
  static const Color vitColor = Color(0xFFF59E0B); // Gold
  static const Color intColor = Color(0xFF3B82F6); // Blue
  static const Color senColor = Color(0xFF8B5CF6); // Purple

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF6B7280);

  // Glow effects
  static List<BoxShadow> glowEffect(Color color, {double intensity = 1.0}) {
    return [
      BoxShadow(
        color: color.withOpacity(0.3 * intensity),
        blurRadius: 8 * intensity,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: color.withOpacity(0.2 * intensity),
        blurRadius: 16 * intensity,
        spreadRadius: 2,
      ),
    ];
  }

  static BoxDecoration get systemWindowDecoration => BoxDecoration(
        color: backgroundCard,
        border: Border.all(
          color: primaryCyan.withOpacity(0.5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: glowEffect(primaryCyan, intensity: 0.5),
      );

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: backgroundCard,
        border: Border.all(
          color: primaryCyan.withOpacity(0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: primaryCyan,
      colorScheme: const ColorScheme.dark(
        primary: primaryCyan,
        secondary: accentPurple,
        surface: backgroundCard,
        error: hpRed,
      ),
      fontFamily: 'Rajdhani',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: 2,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: 1.5,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: primaryCyan,
          letterSpacing: 1,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primaryCyan,
          letterSpacing: 1,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Rajdhani',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: primaryCyan,
          letterSpacing: 2,
        ),
      ),
      cardTheme: CardThemeData(
        color: backgroundCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: primaryCyan.withOpacity(0.2),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryCyan.withOpacity(0.2),
          foregroundColor: primaryCyan,
          side: const BorderSide(color: primaryCyan),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryCyan,
        foregroundColor: backgroundDark,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundCard,
        selectedItemColor: primaryCyan,
        unselectedItemColor: textMuted,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryCyan,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryCyan,
        inactiveTrackColor: primaryCyan.withOpacity(0.2),
        thumbColor: primaryCyan,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: primaryCyan.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: primaryCyan.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: primaryCyan),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textMuted),
      ),
    );
  }

  // Rank colors
  static Color getRankColor(String rank) {
    switch (rank.toUpperCase()) {
      case 'S':
        return const Color(0xFFFFD700); // Gold
      case 'A':
        return const Color(0xFFFF6B6B); // Red-ish
      case 'B':
        return const Color(0xFFFF9F43); // Orange
      case 'C':
        return const Color(0xFF54A0FF); // Blue
      case 'D':
        return const Color(0xFF5F27CD); // Purple
      case 'E':
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  // Stat color getter
  static Color getStatColor(String stat) {
    switch (stat.toUpperCase()) {
      case 'STR':
        return strColor;
      case 'AGI':
        return agiColor;
      case 'VIT':
        return vitColor;
      case 'INT':
        return intColor;
      case 'SEN':
        return senColor;
      default:
        return primaryCyan;
    }
  }
}
