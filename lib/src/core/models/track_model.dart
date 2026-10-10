import 'package:equatable/equatable.dart';

/// Which upstream API a [Track] came from. Kept on the model so the UI can
/// (optionally) show provenance, and so the repository can apply
/// source-specific merge/dedupe rules.
enum MusicSource { deezer, itunes }

/// A single song, normalised from either Deezer or iTunes into one shape
/// the rest of the app never has to special-case.
class Track extends Equatable {
  const Track({
    required this.id,
    required this.source,
    required this.title,
    required this.artistName,
    required this.albumName,
    required this.artworkUrl,
    required this.previewUrl,
    required this.durationMs,
    this.artistId,
    this.explicit = false,
  });

  /// Globally unique within the app: `"deezer_123"` / `"itunes_456"`.
  final String id;
  final MusicSource source;
  final String title;
  final String artistName;
  final String? artistId;
  final String albumName;
  final String artworkUrl;

  /// 30-second preview clip. Both APIs are free/key-less and only expose a
  /// short preview rather than full playback — this is what the in-app
  /// player streams.
  final String? previewUrl;
  final int durationMs;
  final bool explicit;

  bool get isPlayable => previewUrl != null && previewUrl!.isNotEmpty;

  /// Loose key used to detect the "same song" across the two providers
  /// (e.g. Deezer's "Lose Yourself" by Eminem vs iTunes' copy of it) so we
  /// never show an obvious duplicate in a merged list.
  String get dedupeKey =>
      '${title.trim().toLowerCase()}|${artistName.trim().toLowerCase()}';

  factory Track.fromDeezerJson(Map<String, dynamic> json) {
    final artist = (json['artist'] as Map<String, dynamic>?) ?? const {};
    final album = (json['album'] as Map<String, dynamic>?) ?? const {};
    return Track(
      id: 'deezer_${json['id']}',
      source: MusicSource.deezer,
      title: (json['title'] ?? json['title_short'] ?? 'Unknown title') as String,
      artistName: (artist['name'] ?? 'Unknown artist') as String,
      artistId: artist['id']?.toString(),
      albumName: (album['title'] ?? '') as String,
      artworkUrl: (album['cover_medium'] ?? album['cover'] ?? '') as String,
      previewUrl: json['preview'] as String?,
      durationMs: ((json['duration'] ?? 0) as num).toInt() * 1000,
      explicit: (json['explicit_lyrics'] ?? false) as bool,
    );
  }

  factory Track.fromItunesJson(Map<String, dynamic> json) {
    // iTunes only ships small 100x100 artwork by default; this upscales it.
    final rawArt = (json['artworkUrl100'] ?? json['artworkUrl60'] ?? '') as String;
    final bigArt = rawArt.replaceAll('100x100bb', '600x600bb');
    return Track(
      id: 'itunes_${json['trackId']}',
      source: MusicSource.itunes,
      title: (json['trackName'] ?? 'Unknown title') as String,
      artistName: (json['artistName'] ?? 'Unknown artist') as String,
      artistId: json['artistId']?.toString(),
      albumName: (json['collectionName'] ?? '') as String,
      artworkUrl: bigArt,
      previewUrl: json['previewUrl'] as String?,
      durationMs: ((json['trackTimeMillis'] ?? 0) as num).toInt(),
      explicit: (json['trackExplicitness'] ?? 'notExplicit') == 'explicit',
    );
  }

  Map<String, dynamic> toCacheJson() => {
        'id': id,
        'source': source.name,
        'title': title,
        'artistName': artistName,
        'artistId': artistId,
        'albumName': albumName,
        'artworkUrl': artworkUrl,
        'previewUrl': previewUrl,
        'durationMs': durationMs,
        'explicit': explicit,
      };

  factory Track.fromCacheJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] as String,
      source: MusicSource.values.firstWhere(
        (s) => s.name == json['source'],
        orElse: () => MusicSource.deezer,
      ),
      title: json['title'] as String,
      artistName: json['artistName'] as String,
      artistId: json['artistId'] as String?,
      albumName: json['albumName'] as String? ?? '',
      artworkUrl: json['artworkUrl'] as String? ?? '',
      previewUrl: json['previewUrl'] as String?,
      durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
      explicit: json['explicit'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id];
}
