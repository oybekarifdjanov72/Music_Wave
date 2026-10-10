import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../models/artist_model.dart';
import '../models/genre_model.dart';
import '../models/paginated_result.dart';
import '../models/track_model.dart';
import '../network/network_exceptions.dart';

/// Talks to the Deezer public API (https://api.deezer.com) and maps every
/// response straight into our domain models. This is the "real" pagination
/// source in the app: Deezer's list endpoints accept `index`/`limit` and
/// tell us whether there's a next page via a `next` field.
///
/// Kept deliberately dumb (no caching, no merging) so it's trivial to unit
/// test in isolation — see `test/core/services/deezer_service_test.dart`.
class DeezerService {
  DeezerService({Dio? dio}) : _dio = dio ?? _createDefaultDio();

  static Dio _createDefaultDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.deezerBaseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
      ),
    );
    if (kIsWeb) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final fullUrl = options.uri.toString();
            if (!fullUrl.startsWith('https://corsproxy.io/?')) {
              options.path = 'https://corsproxy.io/?$fullUrl';
              options.queryParameters = {};
            }
            return handler.next(options);
          },
        ),
      );
    }
    return dio;
  }

  final Dio _dio;

  Future<PaginatedResult<Track>> searchTracks({
    required String query,
    int offset = 0,
    int limit = 20,
  }) async {
    final json = await _get(ApiConstants.deezerSearchTracks, {
      'q': query,
      'index': offset,
      'limit': limit,
    });
    return _paginatedTracksFrom(json, offset: offset, limit: limit);
  }

  Future<PaginatedResult<Track>> getChartTracks({int offset = 0, int limit = 20}) async {
    final json = await _get(ApiConstants.deezerChartTracks, {
      'index': offset,
      'limit': limit,
    });
    return _paginatedTracksFrom(json, offset: offset, limit: limit);
  }

  Future<List<Track>> getArtistTopTracks({required String artistId, int limit = 15}) async {
    final json = await _get(ApiConstants.deezerArtistTop(artistId), {'limit': limit});
    return _tracksFromDataList(json);
  }

  /// Deezer's "radio" mix for an artist. Useful when `/artist/{id}/top`
  /// is empty or returns unrelated collabs (seen with Madonna / HONNE).
  Future<List<Track>> getArtistRadio({required String artistId}) async {
    final json = await _get(ApiConstants.deezerArtistRadio(artistId), const {});
    return _tracksFromDataList(json);
  }

  Future<List<Map<String, dynamic>>> getArtistAlbums({
    required String artistId,
    int limit = 10,
  }) async {
    final json = await _get(ApiConstants.deezerArtistAlbums(artistId), {'limit': limit});
    return (json['data'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
  }

  Future<List<Track>> getAlbumTracks({
    required String albumId,
    String? albumTitle,
    String? albumCover,
  }) async {
    final json = await _get(ApiConstants.deezerAlbumTracks(albumId), const {});
    final list = (json['data'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    return list.map((raw) {
      final enriched = Map<String, dynamic>.from(raw);
      if (enriched['album'] == null) {
        enriched['album'] = {
          'title': albumTitle ?? '',
          'cover_medium': albumCover ?? '',
          'cover': albumCover ?? '',
        };
      }
      return Track.fromDeezerJson(enriched);
    }).toList();
  }

  Future<List<Artist>> searchArtists({required String query, int limit = 20}) async {
    final json = await _get(ApiConstants.deezerSearchArtists, {'q': query, 'limit': limit});
    return _artistsFromDataList(json);
  }

  Future<List<Artist>> getChartArtists({int limit = 30}) async {
    final json = await _get(ApiConstants.deezerChartArtists, {'limit': limit});
    return _artistsFromDataList(json);
  }

  Future<List<Artist>> getGenreArtists({required String genreId, int limit = 20}) async {
    final json = await _get(ApiConstants.deezerGenreArtists(genreId), {'limit': limit});
    return _artistsFromDataList(json);
  }

  Future<List<Genre>> getGenres() async {
    final json = await _get(ApiConstants.deezerGenres, const {});
    final data = (json['data'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        // Deezer always returns a genre with id 0 ("All genres") first;
        // it's not a real category so it's not useful as a filter chip.
        .where((g) => g['id'].toString() != '0')
        .map(Genre.fromDeezerJson)
        .toList();
    return data;
  }

  Future<Map<String, dynamic>> _get(String path, Map<String, dynamic> query) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(path, queryParameters: query);
      final data = response.data ?? const {};
      if (data['error'] != null) {
        final err = data['error'] as Map<String, dynamic>;
        throw ServerFailure(err['message'] as String? ?? 'Deezer request failed');
      }
      return data;
    } on DioException catch (e) {
      throw mapExceptionToFailure(e);
    } catch (e) {
      throw mapExceptionToFailure(e);
    }
  }

  PaginatedResult<Track> _paginatedTracksFrom(
    Map<String, dynamic> json, {
    required int offset,
    required int limit,
  }) {
    final tracks = _tracksFromDataList(json);
    final hasMore = json.containsKey('next');
    return PaginatedResult<Track>(
      items: tracks,
      hasMore: hasMore,
      nextOffset: offset + limit,
    );
  }

  List<Track> _tracksFromDataList(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    return list
        .where((e) => e['preview'] != null || e['id'] != null)
        .map(Track.fromDeezerJson)
        .toList();
  }

  List<Artist> _artistsFromDataList(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    return list.map(Artist.fromDeezerJson).toList();
  }
}
