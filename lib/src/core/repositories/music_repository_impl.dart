import '../models/artist_model.dart';
import '../models/genre_model.dart';
import '../models/paginated_result.dart';
import '../models/track_model.dart';
import '../network/network_exceptions.dart';
import '../network/result.dart';
import '../services/deezer_service.dart';
import '../services/itunes_service.dart';
import 'music_repository.dart';

class MusicRepositoryImpl implements MusicRepository {
  MusicRepositoryImpl({
    required DeezerService deezerService,
    required ItunesService itunesService,
  })  : _deezer = deezerService,
        _itunes = itunesService;

  final DeezerService _deezer;
  final ItunesService _itunes;

  @override
  Future<Result<PaginatedResult<Track>>> searchTracks({
    required String query,
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      final deezerPage = await _deezer.searchTracks(query: query, offset: offset, limit: limit);

      // iTunes has no dependable offset paging, so it only ever
      // contributes to the very first page of a search.
      if (offset != 0) {
        return Result.success(deezerPage);
      }

      List<Track> itunesTracks = const [];
      try {
        itunesTracks = await _itunes.searchTracks(query: query, limit: limit);
      } catch (_) {
        // iTunes being down shouldn't break a search that Deezer answered
        // fine — we just quietly show Deezer-only results.
      }

      final merged = _mergeDeduped(primary: deezerPage.items, secondary: itunesTracks);
      return Result.success(deezerPage.copyWith(items: merged));
    } catch (e) {
      return Result.failure(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<List<Artist>>> searchArtists({required String query, int limit = 20}) async {
    try {
      final artists = await _deezer.searchArtists(query: query, limit: limit);
      return Result.success(artists);
    } catch (e) {
      return Result.failure(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<List<Artist>>> getPopularArtists({int limit = 30}) async {
    try {
      final artists = await _deezer.getChartArtists(limit: limit);
      if (artists.isNotEmpty) {
        return Result.success(artists);
      }
      return const Result.success(_fallbackArtists);
    } catch (_) {
      // If network/CORS fails, fall back to a curated popular artists list
      // so onboarding never blocks the user.
      return const Result.success(_fallbackArtists);
    }
  }

  @override
  Future<Result<List<Track>>> getChartTracks({int limit = 20}) async {
    try {
      final page = await _deezer.getChartTracks(limit: limit);
      return Result.success(page.items);
    } catch (e) {
      return Result.failure(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<List<Track>>> getArtistTopTracks({required String artistId, int limit = 15}) async {
    final normalizedId = _normalizeArtistId(artistId);
    try {
      final collected = <String, Track>{};

      void addAll(Iterable<Track> tracks, {bool onlyMatchingArtist = false}) {
        for (final track in tracks) {
          if (onlyMatchingArtist && track.artistId != null && track.artistId != normalizedId) {
            continue;
          }
          collected.putIfAbsent(track.id, () => track);
        }
      }

      // 1. Official top — keep only tracks whose primary artist matches.
      //    Madonna's /top currently returns a Weeknd collab as the sole
      //    entry; without this filter the sheet looks completely wrong.
      try {
        final top = await _deezer.getArtistTopTracks(artistId: normalizedId, limit: limit);
        addAll(top, onlyMatchingArtist: true);
      } catch (_) {
        // Continue with fallbacks below.
      }

      // 2. Artist radio (filtered) — fills gaps when /top is empty/wrong.
      if (collected.length < limit) {
        try {
          final radio = await _deezer.getArtistRadio(artistId: normalizedId);
          addAll(radio, onlyMatchingArtist: true);
        } catch (_) {}
      }

      // 3. Album tracks — strongest source for artists like HONNE whose
      //    /top is empty but albums are fully populated.
      if (collected.length < limit) {
        try {
          final albums = await _deezer.getArtistAlbums(artistId: normalizedId, limit: 8);
          for (final album in albums) {
            if (collected.length >= limit) break;
            final albumId = album['id']?.toString();
            if (albumId == null) continue;
            final albumTracks = await _deezer.getAlbumTracks(
              albumId: albumId,
              albumTitle: album['title'] as String?,
              albumCover: (album['cover_medium'] ?? album['cover']) as String?,
            );
            addAll(albumTracks, onlyMatchingArtist: true);
          }
        } catch (_) {}
      }

      // Last resort: unfiltered top/radio so the sheet is never blank if
      // Deezer only exposes collabs under this artist id.
      if (collected.isEmpty) {
        try {
          addAll(await _deezer.getArtistTopTracks(artistId: normalizedId, limit: limit));
        } catch (_) {}
      }
      if (collected.isEmpty) {
        try {
          addAll(await _deezer.getArtistRadio(artistId: normalizedId));
        } catch (_) {}
      }

      return Result.success(collected.values.take(limit).toList());
    } catch (e) {
      return Result.failure(mapExceptionToFailure(e));
    }
  }

  /// Accepts both live Deezer ids (`"13"`) and legacy fallback ids
  /// (`"deezer_13"`) so `/artist/{id}/top` always hits a real endpoint.
  static String _normalizeArtistId(String artistId) {
    if (artistId.startsWith('deezer_')) {
      return artistId.substring('deezer_'.length);
    }
    return artistId;
  }

  @override
  Future<Result<List<Genre>>> getGenres() async {
    try {
      final genres = await _deezer.getGenres();
      return Result.success(genres);
    } catch (e) {
      return Result.failure(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<List<Artist>>> getArtistsByGenre({required String genreId, int limit = 20}) async {
    try {
      final artists = await _deezer.getGenreArtists(genreId: genreId, limit: limit);
      return Result.success(artists);
    } catch (e) {
      return Result.failure(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<PaginatedResult<Track>>> getCategoryTracks({
    required String genreName,
    int offset = 0,
    int limit = 20,
  }) async {
    return searchTracks(query: '$genreName music', offset: offset, limit: limit);
  }

  /// Keeps every `primary` (Deezer) track, then appends `secondary`
  /// (iTunes) tracks whose title+artist doesn't already appear — the
  /// "smart" duplicate-free merge mentioned in [MusicRepository].
  List<Track> _mergeDeduped({required List<Track> primary, required List<Track> secondary}) {
    final seen = primary.map((t) => t.dedupeKey).toSet();
    final result = List<Track>.from(primary);
    for (final track in secondary) {
      if (seen.add(track.dedupeKey)) {
        result.add(track);
      }
    }
    return result;
  }

  static List<Track> get fallbackTracks => _fallbackTracks;
  static List<Genre> get fallbackGenres => _fallbackGenres;

  static const List<Artist> _fallbackArtists = [
    Artist(
      id: '13',
      name: 'Eminem',
      pictureUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&auto=format&fit=crop&q=80',
      fanCount: 15000000,
    ),
    Artist(
      id: '4050205',
      name: 'The Weeknd',
      pictureUrl: 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=500&auto=format&fit=crop&q=80',
      fanCount: 18000000,
    ),
    Artist(
      id: '246791',
      name: 'Drake',
      pictureUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=500&auto=format&fit=crop&q=80',
      fanCount: 20000000,
    ),
    Artist(
      id: '12246',
      name: 'Taylor Swift',
      pictureUrl: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=500&auto=format&fit=crop&q=80',
      fanCount: 22000000,
    ),
    Artist(
      id: '1562681',
      name: 'Ariana Grande',
      pictureUrl: 'https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?w=500&auto=format&fit=crop&q=80',
      fanCount: 16000000,
    ),
    Artist(
      id: '9635624',
      name: 'Billie Eilish',
      pictureUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=500&auto=format&fit=crop&q=80',
      fanCount: 14000000,
    ),
    Artist(
      id: '429675',
      name: 'Bruno Mars',
      pictureUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&auto=format&fit=crop&q=80',
      fanCount: 12000000,
    ),
    Artist(
      id: '384236',
      name: 'Ed Sheeran',
      pictureUrl: 'https://images.unsplash.com/photo-1465847899084-d164df4dedc6?w=500&auto=format&fit=crop&q=80',
      fanCount: 19000000,
    ),
    Artist(
      id: '564',
      name: 'Rihanna',
      pictureUrl: 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=500&auto=format&fit=crop&q=80',
      fanCount: 17000000,
    ),
    Artist(
      id: '230',
      name: 'Kanye West',
      pictureUrl: 'https://images.unsplash.com/photo-1511192336575-5a79af67a629?w=500&auto=format&fit=crop&q=80',
      fanCount: 13000000,
    ),
    Artist(
      id: '8706544',
      name: 'Dua Lipa',
      pictureUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop&q=80',
      fanCount: 11000000,
    ),
    Artist(
      id: '7543848',
      name: 'Post Malone',
      pictureUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&auto=format&fit=crop&q=80',
      fanCount: 10000000,
    ),
  ];

  static const List<Track> _fallbackTracks = [
    Track(
      id: 'deezer_3135556',
      source: MusicSource.deezer,
      title: 'Lose Yourself',
      artistName: 'Eminem',
      albumName: '8 Mile',
      artworkUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&auto=format&fit=crop&q=80',
      previewUrl: 'https://cdns-preview-b.dzcdn.net/stream/c-b0e6df298f2b70f2f3d32152865ffb5f-5.mp3',
      durationMs: 326000,
      explicit: true,
    ),
    Track(
      id: 'deezer_12047952',
      source: MusicSource.deezer,
      title: 'Starboy',
      artistName: 'The Weeknd ft. Daft Punk',
      albumName: 'Starboy',
      artworkUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&auto=format&fit=crop&q=80',
      previewUrl: 'https://cdns-preview-d.dzcdn.net/stream/c-d41f0219c636f977d07993a200f68d60-7.mp3',
      durationMs: 230000,
    ),
    Track(
      id: 'deezer_864696812',
      source: MusicSource.deezer,
      title: 'Blinding Lights',
      artistName: 'The Weeknd',
      albumName: 'After Hours',
      artworkUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=500&auto=format&fit=crop&q=80',
      previewUrl: 'https://cdns-preview-e.dzcdn.net/stream/c-e99d3d3c26a63df4775d7146522c0617-6.mp3',
      durationMs: 200000,
    ),
    Track(
      id: 'deezer_486053332',
      source: MusicSource.deezer,
      title: 'God\'s Plan',
      artistName: 'Drake',
      albumName: 'Scorpion',
      artworkUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=500&auto=format&fit=crop&q=80',
      previewUrl: 'https://cdns-preview-8.dzcdn.net/stream/c-86e737c352a46e1bb2a62888981e4695-4.mp3',
      durationMs: 198000,
      explicit: true,
    ),
    Track(
      id: 'deezer_742416172',
      source: MusicSource.deezer,
      title: 'Cruel Summer',
      artistName: 'Taylor Swift',
      albumName: 'Lover',
      artworkUrl: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=500&auto=format&fit=crop&q=80',
      previewUrl: 'https://cdns-preview-8.dzcdn.net/stream/c-806b23d9a9b4f9fbdf940f81d830b5e4-2.mp3',
      durationMs: 178000,
    ),
    Track(
      id: 'deezer_658428802',
      source: MusicSource.deezer,
      title: 'bad guy',
      artistName: 'Billie Eilish',
      albumName: 'WHEN WE ALL FALL ASLEEP, WHERE DO WE GO?',
      artworkUrl: 'https://images.unsplash.com/photo-1511192336575-5a79af67a629?w=500&auto=format&fit=crop&q=80',
      previewUrl: 'https://cdns-preview-c.dzcdn.net/stream/c-c8206d99db8a8b132f8ebca6ed0d6b63-4.mp3',
      durationMs: 194000,
    ),
    Track(
      id: 'deezer_916424',
      source: MusicSource.deezer,
      title: 'Uptown Funk',
      artistName: 'Mark Ronson ft. Bruno Mars',
      albumName: 'Uptown Special',
      artworkUrl: 'https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?w=500&auto=format&fit=crop&q=80',
      previewUrl: 'https://cdns-preview-a.dzcdn.net/stream/c-a11b6911c03a6331a70cb65ec72e0d36-8.mp3',
      durationMs: 270000,
    ),
    Track(
      id: 'deezer_142986206',
      source: MusicSource.deezer,
      title: 'Shape of You',
      artistName: 'Ed Sheeran',
      albumName: '÷ (Divide)',
      artworkUrl: 'https://images.unsplash.com/photo-1465847899084-d164df4dedc6?w=500&auto=format&fit=crop&q=80',
      previewUrl: 'https://cdns-preview-0.dzcdn.net/stream/c-0b819e917d09228807d9f9bb42ed66fb-11.mp3',
      durationMs: 233000,
    ),
  ];

  static const List<Genre> _fallbackGenres = [
    Genre(
      id: '132',
      name: 'Pop',
      pictureUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=500&auto=format&fit=crop&q=80',
    ),
    Genre(
      id: '116',
      name: 'Hip-Hop',
      pictureUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&auto=format&fit=crop&q=80',
    ),
    Genre(
      id: '152',
      name: 'Rock',
      pictureUrl: 'https://images.unsplash.com/photo-1498038432885-c6f3f1b912ee?w=500&auto=format&fit=crop&q=80',
    ),
    Genre(
      id: '113',
      name: 'Dance',
      pictureUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&auto=format&fit=crop&q=80',
    ),
    Genre(
      id: '165',
      name: 'R&B',
      pictureUrl: 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=500&auto=format&fit=crop&q=80',
    ),
    Genre(
      id: '106',
      name: 'Electro',
      pictureUrl: 'https://images.unsplash.com/photo-1511192336575-5a79af67a629?w=500&auto=format&fit=crop&q=80',
    ),
  ];
}
