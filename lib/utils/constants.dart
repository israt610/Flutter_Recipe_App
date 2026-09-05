import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF8C61);
  static const Color primaryDark = Color(0xFFE85520);

  static const Color secondary = Color(0xFFFF9F1C);
  static const Color accent = Color(0xFF2EC4B6);

  static const Color background = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;

  static const Color textPrimary = Color(0xFF1E2124);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textMuted = Color(0xFFA0AAB2);

  static const Color border = Color(0xFFE9ECEF);
  static const Color divider = Color(0xFFF1F3F5);

  static const Color error = Color(0xFFE63946);
  static const Color success = Color(0xFF38B000);
  static const Color starRating = Color(0xFFFFB703);
}

class AppConstants {
  static const String appName = 'RecipeHub';

  static const List<String> categories = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Dessert',
    'Snack',
    'Drink',
  ];
}
