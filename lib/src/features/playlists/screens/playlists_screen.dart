import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/widgets/state_views.dart';
import '../cubit/playlists_cubit.dart';
import '../cubit/playlists_state.dart';
import '../widgets/create_playlist_sheet.dart';
import '../widgets/playlist_card.dart';

/// The "Library" tab — every playlist the person has, "Liked Songs" always
/// pinned first.
class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistsCubit, PlaylistsState>(
      builder: (context, state) {
        final cubit = context.read<PlaylistsCubit>();
        return Scaffold(
          appBar: AppBar(
            title: const Text('Your Library'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  final name = await CreatePlaylistSheet.show(context);
                  if (name != null && name.trim().isNotEmpty) {
                    await cubit.createPlaylist(name);
                  }
                },
              ),
            ],
          ),
          body: state.playlists.isEmpty
              ? const EmptyView(
                  message: 'Your library is empty',
                  subtitle: 'Create a playlist to get started.',
                  icon: Icons.library_music_outlined,
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: state.playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = state.playlists[index];
                    return PlaylistCard(
                      playlist: playlist,
                      onTap: () => Navigator.of(context)
                          .pushNamed(RouteNames.playlistDetail, arguments: playlist),
                    );
                  },
                ),
        );
      },
    );
  }
}
