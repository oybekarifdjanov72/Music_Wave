import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:neon_wave/src/core/models/paginated_result.dart';
import 'package:neon_wave/src/core/models/track_model.dart';
import 'package:neon_wave/src/core/network/network_exceptions.dart';
import 'package:neon_wave/src/core/repositories/music_repository_impl.dart';
import 'package:neon_wave/src/core/services/deezer_service.dart';
import 'package:neon_wave/src/core/services/itunes_service.dart';

class MockDeezerService extends Mock implements DeezerService {}

class MockItunesService extends Mock implements ItunesService {}

Track _track({required String id, required MusicSource source, String title = 'Song', String artist = 'Artist'}) {
  return Track(
    id: id,
    source: source,
    title: title,
    artistName: artist,
    albumName: 'Album',
    artworkUrl: 'https://img/art.jpg',
    previewUrl: 'https://cdn/preview.mp3',
    durationMs: 200000,
  );
}

void main() {
  late MockDeezerService deezer;
  late MockItunesService itunes;
  late MusicRepositoryImpl repository;

  setUp(() {
    deezer = MockDeezerService();
    itunes = MockItunesService();
    repository = MusicRepositoryImpl(deezerService: deezer, itunesService: itunes);
  });

  group('searchTracks — page one (offset 0)', () {
    test('merges Deezer + iTunes results and de-duplicates by title/artist', () async {
      final deezerPage = PaginatedResult<Track>(
        items: [
          _track(id: 'deezer_1', source: MusicSource.deezer, title: 'Lose Yourself', artist: 'Eminem'),
          _track(id: 'deezer_2', source: MusicSource.deezer, title: 'Stan', artist: 'Eminem'),
        ],
        hasMore: true,
        nextOffset: 20,
      );
      when(() => deezer.searchTracks(query: any(named: 'query'), offset: 0, limit: 20))
          .thenAnswer((_) async => deezerPage);
      when(() => itunes.searchTracks(query: any(named: 'query'), limit: 20)).thenAnswer(
        (_) async => [
          // Same song as deezer_1 — should be dropped as a duplicate.
          _track(id: 'itunes_1', source: MusicSource.itunes, title: 'Lose Yourself', artist: 'Eminem'),
          // A genuinely different song — should be kept.
          _track(id: 'itunes_2', source: MusicSource.itunes, title: 'Not Afraid', artist: 'Eminem'),
        ],
      );

      final result = await repository.searchTracks(query: 'eminem', offset: 0, limit: 20);

      final page = result.dataOrNull!;
      expect(page.items.map((t) => t.id), ['deezer_1', 'deezer_2', 'itunes_2']);
      expect(page.hasMore, isTrue);
      expect(page.nextOffset, 20);
    });

    test('falls back to Deezer-only results if iTunes fails', () async {
      final deezerPage = PaginatedResult<Track>(
        items: [_track(id: 'deezer_1', source: MusicSource.deezer)],
        hasMore: false,
        nextOffset: 20,
      );
      when(() => deezer.searchTracks(query: any(named: 'query'), offset: 0, limit: 20))
          .thenAnswer((_) async => deezerPage);
      when(() => itunes.searchTracks(query: any(named: 'query'), limit: 20))
          .thenThrow(const NoInternetFailure());

      final result = await repository.searchTracks(query: 'eminem', offset: 0, limit: 20);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull!.items.map((t) => t.id), ['deezer_1']);
    });

    test('returns a Failure when Deezer itself fails', () async {
      when(() => deezer.searchTracks(query: any(named: 'query'), offset: 0, limit: 20))
          .thenThrow(const NoInternetFailure());

      final result = await repository.searchTracks(query: 'eminem', offset: 0, limit: 20);

      expect(result.isFailure, isTrue);
      result.when(
        success: (_) => fail('expected a failure'),
        failure: (f) => expect(f, isA<NoInternetFailure>()),
      );
    });
  });

  group('searchTracks — subsequent pages (offset > 0)', () {
    test('only calls Deezer, never iTunes, for page 2+', () async {
      final deezerPage = PaginatedResult<Track>(
        items: [_track(id: 'deezer_21', source: MusicSource.deezer)],
        hasMore: false,
        nextOffset: 40,
      );
      when(() => deezer.searchTracks(query: any(named: 'query'), offset: 20, limit: 20))
          .thenAnswer((_) async => deezerPage);

      final result = await repository.searchTracks(query: 'eminem', offset: 20, limit: 20);

      expect(result.dataOrNull!.items.map((t) => t.id), ['deezer_21']);
      verifyNever(() => itunes.searchTracks(query: any(named: 'query'), limit: any(named: 'limit')));
    });
  });

  group('getChartTracks', () {
    test('returns the chart items on success', () async {
      when(() => deezer.getChartTracks(limit: 20)).thenAnswer(
        (_) async => PaginatedResult<Track>(
          items: [_track(id: 'deezer_1', source: MusicSource.deezer)],
          hasMore: true,
          nextOffset: 20,
        ),
      );

      final result = await repository.getChartTracks(limit: 20);

      expect(result.dataOrNull, hasLength(1));
    });

    test('maps a thrown Failure through to Result.failure', () async {
      when(() => deezer.getChartTracks(limit: 20)).thenThrow(const ServerFailure());

      final result = await repository.getChartTracks(limit: 20);

      expect(result.isFailure, isTrue);
    });
  });
}
