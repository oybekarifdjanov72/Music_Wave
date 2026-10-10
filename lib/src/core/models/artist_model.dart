import 'package:equatable/equatable.dart';

/// An artist/singer, as returned by Deezer (search, chart, or genre
/// listings). Used both for the onboarding "pick your singers" step and
/// for artist chips/results elsewhere.
class Artist extends Equatable {
  const Artist({
    required this.id,
    required this.name,
    required this.pictureUrl,
    this.fanCount,
  });

  final String id;
  final String name;
  final String pictureUrl;
  final int? fanCount;

  factory Artist.fromDeezerJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'].toString(),
      name: (json['name'] ?? 'Unknown artist') as String,
      pictureUrl: (json['picture_medium'] ?? json['picture'] ?? '') as String,
      fanCount: (json['nb_fan'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toCacheJson() => {
        'id': id,
        'name': name,
        'pictureUrl': pictureUrl,
        'fanCount': fanCount,
      };

  factory Artist.fromCacheJson(Map<String, dynamic> json) {
    var id = json['id'] as String;
    // Legacy fallback artists were stored as "deezer_13"; live Deezer
    // artists use the bare numeric id. Normalize so /artist/{id}/top works.
    if (id.startsWith('deezer_')) {
      id = id.substring('deezer_'.length);
    }
    return Artist(
      id: id,
      name: json['name'] as String,
      pictureUrl: json['pictureUrl'] as String? ?? '',
      fanCount: (json['fanCount'] as num?)?.toInt(),
    );
  }

  @override
  List<Object?> get props => [id];
}
