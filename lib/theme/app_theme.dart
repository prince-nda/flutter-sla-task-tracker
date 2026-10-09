import 'package:flutter/material.dart';

import '../models/task.dart';

/// Single source of truth for colors, so every screen stays consistent.
class AppColors {
  // Brand palette
  static const blue = Color(0xFF3A4EFB);
  static const sky = Color(0xFF33A4FA);
  static const lime = Color(0xFFE3FF3B);
  static const navy = Color(0xFF252943);
  static const mist = Color(0xFFDEE0ED);

  // SLA status colors (amber and red are added; they are not in the palette)
  static const onTrack = Color(0xFF1FA971);
  static const atRisk = Color(0xFFFFB020);
  static const overdue = Color(0xFFE5484D);
  static const completed = sky;

  static const headerGradient = LinearGradient(
    colors: [blue, sky],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color forSla(SlaStatus s) => switch (s) {
        SlaStatus.onTrack => onTrack,
        SlaStatus.atRisk => atRisk,
        SlaStatus.overdue => overdue,
        SlaStatus.completed => completed,
      };

  static IconData iconForSla(SlaStatus s) => switch (s) {
        SlaStatus.onTrack => Icons.check_circle_outline,
        SlaStatus.atRisk => Icons.warning_amber_rounded,
        SlaStatus.overdue => Icons.error_outline,
        SlaStatus.completed => Icons.task_alt,
      };
}

/// Shared spacing values (multiples of 4) used for padding and gaps.
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.mist,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.blue,
    primary: AppColors.blue,
    onPrimary: Colors.white,
    secondary: AppColors.lime,
    onSecondary: AppColors.navy,
    surface: Colors.white,
    onSurface: AppColors.navy,
  ),
  textTheme: Typography.blackMountainView.apply(
    bodyColor: AppColors.navy,
    displayColor: AppColors.navy,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.blue,
    foregroundColor: Colors.white,
    centerTitle: true,
    elevation: 0,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.lime,
    foregroundColor: AppColors.navy,
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Colors.white,
    indicatorColor: AppColors.lime,
    labelTextStyle: WidgetStateProperty.all(
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.blue,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.mist),
    ),
  ),
);
