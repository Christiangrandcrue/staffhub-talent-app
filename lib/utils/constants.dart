import 'package:flutter/material.dart';

class AppColors {
  // Primary palette - Dark Premium theme
  static const Color primaryPurple = Color(0xFFa855f7);
  static const Color secondaryAmber = Color(0xFFf59e0b);
  static const Color background = Color(0xFF0f0f23);
  static const Color surface = Color(0xFF1a1a2e);
  static const Color cardBackground = Color(0xFF16162a);
  
  // Glass morphism colors
  static const Color glassLight = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  
  // Status colors
  static const Color success = Color(0xFF22c55e);
  static const Color warning = Color(0xFFf59e0b);
  static const Color error = Color(0xFFef4444);
  static const Color info = Color(0xFF3b82f6);
  
  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFa1a1aa);
  static const Color textMuted = Color(0xFF71717a);
}

class AppConstants {
  static const String baseUrl = 'https://me.synthnova.me/api';
  static const String webPortal = 'https://me.synthnova.me';
  
  // Cache durations
  static const Duration profileCacheDuration = Duration(hours: 24);
  static const Duration jobsCacheDuration = Duration(minutes: 5);
  static const Duration documentsCacheDuration = Duration(hours: 1);
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textMuted,
  );
  
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );
}
