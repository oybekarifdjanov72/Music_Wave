import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';

/// A rounded container with the brand's signature cyan glow. [glow]
/// toggles the shadow (e.g. only glow the selected item in a list).
class NeonGlowContainer extends StatelessWidget {
  const NeonGlowContainer({
    super.key,
    required this.child,
    this.glow = false,
    this.borderColor,
    this.radius = 18,
    this.padding,
  });

  final Widget child;
  final bool glow;
  final Color? borderColor;
  final double radius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: padding,
      decoration: AppShadows.neonCard(
        borderColor: glow ? AppColors.cyanAccent : borderColor,
        radius: radius,
        glow: glow,
      ),
      child: child,
    );
  }
}
