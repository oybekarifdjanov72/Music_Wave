import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/toast_util.dart';
import '../../playlists/cubit/playlists_cubit.dart';
import '../cubit/player_cubit.dart';
import '../cubit/player_state.dart';
import '../widgets/seek_bar.dart';

/// The full-screen "Now Playing" sheet, pushed on top of whatever the
/// person was doing. Purely a view over [PlayerCubit] and [PlaylistsCubit].
class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  String _effectiveArtwork(String url) {
    if (url.isEmpty) return '';
    if (kIsWeb && url.contains('dzcdn.net') && !url.startsWith('https://corsproxy.io/?')) {
      return 'https://corsproxy.io/?$url';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        final track = state.currentTrack;
        final playlistsCubit = context.watch<PlaylistsCubit>();
        final isLiked = track != null && playlistsCubit.isLiked(track.id);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: track == null
                ? _EmptyPlayerState(onClose: () => Navigator.of(context).pop())
                : Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 30),
                            ),
                            Text('Now Playing', style: AppTextStyles.bodyMuted),
                            const SizedBox(width: 48),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: AppShadows.neonGlow(blur: 40, opacity: 0.35, spread: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: track.artworkUrl.isEmpty
                                ? Container(
                                    color: AppColors.surface,
                                    child: const Icon(Icons.music_note, size: 64, color: AppColors.textMuted),
                                  )
                                : CachedNetworkImage(
                                    imageUrl: _effectiveArtwork(track.artworkUrl),
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(color: AppColors.surface),
                                    errorWidget: (_, __, ___) => Container(
                                      color: AppColors.surface,
                                      child: const Icon(Icons.music_note, size: 64, color: AppColors.textMuted),
                                    ),
                                  ),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    track.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.screenTitle,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    track.artistName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodyMuted,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                await playlistsCubit.toggleLiked(track);
                                final nowLiked = playlistsCubit.isLiked(track.id);
                                if (context.mounted) {
                                  ToastUtil.info(
                                    context,
                                    nowLiked ? 'Added to Liked Songs' : 'Removed from Liked Songs',
                                  );
                                }
                              },
                              icon: Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                color: isLiked ? AppColors.cyanAccent : AppColors.textMuted,
                                size: 26,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SeekBar(
                          position: state.position,
                          duration: state.duration,
                          onSeek: (position) => context.read<PlayerCubit>().seek(position),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              iconSize: 36,
                              onPressed:
                                  state.hasPrevious ? () => context.read<PlayerCubit>().previous() : null,
                              icon: const Icon(Icons.skip_previous_rounded),
                              color: state.hasPrevious ? AppColors.textPrimary : AppColors.textMuted,
                            ),
                            _PlayPauseButton(
                              isPlaying: state.isPlaying,
                              isBuffering: state.isBuffering,
                              onTap: () => context.read<PlayerCubit>().togglePlayPause(),
                            ),
                            IconButton(
                              iconSize: 36,
                              onPressed: state.hasNext ? () => context.read<PlayerCubit>().next() : null,
                              icon: const Icon(Icons.skip_next_rounded),
                              color: state.hasNext ? AppColors.textPrimary : AppColors.textMuted,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.isFullTrack ? 'Playing full track' : 'Playing a 30-second preview',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({required this.isPlaying, required this.isBuffering, required this.onTap});

  final bool isPlaying;
  final bool isBuffering;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.cyanAccent,
        boxShadow: AppShadows.neonGlow(blur: 20, opacity: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: isBuffering ? null : onTap,
          child: Center(
            child: isBuffering
                ? const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.black),
                  )
                : Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: AppColors.background,
                    size: 36,
                  ),
          ),
        ),
      ),
    );
  }
}

class _EmptyPlayerState extends StatelessWidget {
  const _EmptyPlayerState({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.music_off_rounded, color: AppColors.textMuted, size: 48),
        const SizedBox(height: 16),
        Text('Nothing is playing', style: AppTextStyles.body),
        const SizedBox(height: 20),
        TextButton(onPressed: onClose, child: const Text('Close')),
      ],
    );
  }
}
