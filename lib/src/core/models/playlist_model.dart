import 'package:equatable/equatable.dart';

import 'track_model.dart';

/// A user-created (fully local) playlist. `Liked Songs` and `Downloaded Songs`
/// are playlists created automatically and flagged [isLikedSongs] / [isDownloadedSongs]
/// so they can't be renamed or deleted.
class Playlist extends Equatable {
  const Playlist({
    required this.id,
    required this.name,
    required this.tracks,
    required this.createdAt,
    this.isLikedSongs = false,
    this.isDownloadedSongs = false,
  });

  final String id;
  final String name;
  final List<Track> tracks;
  final DateTime createdAt;
  final bool isLikedSongs;
  final bool isDownloadedSongs;

  String? get coverUrl => tracks.isEmpty ? null : tracks.first.artworkUrl;

  bool containsTrack(String trackId) => tracks.any((t) => t.id == trackId);

  Playlist copyWith({String? name, List<Track>? tracks}) {
    return Playlist(
      id: id,
      name: name ?? this.name,
      tracks: tracks ?? this.tracks,
      createdAt: createdAt,
      isLikedSongs: isLikedSongs,
      isDownloadedSongs: isDownloadedSongs,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tracks': tracks.map((t) => t.toCacheJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'isLikedSongs': isLikedSongs,
        'isDownloadedSongs': isDownloadedSongs,
      };

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      tracks: (json['tracks'] as List<dynamic>? ?? [])
          .map((e) => Track.fromCacheJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      isLikedSongs: json['isLikedSongs'] as bool? ?? false,
      isDownloadedSongs: json['isDownloadedSongs'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, name, tracks, isLikedSongs, isDownloadedSongs];
}
