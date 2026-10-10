import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:neon_wave/src/core/network/network_exceptions.dart';
import 'package:neon_wave/src/core/services/itunes_service.dart';

class MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _jsonResponse(Map<String, dynamic> data) {
  return Response<Map<String, dynamic>>(
    data: data,
    requestOptions: RequestOptions(path: '/search'),
    statusCode: 200,
  );
}

void main() {
  late MockDio mockDio;
  late ItunesService service;

  setUp(() {
    mockDio = MockDio();
    service = ItunesService(dio: mockDio);
  });

  group('ItunesService.searchTracks', () {
    test('maps iTunes results into domain Tracks and upscales artwork', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _jsonResponse({
            'results': [
              {
                'trackId': 987654,
                'trackName': 'Lose Yourself',
                'artistName': 'Eminem',
                'artistId': 13,
                'collectionName': '8 Mile',
                'artworkUrl100': 'https://img.example.com/100x100bb.jpg',
                'previewUrl': 'https://cdn.example.com/preview.m4a',
                'trackTimeMillis': 320000,
                'trackExplicitness': 'explicit',
              },
            ],
          }));

      final tracks = await service.searchTracks(query: 'eminem');

      expect(tracks, hasLength(1));
      final track = tracks.first;
      expect(track.id, 'itunes_987654');
      expect(track.title, 'Lose Yourself');
      expect(track.artistName, 'Eminem');
      expect(track.durationMs, 320000);
      expect(track.explicit, isTrue);
      // 100x100 artwork should be upgraded to a much larger size.
      expect(track.artworkUrl, contains('600x600bb'));
    });

    test('skips malformed entries with no trackId', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _jsonResponse({
            'results': [
              {'trackName': 'Missing id'},
            ],
          }));

      final tracks = await service.searchTracks(query: 'eminem');

      expect(tracks, isEmpty);
    });

    test('maps a DioException into a typed Failure', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/search'),
          type: DioExceptionType.receiveTimeout,
        ),
      );

      expect(
        () => service.searchTracks(query: 'eminem'),
        throwsA(isA<TimeoutFailure>()),
      );
    });
  });
}
