import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Thin wrapper around `toastification` so every screen shows errors,
/// successes and info messages the exact same, on-brand way instead of
/// each cubit/screen rolling its own SnackBar.
class ToastUtil {
  ToastUtil._();

  static void success(BuildContext context, String message) {
    _show(context, message, icon: Icons.check_circle, accent: AppColors.success);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, icon: Icons.error_outline, accent: AppColors.error);
  }

  static void info(BuildContext context, String message) {
    _show(context, message, icon: Icons.info_outline, accent: AppColors.cyanAccent);
  }

  static void _show(
    BuildContext context,
    String message, {
    required IconData icon,
    required Color accent,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topCenter,
      icon: Icon(icon, color: accent),
      primaryColor: accent,
      backgroundColor: AppColors.surfaceElevated,
      foregroundColor: AppColors.textPrimary,
      title: Text(message, style: AppTextStyles.body, maxLines: 3),
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: accent.withValues(alpha: 0.4)),
      boxShadow: [
        BoxShadow(color: accent.withValues(alpha: 0.25), blurRadius: 16, spreadRadius: 1),
      ],
      showProgressBar: false,
    );
  }
}
