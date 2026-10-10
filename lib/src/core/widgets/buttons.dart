import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text_styles.dart';

/// The app's primary call-to-action: solid cyan pill with a neon glow.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final active = enabled && !isLoading && onPressed != null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: active ? AppColors.cyanAccent : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(26),
        boxShadow: active ? AppShadows.neonGlow(blur: 16, opacity: 0.45) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: active ? onPressed : null,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.black),
                  )
                : Text(
                    label,
                    style: active
                        ? AppTextStyles.buttonLabel
                        : AppTextStyles.buttonLabel.copyWith(color: AppColors.textMuted),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Secondary, outlined action — used for "Sign up" / "Sign in" toggles etc.
class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.surfaceBorder, width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        ),
        child: Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

/// Small circular icon button with a subtle neon ring — play/pause, like,
/// shuffle, etc.
class NeonIconButton extends StatelessWidget {
  const NeonIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 44,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.cyanAccent : AppColors.surfaceElevated,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            color: filled ? AppColors.background : AppColors.textPrimary,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}
