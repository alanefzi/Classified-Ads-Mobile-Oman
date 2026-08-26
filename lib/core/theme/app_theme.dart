import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF2E2B5C);
  static const accent = Color(0xFF5FBFA0);
  static const primaryLight = Color(0xFFEDEBF5);
  static const background = Color(0xFFF4F4F5);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF18181B);
  static const textSecondary = Color(0xFF71717A);
  static const border = Color(0xFFE4E4E7);
  static const success = Color(0xFF22C55E);
  static const danger = Color(0xFFEF4444);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
      ),
      fontFamily: 'Cairo',
    );
  }
}