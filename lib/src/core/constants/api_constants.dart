/// All network endpoints the app talks to. Both APIs are free, public,
/// key-less endpoints:
///  * Deezer  — used for search, charts, artists, genres. It supports real
///    `index`/`limit` based pagination and returns a `next` link, so it is
///    the backbone of every paginated / "load more" list in the app.
///  * iTunes Search API — used as a second, independent source that gets
///    merged into the *first* page of a search only (see [MusicRepository]
///    for why: the endpoint has no reliable offset-based paging).
class ApiConstants {
  ApiConstants._();

  // ---- Deezer ----
  static const String deezerBaseUrl = 'https://api.deezer.com';
  static const String deezerSearchTracks = '/search';
  static const String deezerSearchArtists = '/search/artist';
  static const String deezerChartTracks = '/chart/0/tracks';
  static const String deezerChartArtists = '/chart/0/artists';
  static const String deezerGenres = '/genre';
  static String deezerGenreArtists(String genreId) => '/genre/$genreId/artists';
  static String deezerArtistTop(String artistId) => '/artist/$artistId/top';
  static String deezerArtistRadio(String artistId) => '/artist/$artistId/radio';
  static String deezerArtistAlbums(String artistId) => '/artist/$artistId/albums';
  static String deezerAlbumTracks(String albumId) => '/album/$albumId/tracks';

  // ---- iTunes ----
  static const String itunesBaseUrl = 'https://itunes.apple.com';
  static const String itunesSearch = '/search';

  static const Duration connectTimeout = Duration(seconds: 12);
  static const Duration receiveTimeout = Duration(seconds: 12);
}
