import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/models/playlist_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// A single row in the Library list — cover (or a heart for Liked Songs),
/// name, and track count.
class PlaylistCard extends StatelessWidget {
  const PlaylistCard({super.key, required this.playlist, required this.onTap});

  final Playlist playlist;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 52,
          height: 52,
          child: playlist.isLikedSongs
              ? Container(
                  color: AppColors.cyanAccent,
                  child: const Icon(Icons.favorite, color: Colors.black, size: 24),
                )
              : (playlist.coverUrl == null || playlist.coverUrl!.isEmpty)
                  ? Container(
                      color: AppColors.surfaceElevated,
                      child: const Icon(Icons.queue_music_rounded, color: AppColors.textMuted),
                    )
                  : CachedNetworkImage(imageUrl: playlist.coverUrl!, fit: BoxFit.cover),
        ),
      ),
      title: Text(
        playlist.name,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        '${playlist.tracks.length} ${playlist.tracks.length == 1 ? 'song' : 'songs'}',
        style: AppTextStyles.bodyMuted,
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
    );
  }
}
