import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user_model.dart';
import '../models/artist_model.dart';
import '../models/playlist_model.dart';
import '../models/track_model.dart';

/// Every bit of state that needs to survive an app restart lives behind
/// this one class — auth accounts + session, the singers picked at
/// onboarding, playlists (including special "Liked Songs" and "Downloaded Songs")
/// and recent searches.
class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  static Future<LocalStorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  // ---------------------------------------------------------------------
  // Auth (local, backend-less)
  // ---------------------------------------------------------------------
  static const _kAccounts = 'auth_accounts_v1';
  static const _kSessionEmail = 'auth_session_email_v1';

  Map<String, dynamic> _readAccounts() {
    final raw = _prefs.getString(_kAccounts);
    if (raw == null || raw.isEmpty) return {};
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> _writeAccounts(Map<String, dynamic> accounts) {
    return _prefs.setString(_kAccounts, jsonEncode(accounts));
  }

  Map<String, dynamic>? findAccount(String email) {
    final accounts = _readAccounts();
    final key = email.trim().toLowerCase();
    return accounts[key] == null ? null : Map<String, dynamic>.from(accounts[key] as Map);
  }

  Future<void> saveAccount({
    required String email,
    required String passwordHash,
    required String fullName,
  }) async {
    final accounts = _readAccounts();
    final key = email.trim().toLowerCase();
    accounts[key] = {
      'email': key,
      'passwordHash': passwordHash,
      'fullName': fullName,
      'joinedAt': DateTime.now().toIso8601String(),
    };
    await _writeAccounts(accounts);
  }

  Future<void> setSession(String? email) async {
    if (email == null) {
      await _prefs.remove(_kSessionEmail);
    } else {
      await _prefs.setString(_kSessionEmail, email.trim().toLowerCase());
    }
  }

  AppUser? getCurrentUser() {
    final email = _prefs.getString(_kSessionEmail);
    if (email == null) return null;
    final account = findAccount(email);
    if (account == null) return null;
    return AppUser(
      email: account['email'] as String,
      fullName: account['fullName'] as String,
      joinedAt: DateTime.tryParse(account['joinedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  // ---------------------------------------------------------------------
  // Profile Image
  // ---------------------------------------------------------------------
  static const _kProfileImagePath = 'profile_image_path_v1';

  String? getProfileImagePath() {
    return _prefs.getString(_kProfileImagePath);
  }

  Future<void> saveProfileImagePath(String path) async {
    await _prefs.setString(_kProfileImagePath, path);
  }

  Future<String> persistProfileImage(String sourcePath) async {
    await saveProfileImagePath(sourcePath);
    return sourcePath;
  }

  // ---------------------------------------------------------------------
  // Onboarding: chosen singers
  // ---------------------------------------------------------------------
  static const _kChosenArtists = 'chosen_artists_v1';
  static const _kHasSelectedSingers = 'has_selected_singers_v1';

  bool get hasSelectedSingers => _prefs.getBool(_kHasSelectedSingers) ?? false;

  List<Artist> getChosenArtists() {
    final raw = _prefs.getString(_kChosenArtists);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Artist.fromCacheJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveChosenArtists(List<Artist> artists) async {
    await _prefs.setString(
      _kChosenArtists,
      jsonEncode(artists.map((a) => a.toCacheJson()).toList()),
    );
    await _prefs.setBool(_kHasSelectedSingers, true);
  }

  // ---------------------------------------------------------------------
  // Playlists (Liked Songs and Downloaded Songs are system playlists)
  // ---------------------------------------------------------------------
  static const _kPlaylists = 'playlists_v1';
  static const likedSongsId = 'liked_songs';
  static const downloadedSongsId = 'downloaded_songs';

  List<Playlist> getPlaylists() {
    final raw = _prefs.getString(_kPlaylists);
    List<Playlist> playlists = [];
    if (raw != null && raw.isNotEmpty) {
      final list = jsonDecode(raw) as List<dynamic>;
      playlists = list.map((e) => Playlist.fromJson(e as Map<String, dynamic>)).toList();
    }
    if (!playlists.any((p) => p.id == likedSongsId)) {
      playlists.insert(
        0,
        Playlist(
          id: likedSongsId,
          name: 'Liked Songs',
          tracks: const [],
          createdAt: DateTime.now(),
          isLikedSongs: true,
        ),
      );
    }
    if (!playlists.any((p) => p.id == downloadedSongsId)) {
      playlists.insert(
        1,
        Playlist(
          id: downloadedSongsId,
          name: 'Downloaded Songs',
          tracks: const [],
          createdAt: DateTime.now(),
          isDownloadedSongs: true,
        ),
      );
    }
    return playlists;
  }

  Future<void> savePlaylists(List<Playlist> playlists) async {
    await _prefs.setString(_kPlaylists, jsonEncode(playlists.map((p) => p.toJson()).toList()));
  }

  // ---------------------------------------------------------------------
  // Recent searches
  // ---------------------------------------------------------------------
  static const _kRecentSearches = 'recent_searches_v1';

  List<String> getRecentSearches() {
    return _prefs.getStringList(_kRecentSearches) ?? [];
  }

  Future<void> addRecentSearch(String query, {int maxEntries = 10}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final current = getRecentSearches();
    current.removeWhere((q) => q.toLowerCase() == trimmed.toLowerCase());
    current.insert(0, trimmed);
    final capped = current.take(maxEntries).toList();
    await _prefs.setStringList(_kRecentSearches, capped);
  }

  Future<void> clearRecentSearches() => _prefs.remove(_kRecentSearches);

  // ---------------------------------------------------------------------
  // Recently played
  // ---------------------------------------------------------------------
  static const _kRecentlyPlayed = 'recently_played_v1';

  List<Track> getRecentlyPlayed() {
    final raw = _prefs.getString(_kRecentlyPlayed);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Track.fromCacheJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> addRecentlyPlayed(Track track, {int maxEntries = 15}) async {
    final current = getRecentlyPlayed();
    current.removeWhere((t) => t.id == track.id);
    current.insert(0, track);
    final capped = current.take(maxEntries).toList();
    await _prefs.setString(_kRecentlyPlayed, jsonEncode(capped.map((t) => t.toCacheJson()).toList()));
  }

  // ---------------------------------------------------------------------
  // Full sign-out
  // ---------------------------------------------------------------------
  Future<void> clearSessionData() async {
    await _prefs.remove(_kSessionEmail);
  }
}
