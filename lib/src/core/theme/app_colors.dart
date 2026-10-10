import 'package:flutter/material.dart';

/// Central color palette for Neon Wave.
class AppColors {
  AppColors._();

  static final AppColors instance = AppColors._();

  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF121212);
  static const Color surfaceElevated = Color(0xFF1C1C1E);
  static const Color surfaceBorder = Color(0x1AFFFFFF); // white @ 10%

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0x99FFFFFF); // white @ 60%
  static const Color textMuted = Color(0x61FFFFFF); // white @ 38%

  static const Color cyanAccent = Color(0xFF00E5FF);
  static const Color cyanAccentDim = Color(0xFF0097A7);

  static const Color error = Color(0xFFFF5252);
  static const Color success = Color(0xFF69F0AE);
  static const Color warning = Color(0xFFFFD54F);

  // Instance getters for dynamic design sample compatibility
  Color get black => const Color(0xFF000000);
  Color get white => const Color(0xFFFFFFFF);
  Color get gray => const Color(0xFF9E9E9E);
  Color get shadeblack => surface;
  Color get gray300 => const Color(0xFFE0E0E0);
  Color get cyanAccentColor => cyanAccent;

  bool get isDarkMode => true;

  Color getTextPrimary([bool isDark = true]) => isDark ? textPrimary : const Color(0xFF121212);
  Color getBackground([bool isDark = true]) => isDark ? background : const Color(0xFFF5F5F5);
  Color getCardBackground([bool isDark = true]) => isDark ? surfaceElevated : const Color(0xFFFFFFFF);

  /// Gradient used behind headers / hero areas for a bit of depth.
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF062226), Color(0xFF000000)],
    stops: [0.0, 0.55],
  );
}
