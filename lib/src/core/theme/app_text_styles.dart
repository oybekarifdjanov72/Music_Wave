import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Text styles for the app, all built on Work Sans to match the rest of
/// the brand's typography.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get displayTitle => GoogleFonts.workSans(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get screenTitle => GoogleFonts.workSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get sectionTitle => GoogleFonts.workSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get body => GoogleFonts.workSans(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMuted => GoogleFonts.workSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  static TextStyle get caption => GoogleFonts.workSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
      );

  static TextStyle get buttonLabel => GoogleFonts.workSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.background,
      );

  static TextStyle get link => GoogleFonts.workSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.cyanAccent,
      );
}
