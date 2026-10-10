import 'package:equatable/equatable.dart';

/// A music genre/category (Deezer `/genre`), used to power the filter
/// chips on the Search screen.
class Genre extends Equatable {
  const Genre({required this.id, required this.name, required this.pictureUrl});

  final String id;
  final String name;
  final String pictureUrl;

  factory Genre.fromDeezerJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'].toString(),
      name: (json['name'] ?? '') as String,
      pictureUrl: (json['picture_medium'] ?? json['picture'] ?? '') as String,
    );
  }

  @override
  List<Object?> get props => [id];
}
