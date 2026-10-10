import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:neon_wave/src/core/network/network_exceptions.dart';
import 'package:neon_wave/src/core/services/deezer_service.dart';

class MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _jsonResponse(Map<String, dynamic> data, {String path = '/search'}) {
  return Response<Map<String, dynamic>>(
    data: data,
    requestOptions: RequestOptions(path: path),
    statusCode: 200,
  );
}

void main() {
  late MockDio mockDio;
  late DeezerService service;

  setUpAll(() {
    registerFallbackValue(Options());
  });

  setUp(() {
    mockDio = MockDio();
    service = DeezerService(dio: mockDio);
  });

  group('DeezerService.searchTracks', () {
    test('maps a Deezer track list into domain Tracks', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _jsonResponse({
            'data': [
              {
                'id': 3135556,
                'title': 'Lose Yourself',
                'duration': 320,
                'explicit_lyrics': true,
                'preview': 'https://cdn.example.com/preview.mp3',
                'artist': {'id': 13, 'name': 'Eminem', 'picture_medium': 'https://img/artist.jpg'},
                'album': {'title': '8 Mile', 'cover_medium': 'https://img/album.jpg'},
              },
            ],
            'total': 1,
          }));

      final page = await service.searchTracks(query: 'eminem', offset: 0, limit: 20);

      expect(page.items, hasLength(1));
      expect(page.items.first.id, 'deezer_3135556');
      expect(page.items.first.title, 'Lose Yourself');
      expect(page.items.first.artistName, 'Eminem');
      expect(page.items.first.durationMs, 320000);
      expect(page.items.first.explicit, isTrue);
      // No `next` key in the fake payload above.
      expect(page.hasMore, isFalse);
    });

    test('hasMore is true when the response includes a `next` link', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _jsonResponse({
            'data': <Map<String, dynamic>>[],
            'total': 100,
            'next': 'https://api.deezer.com/search?q=eminem&index=20&limit=20',
          }));

      final page = await service.searchTracks(query: 'eminem', offset: 0, limit: 20);

      expect(page.hasMore, isTrue);
      expect(page.nextOffset, 20);
    });

    test('requests the correct index/limit for the given offset', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _jsonResponse({'data': <Map<String, dynamic>>[]}));

      await service.searchTracks(query: 'drake', offset: 40, limit: 20);

      final captured = verify(() => mockDio.get<Map<String, dynamic>>(
            '/search',
            queryParameters: captureAny(named: 'queryParameters'),
          )).captured.single as Map<String, dynamic>;

      expect(captured['q'], 'drake');
      expect(captured['index'], 40);
      expect(captured['limit'], 20);
    });

    test('throws a ServerFailure when Deezer responds with an error payload', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _jsonResponse({
            'error': {'type': 'ParameterException', 'message': 'Bad query', 'code': 501},
          }));

      expect(
        () => service.searchTracks(query: '', offset: 0, limit: 20),
        throwsA(isA<ServerFailure>()),
      );
    });

    test('maps a DioException to a typed Failure instead of leaking it', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/search'),
          type: DioExceptionType.connectionError,
        ),
      );

      expect(
        () => service.searchTracks(query: 'eminem', offset: 0, limit: 20),
        throwsA(isA<NoInternetFailure>()),
      );
    });
  });

  group('DeezerService.getGenres', () {
    test('filters out the non-genre "All genres" (id 0) entry', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _jsonResponse({
            'data': [
              {'id': 0, 'name': 'All genres', 'picture': ''},
              {'id': 132, 'name': 'Pop', 'picture': 'https://img/pop.jpg'},
            ],
          }));

      final genres = await service.getGenres();

      expect(genres, hasLength(1));
      expect(genres.single.name, 'Pop');
    });
  });
}
