import 'package:equatable/equatable.dart';

import '../../../core/models/artist_model.dart';
import '../../../core/models/genre_model.dart';
import '../../../core/models/track_model.dart';

class SearchState extends Equatable {
  const SearchState({
    this.query = '',
    this.genres = const [],
    this.isLoadingGenres = true,
    this.selectedGenre,
    this.genreArtists,
    this.isLoadingGenreArtists = false,
    this.categoryTracks = const [],
    this.isLoadingCategoryTracks = false,
    this.hasMoreCategoryTracks = false,
    this.categoryNextOffset = 0,
    this.isLoadingMoreCategoryTracks = false,
    this.results = const [],
    this.isSearching = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.nextOffset = 0,
    this.error,
    this.recentSearches = const [],
  });

  final String query;
  final List<Genre> genres;
  final bool isLoadingGenres;
  final Genre? selectedGenre;
  final List<Artist>? genreArtists;
  final bool isLoadingGenreArtists;

  // Category Songs state
  final List<Track> categoryTracks;
  final bool isLoadingCategoryTracks;
  final bool hasMoreCategoryTracks;
  final int categoryNextOffset;
  final bool isLoadingMoreCategoryTracks;

  final List<Track> results;
  final bool isSearching;
  final bool isLoadingMore;
  final bool hasMore;
  final int nextOffset;
  final String? error;
  final List<String> recentSearches;

  bool get hasQuery => query.trim().isNotEmpty;
  bool get isBrowsing => !hasQuery;

  SearchState copyWith({
    String? query,
    List<Genre>? genres,
    bool? isLoadingGenres,
    Genre? selectedGenre,
    bool clearSelectedGenre = false,
    List<Artist>? genreArtists,
    bool? isLoadingGenreArtists,
    List<Track>? categoryTracks,
    bool? isLoadingCategoryTracks,
    bool? hasMoreCategoryTracks,
    int? categoryNextOffset,
    bool? isLoadingMoreCategoryTracks,
    List<Track>? results,
    bool? isSearching,
    bool? isLoadingMore,
    bool? hasMore,
    int? nextOffset,
    String? error,
    bool clearError = false,
    List<String>? recentSearches,
  }) {
    return SearchState(
      query: query ?? this.query,
      genres: genres ?? this.genres,
      isLoadingGenres: isLoadingGenres ?? this.isLoadingGenres,
      selectedGenre: clearSelectedGenre ? null : (selectedGenre ?? this.selectedGenre),
      genreArtists: clearSelectedGenre ? null : (genreArtists ?? this.genreArtists),
      isLoadingGenreArtists: isLoadingGenreArtists ?? this.isLoadingGenreArtists,
      categoryTracks: clearSelectedGenre ? const [] : (categoryTracks ?? this.categoryTracks),
      isLoadingCategoryTracks: isLoadingCategoryTracks ?? this.isLoadingCategoryTracks,
      hasMoreCategoryTracks: hasMoreCategoryTracks ?? this.hasMoreCategoryTracks,
      categoryNextOffset: categoryNextOffset ?? this.categoryNextOffset,
      isLoadingMoreCategoryTracks: isLoadingMoreCategoryTracks ?? this.isLoadingMoreCategoryTracks,
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      nextOffset: nextOffset ?? this.nextOffset,
      error: clearError ? null : (error ?? this.error),
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }

  @override
  List<Object?> get props => [
        query,
        genres,
        isLoadingGenres,
        selectedGenre,
        genreArtists,
        isLoadingGenreArtists,
        categoryTracks,
        isLoadingCategoryTracks,
        hasMoreCategoryTracks,
        categoryNextOffset,
        isLoadingMoreCategoryTracks,
        results,
        isSearching,
        isLoadingMore,
        hasMore,
        nextOffset,
        error,
        recentSearches,
      ];
}
