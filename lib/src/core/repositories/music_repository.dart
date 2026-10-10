import '../models/artist_model.dart';
import '../models/genre_model.dart';
import '../models/paginated_result.dart';
import '../models/track_model.dart';
import '../network/result.dart';

/// The single door every screen goes through to get music data. Cubits
/// depend on this abstraction (never on [DeezerService]/[ItunesService]
/// directly), which is what makes them trivially testable with a fake
/// repository.
abstract class MusicRepository {
  /// Paginated, merged search across both providers.
  ///
  /// * `offset == 0`: fetches Deezer **and** iTunes, merges them (Deezer
  ///   first, iTunes de-duplicated against it) into one page.
  /// * `offset > 0`: fetches only the next Deezer page — iTunes has no
  ///   reliable offset paging, so it only ever contributes to page one.
  Future<Result<PaginatedResult<Track>>> searchTracks({
    required String query,
    int offset = 0,
    int limit = 20,
  });

  Future<Result<List<Artist>>> searchArtists({required String query, int limit = 20});

  /// A curated "popular artists" list used to seed the onboarding
  /// singer-picker (Deezer's current artist chart).
  Future<Result<List<Artist>>> getPopularArtists({int limit = 30});

  /// "Popular Right Now" on the Home screen.
  Future<Result<List<Track>>> getChartTracks({int limit = 20});

  /// Used both for "Made For You" (the singers a person picked at
  /// onboarding) and for an artist's own page.
  ///
  /// [artistId] may be a bare Deezer id (`"290"`) or a legacy prefixed
  /// id (`"deezer_290"`) — both are accepted. When Deezer's `/top`
  /// endpoint is empty or returns unrelated collabs, the repository
  /// falls back to the artist's radio mix and album tracks.
  Future<Result<List<Track>>> getArtistTopTracks({required String artistId, int limit = 15});

  /// Category chips on the Search screen.
  Future<Result<List<Genre>>> getGenres();

  Future<Result<List<Artist>>> getArtistsByGenre({required String genreId, int limit = 20});

  /// Paginated songs belonging to a specific music category (e.g. Pop, Jazz, Hip-Hop).
  Future<Result<PaginatedResult<Track>>> getCategoryTracks({
    required String genreName,
    int offset = 0,
    int limit = 20,
  });
}
