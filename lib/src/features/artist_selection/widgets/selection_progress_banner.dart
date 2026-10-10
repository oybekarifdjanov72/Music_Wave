import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// "2 of 3 selected" banner shown above the artist grid so people always
/// know how much further they need to go before "Continue" lights up.
class SelectionProgressBanner extends StatelessWidget {
  const SelectionProgressBanner({super.key, required this.selectedCount});

  final int selectedCount;

  @override
  Widget build(BuildContext context) {
    final target = AppConstants.minSingersToSelect;
    final done = selectedCount >= target;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: done ? AppColors.cyanAccent.withValues(alpha: 0.6) : AppColors.surfaceBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.info_outline,
            color: done ? AppColors.cyanAccent : AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              done
                  ? '$selectedCount artists selected — you\'re all set!'
                  : 'Pick at least $target artists ($selectedCount/$target)',
              style: AppTextStyles.bodyMuted.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
