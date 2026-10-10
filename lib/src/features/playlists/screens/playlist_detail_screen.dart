import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/playlist_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/toast_util.dart';
import '../../../core/widgets/track_tile.dart';
import '../../player/cubit/player_cubit.dart';
import '../cubit/playlists_cubit.dart';
import '../cubit/playlists_state.dart';
import '../widgets/add_songs_to_playlist_sheet.dart';
import '../widgets/create_playlist_sheet.dart';

class PlaylistDetailScreen extends StatelessWidget {
  const PlaylistDetailScreen({super.key, required this.playlist});

  /// A snapshot from the moment the user tapped into this playlist — kept
  /// only as a fallback; the live copy from [PlaylistsCubit] is preferred
  /// so edits made elsewhere (liking a song, removing a track) show up
  /// immediately.
  final Playlist playlist;

  void _openAddSongs(BuildContext context, Playlist live) {
    AddSongsToPlaylistSheet.show(
      context,
      playlistId: live.id,
      playlistName: live.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistsCubit, PlaylistsState>(
      builder: (context, state) {
        final live = state.findById(playlist.id) ?? playlist;
        final cubit = context.read<PlaylistsCubit>();

        return Scaffold(
          appBar: AppBar(
            title: Text(live.name),
            actions: [
              if (!live.isLikedSongs)
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'rename') {
                      final newName = await CreatePlaylistSheet.show(context);
                      if (newName != null && newName.trim().isNotEmpty) {
                        await cubit.renamePlaylist(live.id, newName);
                      }
                    } else if (value == 'delete') {
                      await cubit.deletePlaylist(live.id);
                      if (context.mounted) Navigator.of(context).pop();
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'rename', child: Text('Rename')),
                    PopupMenuItem(value: 'delete', child: Text('Delete playlist')),
                  ],
                ),
            ],
          ),
          body: live.tracks.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => _openAddSongs(context, live),
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surfaceElevated,
                              border: Border.all(color: AppColors.cyanAccent, width: 1.4),
                            ),
                            child: const Icon(Icons.add_rounded, color: AppColors.cyanAccent, size: 36),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text('No songs yet', style: AppTextStyles.sectionTitle),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to search and add songs to this playlist.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMuted,
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${live.tracks.length} ${live.tracks.length == 1 ? 'song' : 'songs'}',
                              style: AppTextStyles.bodyMuted,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _openAddSongs(context, live),
                            icon: const Icon(Icons.add_rounded, color: AppColors.cyanAccent),
                            label: Text('Add', style: AppTextStyles.link),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: live.tracks.length,
                        itemBuilder: (context, index) {
                          final track = live.tracks[index];
                          return TrackTile(
                            track: track,
                            onTap: () => context.read<PlayerCubit>().playQueue(live.tracks, index),
                            onMore: () async {
                              await cubit.removeTrack(live.id, track.id);
                              if (context.mounted) {
                                ToastUtil.info(context, 'Removed from ${live.name}');
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
