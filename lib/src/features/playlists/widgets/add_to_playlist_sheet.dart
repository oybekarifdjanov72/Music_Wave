import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/track_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/toast_util.dart';
import '../cubit/playlists_cubit.dart';
import '../cubit/playlists_state.dart';
import 'create_playlist_sheet.dart';

/// Bottom sheet listing every playlist so a track can be filed into one
/// (or several) — plus a shortcut to create a brand new playlist on the
/// spot. [PlaylistsCubit] is provided at the app root, so this works from
/// anywhere a [Track]'s "more" button lives.
class AddToPlaylistSheet extends StatelessWidget {
  const AddToPlaylistSheet({super.key, required this.track});

  final Track track;

  static void show(BuildContext context, Track track) {
    final cubit = context.read<PlaylistsCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: AddToPlaylistSheet(track: track),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistsCubit, PlaylistsState>(
      builder: (context, _) {
        final cubit = context.read<PlaylistsCubit>();
        final playlists = cubit.state.playlists.where((p) => !p.isLikedSongs).toList();

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Add to playlist', style: AppTextStyles.screenTitle),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.add_circle_outline, color: AppColors.cyanAccent),
                  title: Text('New playlist', style: AppTextStyles.body),
                  onTap: () async {
                    final name = await CreatePlaylistSheet.show(context);
                    if (name == null || name.trim().isEmpty) return;
                    final playlist = await cubit.createPlaylist(name);
                    await cubit.addTrack(playlist.id, track);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ToastUtil.success(context, 'Added to "$name"');
                    }
                  },
                ),
                const Divider(color: AppColors.surfaceBorder, height: 1),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = playlists[index];
                      final alreadyIn = playlist.containsTrack(track.id);
                      return ListTile(
                        leading: Icon(
                          alreadyIn ? Icons.check_circle : Icons.queue_music_rounded,
                          color: alreadyIn ? AppColors.cyanAccent : AppColors.textMuted,
                        ),
                        title: Text(playlist.name, style: AppTextStyles.body),
                        subtitle: Text('${playlist.tracks.length} songs', style: AppTextStyles.caption),
                        onTap: () async {
                          if (alreadyIn) {
                            await cubit.removeTrack(playlist.id, track.id);
                          } else {
                            await cubit.addTrack(playlist.id, track);
                          }
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}
