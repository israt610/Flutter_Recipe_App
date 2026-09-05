import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette - Reference Dark Teal
  static const Color primary = Color(0xFF366B72);
  static const Color primaryLight = Color(0xFF50858C);
  static const Color primaryDark = Color(0xFF254B50);

  static const Color secondary = Color(0xFFFF9F1C);
  static const Color accent = Color(0xFF2EC4B6);

  // Background & Surface
  static const Color background = Color(0xFFF8FAFC);
  static const Color cardBackground = Colors.white;
  static const Color badgeBackground = Color(0xFFEBF1F5);

  // Typography
  static const Color textPrimary = Color(0xFF1E2124);
  static const Color textSecondary = Color(0xFF717D8A);
  static const Color textMuted = Color(0xFFA0AAB2);

  // Borders & Dividers
  static const Color border = Color(0xFFE9ECEF);
  static const Color divider = Color(0xFFF1F3F5);

  // Status Indicators
  static const Color error = Color(0xFFE63946);
  static const Color success = Color(0xFF38B000);
  static const Color starRating = Color(0xFFFFB703);
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

class AppConstants {
  static const String appName = 'Recipe Hub';

  static const List<String> categories = [
    'All',
    'Dinner',
    'Lunch',
    'Breakfast',
    'Dessert',
    'Snack',
    'Drink',
    'Vegetarian',
  ];
}
