import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../models/track_model.dart';
import '../network/network_exceptions.dart';

/// Talks to the iTunes Search API (https://itunes.apple.com/search).
///
/// Unlike Deezer, this endpoint has no documented/reliable offset-based
/// pagination — `limit` is honoured but there is no safe way to ask for
/// "page 2" of the same query. Because of that [MusicRepositoryImpl] only
/// calls this service for the *first* page of a search and folds the
/// results in alongside Deezer's; every subsequent page comes from Deezer
/// alone. See that class for the merge/dedupe logic.
class ItunesService {
  ItunesService({Dio? dio}) : _dio = dio ?? _createDefaultDio();

  static Dio _createDefaultDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.itunesBaseUrl,
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

  Future<List<Track>> searchTracks({required String query, int limit = 25}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.itunesSearch,
        queryParameters: {
          'term': query,
          'media': 'music',
          'entity': 'song',
          'limit': limit,
        },
      );
      final data = response.data ?? const {};
      final results = (data['results'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
      return results
          .where((e) => e['trackId'] != null)
          .map(Track.fromItunesJson)
          .toList();
    } on DioException catch (e) {
      throw mapExceptionToFailure(e);
    } catch (e) {
      throw mapExceptionToFailure(e);
    }
  }
}
