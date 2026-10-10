import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_text_styles.dart';
import '../cubit/player_cubit.dart';
import '../cubit/player_state.dart';

/// Slim, always-visible now-playing strip pinned just above the bottom
/// nav bar — tapping it opens the full [NowPlayingScreen]. Hides itself
/// entirely when nothing is queued up.
class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        if (!state.hasTrack) return const SizedBox.shrink();
        final track = state.currentTrack!;
        final progress = state.duration.inMilliseconds == 0
            ? 0.0
            : state.position.inMilliseconds / state.duration.inMilliseconds;

        return GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(RouteNames.nowPlaying),
          child: Container(
            height: 64,
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppShadows.neonGlow(blur: 12, opacity: 0.18),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 42,
                            height: 42,
                            child: track.artworkUrl.isEmpty
                                ? Container(
                                    color: AppColors.surface,
                                    child: const Icon(Icons.music_note, color: AppColors.textMuted, size: 18),
                                  )
                                : CachedNetworkImage(imageUrl: track.artworkUrl, fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                track.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                track.artistName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => context.read<PlayerCubit>().previous(),
                          icon: const Icon(Icons.skip_previous_rounded, color: AppColors.textPrimary),
                          visualDensity: VisualDensity.compact,
                        ),
                        IconButton(
                          onPressed: () => context.read<PlayerCubit>().togglePlayPause(),
                          icon: Icon(
                            state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: AppColors.cyanAccent,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 2,
                  backgroundColor: AppColors.surface,
                  valueColor: const AlwaysStoppedAnimation(AppColors.cyanAccent),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
