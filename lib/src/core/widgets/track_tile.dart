import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/track_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A single-row track item — used in Search results, playlist contents,
/// and "Recently Played". Fully presentational: the parent decides what
/// happens on tap / like / more.
class TrackTile extends StatelessWidget {
  const TrackTile({
    super.key,
    required this.track,
    required this.onTap,
    this.isLiked = false,
    this.onToggleLike,
    this.onMore,
    this.isActive = false,
  });

  final Track track;
  final VoidCallback onTap;
  final bool isLiked;
  final VoidCallback? onToggleLike;
  final VoidCallback? onMore;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            _Artwork(url: track.artworkUrl, size: 52),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      color: isActive ? AppColors.cyanAccent : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    track.artistName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMuted,
                  ),
                ],
              ),
            ),
            if (onToggleLike != null)
              IconButton(
                onPressed: onToggleLike,
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? AppColors.cyanAccent : AppColors.textMuted,
                  size: 22,
                ),
              ),
            if (onMore != null)
              IconButton(
                onPressed: onMore,
                icon: const Icon(Icons.more_vert, color: AppColors.textMuted, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}

/// Vertical card used in Home's horizontal carousels ("Popular Right Now",
/// "Made For You"...).
class TrackCard extends StatelessWidget {
  const TrackCard({super.key, required this.track, required this.onTap, this.width = 140});

  final Track track;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Artwork(url: track.artworkUrl, size: width, radius: 12),
            const SizedBox(height: 8),
            Text(
              track.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              track.artistName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}

class _Artwork extends StatelessWidget {
  const _Artwork({required this.url, required this.size, this.radius = 10});

  final String url;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: url.isEmpty
            ? _placeholder()
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, __) => _placeholder(),
                errorWidget: (_, __, ___) => _placeholder(),
              ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.surfaceElevated,
      child: const Icon(Icons.music_note, color: AppColors.textMuted),
    );
  }
}
