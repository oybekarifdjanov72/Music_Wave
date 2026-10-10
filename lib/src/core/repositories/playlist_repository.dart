import '../models/playlist_model.dart';
import '../models/track_model.dart';
import '../storage/local_storage_service.dart';
import '../utils/id_generator.dart';

/// CRUD over the fully-local playlist system, including special
/// "Liked Songs" and "Downloaded Songs" playlists.
abstract class PlaylistRepository {
  List<Playlist> getPlaylists();
  Future<Playlist> createPlaylist(String name);
  Future<void> deletePlaylist(String playlistId);
  Future<void> renamePlaylist(String playlistId, String newName);
  Future<void> addTrack(String playlistId, Track track);
  Future<void> removeTrack(String playlistId, String trackId);
  Future<bool> toggleLiked(Track track);
  bool isLiked(String trackId);
  Future<void> addDownloadedTrack(Track track);
}

class LocalPlaylistRepository implements PlaylistRepository {
  LocalPlaylistRepository({required LocalStorageService storage}) : _storage = storage;

  final LocalStorageService _storage;

  @override
  List<Playlist> getPlaylists() => _storage.getPlaylists();

  @override
  Future<Playlist> createPlaylist(String name) async {
    final playlists = _storage.getPlaylists();
    final playlist = Playlist(
      id: IdGenerator.next('playlist'),
      name: name.trim().isEmpty ? 'New Playlist' : name.trim(),
      tracks: const [],
      createdAt: DateTime.now(),
    );
    playlists.add(playlist);
    await _storage.savePlaylists(playlists);
    return playlist;
  }

  @override
  Future<void> deletePlaylist(String playlistId) async {
    final playlists = _storage.getPlaylists()
      ..removeWhere((p) => p.id == playlistId && !p.isLikedSongs && !p.isDownloadedSongs);
    await _storage.savePlaylists(playlists);
  }

  @override
  Future<void> renamePlaylist(String playlistId, String newName) async {
    final playlists = _storage.getPlaylists();
    final index = playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1 || playlists[index].isLikedSongs || playlists[index].isDownloadedSongs) return;
    playlists[index] = playlists[index].copyWith(name: newName.trim());
    await _storage.savePlaylists(playlists);
  }

  @override
  Future<void> addTrack(String playlistId, Track track) async {
    final playlists = _storage.getPlaylists();
    final index = playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;
    if (playlists[index].containsTrack(track.id)) return;
    final updatedTracks = [...playlists[index].tracks, track];
    playlists[index] = playlists[index].copyWith(tracks: updatedTracks);
    await _storage.savePlaylists(playlists);
  }

  @override
  Future<void> removeTrack(String playlistId, String trackId) async {
    final playlists = _storage.getPlaylists();
    final index = playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;
    final updatedTracks = playlists[index].tracks.where((t) => t.id != trackId).toList();
    playlists[index] = playlists[index].copyWith(tracks: updatedTracks);
    await _storage.savePlaylists(playlists);
  }

  @override
  Future<bool> toggleLiked(Track track) async {
    final playlists = _storage.getPlaylists();
    final index = playlists.indexWhere((p) => p.isLikedSongs);
    final liked = playlists[index];
    final alreadyLiked = liked.containsTrack(track.id);

    final updatedTracks = alreadyLiked
        ? liked.tracks.where((t) => t.id != track.id).toList()
        : [...liked.tracks, track];

    playlists[index] = liked.copyWith(tracks: updatedTracks);
    await _storage.savePlaylists(playlists);
    return !alreadyLiked;
  }

  @override
  bool isLiked(String trackId) {
    final liked = _storage.getPlaylists().firstWhere((p) => p.isLikedSongs);
    return liked.containsTrack(trackId);
  }

  @override
  Future<void> addDownloadedTrack(Track track) async {
    final playlists = _storage.getPlaylists();
    final index = playlists.indexWhere((p) => p.isDownloadedSongs);
    if (index == -1) return;
    final downloaded = playlists[index];
    if (downloaded.containsTrack(track.id)) return;
    final updatedTracks = [...downloaded.tracks, track];
    playlists[index] = downloaded.copyWith(tracks: updatedTracks);
    await _storage.savePlaylists(playlists);
  }
}
