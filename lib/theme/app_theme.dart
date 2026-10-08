import 'package:flutter/material.dart';

import '../services/sla_service.dart';

class AppColors {
  static const primary = Color(0xFF3F51B5);
  static const background = Color(0xFFF5F6FA);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF1F2430);
  static const textSecondary = Color(0xFF6B7280);

  static const slaCompleted = Color(0xFF2E7D32);
  static const slaOverdue = Color(0xFFD32F2F);
  static const slaAtRisk = Color(0xFFF9A825);
  static const slaOnTrack = Color(0xFF1976D2);
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class AppTheme {
  static Color slaColor(SlaState state) {
    switch (state) {
      case SlaState.completed:
        return AppColors.slaCompleted;
      case SlaState.overdue:
        return AppColors.slaOverdue;
      case SlaState.atRisk:
        return AppColors.slaAtRisk;
      case SlaState.onTrack:
        return AppColors.slaOnTrack;
    }
  }

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
}