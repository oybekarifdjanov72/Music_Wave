import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/models/playlist_model.dart';
import '../../../core/models/track_model.dart';
import '../../../core/repositories/playlist_repository.dart';
import 'playlists_state.dart';

/// Everything playlist-related — including the special "Liked Songs"
/// playlist that every heart icon in the app toggles — lives here so
/// there's exactly one in-memory source of truth, shared across Home,
/// Search and the Library tab via a single provided instance.
class PlaylistsCubit extends Cubit<PlaylistsState> {
  PlaylistsCubit({PlaylistRepository? repository})
      : _repository = repository ?? getIt<PlaylistRepository>(),
        super(const PlaylistsState()) {
    refresh();
  }

  final PlaylistRepository _repository;

  void refresh() => emit(state.copyWith(playlists: _repository.getPlaylists()));

  bool isLiked(String trackId) => _repository.isLiked(trackId);

  Future<void> toggleLiked(Track track) async {
    await _repository.toggleLiked(track);
    refresh();
  }

  Future<Playlist> createPlaylist(String name) async {
    final playlist = await _repository.createPlaylist(name);
    refresh();
    return playlist;
  }

  Future<void> deletePlaylist(String playlistId) async {
    await _repository.deletePlaylist(playlistId);
    refresh();
  }

  Future<void> renamePlaylist(String playlistId, String newName) async {
    await _repository.renamePlaylist(playlistId, newName);
    refresh();
  }

  Future<void> addTrack(String playlistId, Track track) async {
    await _repository.addTrack(playlistId, track);
    refresh();
  }

  Future<void> removeTrack(String playlistId, String trackId) async {
    await _repository.removeTrack(playlistId, trackId);
    refresh();
  }
}
