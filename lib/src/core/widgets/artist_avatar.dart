import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/artist_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text_styles.dart';

/// Circular artist portrait with an optional neon selection ring — used by
/// onboarding's singer picker, the Home "Your Artists" row, and Search.
class ArtistAvatar extends StatelessWidget {
  const ArtistAvatar({
    super.key,
    required this.artist,
    this.size = 100,
    this.selected = false,
    this.onTap,
    this.showName = true,
  });

  final Artist artist;
  final double size;
  final bool selected;
  final VoidCallback? onTap;
  final bool showName;

  String _getEffectiveImageUrl(String url) {
    if (url.isEmpty) return '';
    if (kIsWeb && url.contains('dzcdn.net') && !url.startsWith('https://corsproxy.io/?')) {
      return 'https://corsproxy.io/?$url';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveUrl = _getEffectiveImageUrl(artist.pictureUrl);
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? AppColors.cyanAccent : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: selected ? AppShadows.neonGlow(blur: 16, opacity: 0.6) : null,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: ClipOval(
                    child: effectiveUrl.isEmpty
                        ? _placeholder()
                        : CachedNetworkImage(
                            imageUrl: effectiveUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _placeholder(),
                            errorWidget: (_, __, ___) => _placeholder(),
                          ),
                  ),
                ),
                if (selected)
                  Positioned(
                    right: 0,
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle, color: AppColors.cyanAccent, size: 22),
                    ),
                  ),
              ],
            ),
            if (showName) ...[
              const SizedBox(height: 10),
              Text(
                artist.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  fontSize: 14,
                  color: selected ? AppColors.cyanAccent : AppColors.textPrimary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.surfaceElevated,
      child: const Icon(Icons.person, color: AppColors.textMuted, size: 36),
    );
  }
}
