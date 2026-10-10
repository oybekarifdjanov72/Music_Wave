import 'package:equatable/equatable.dart';

import '../../../core/models/playlist_model.dart';

class PlaylistsState extends Equatable {
  const PlaylistsState({this.playlists = const [], this.isProcessing = false});

  final List<Playlist> playlists;
  final bool isProcessing;

  Playlist? findById(String id) {
    for (final p in playlists) {
      if (p.id == id) return p;
    }
    return null;
  }

  PlaylistsState copyWith({List<Playlist>? playlists, bool? isProcessing}) {
    return PlaylistsState(
      playlists: playlists ?? this.playlists,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  @override
  List<Object?> get props => [playlists, isProcessing];
}
