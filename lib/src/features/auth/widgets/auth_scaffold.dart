import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_text_styles.dart';

/// Shared chrome for the Sign In / Sign Up screens: gradient background,
/// glowing logo mark, headline + subtitle, then whatever form the caller
/// supplies.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.cyanAccent, width: 1.6),
                    boxShadow: AppShadows.neonGlow(blur: 20, opacity: 0.4),
                  ),
                  child: const Icon(Icons.graphic_eq_rounded, color: AppColors.cyanAccent),
                ),
                const SizedBox(height: 28),
                Text(title, style: AppTextStyles.displayTitle),
                const SizedBox(height: 8),
                Text(subtitle, style: AppTextStyles.bodyMuted),
                const SizedBox(height: 32),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
