import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// The single [ThemeData] used by the whole app (Neon Wave is dark-only
/// by design, matching the reference brand: black canvas, white text,
/// cyan accent).
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.cyanAccent,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.cyanAccent,
        secondary: AppColors.cyanAccent,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.screenTitle,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.cyanAccent,
        selectionColor: Color(0x5500E5FF),
        selectionHandleColor: AppColors.cyanAccent,
      ),
      splashColor: AppColors.cyanAccent.withValues(alpha: 0.08),
      highlightColor: Colors.transparent,
      dividerColor: AppColors.surfaceBorder,
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.cyanAccent,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: AppTextStyles.body,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}
