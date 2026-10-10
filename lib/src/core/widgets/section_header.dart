import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

/// "Popular Right Now" / "Made For You" style header used above every
/// horizontal section on the Home screen.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.sectionTitle),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Text('See all', style: AppTextStyles.link),
            ),
        ],
      ),
    );
  }
}
