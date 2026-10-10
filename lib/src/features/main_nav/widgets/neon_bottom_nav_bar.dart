import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class _NavItemData {
  const _NavItemData({required this.icon, required this.activeIcon, required this.label});
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

const List<_NavItemData> _navItems = [
  _NavItemData(
    icon: CupertinoIcons.house,
    activeIcon: CupertinoIcons.house_fill,
    label: 'Home',
  ),
  _NavItemData(
    icon: CupertinoIcons.search,
    activeIcon: CupertinoIcons.search,
    label: 'Search',
  ),
  _NavItemData(
    icon: CupertinoIcons.music_albums,
    activeIcon: CupertinoIcons.music_albums_fill,
    label: 'Library',
  ),
  _NavItemData(
    icon: CupertinoIcons.person,
    activeIcon: CupertinoIcons.person_fill,
    label: 'Profile',
  ),
];

/// Premium glassmorphic floating bottom navigation bar with animated glowing cyan aura
/// and smooth spring scale transitions.
class NeonBottomNavBar extends StatelessWidget {
  const NeonBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const double barHeight = 66.0;
    const double iconSize = 22.0;
    const double bubbleSize = 46.0;
    const Color accent = AppColors.cyanAccent;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            height: barHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.03),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 32,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / _navItems.length;
                final left = (currentIndex * itemWidth) + (itemWidth - bubbleSize) / 2;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutQuart,
                      left: left,
                      top: (barHeight - bubbleSize) / 2,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutQuart,
                        width: bubbleSize,
                        height: bubbleSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              accent.withValues(alpha: 0.4),
                              accent.withValues(alpha: 0.1),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(_navItems.length, (index) {
                        final item = _navItems[index];
                        final selected = currentIndex == index;
                        return Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => onTap(index),
                              splashColor: accent.withValues(alpha: 0.08),
                              highlightColor: Colors.transparent,
                              borderRadius: BorderRadius.circular(28),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedScale(
                                      scale: selected ? 1.18 : 1.0,
                                      duration: const Duration(milliseconds: 320),
                                      curve: Curves.easeOutBack,
                                      child: AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 280),
                                        transitionBuilder: (child, animation) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: ScaleTransition(
                                              scale: animation,
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: Icon(
                                          selected ? item.activeIcon : item.icon,
                                          key: ValueKey('${item.label}-$selected'),
                                          size: iconSize,
                                          color: selected
                                              ? accent
                                              : AppColors.textPrimary.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      item.label,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                        color: selected
                                            ? accent
                                            : AppColors.textPrimary.withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
