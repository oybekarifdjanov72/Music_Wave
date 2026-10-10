import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Reusable neon-glow shadows/decorations shared by every screen so the
/// "glowing cyan" language stays consistent app-wide.
class AppShadows {
  AppShadows._();

  static List<BoxShadow> neonGlow({
    Color color = AppColors.cyanAccent,
    double blur = 18,
    double spread = 0.5,
    double opacity = 0.55,
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        blurRadius: blur,
        spreadRadius: spread,
      ),
    ];
  }

  static List<Shadow> neonTextGlow({
    Color color = AppColors.cyanAccent,
    double blur = 10,
  }) {
    return [Shadow(color: color.withValues(alpha: 0.8), blurRadius: blur)];
  }

  static BoxDecoration neonCard({
    Color? borderColor,
    double radius = 18,
    bool glow = false,
  }) {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? AppColors.surfaceBorder,
        width: 1,
      ),
      boxShadow: glow ? neonGlow(opacity: 0.35, blur: 14) : null,
    );
  }
}
