import 'package:equatable/equatable.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/artist_model.dart';

class ArtistSelectionState extends Equatable {
  const ArtistSelectionState({
    this.isLoading = true,
    this.isSubmitting = false,
    this.isDone = false,
    this.error,
    this.popularArtists = const [],
    this.searchResults = const [],
    this.searchQuery = '',
    this.selectedArtists = const {},
  });

  final bool isLoading;
  final bool isSubmitting;
  final bool isDone;
  final String? error;
  final List<Artist> popularArtists;
  final List<Artist> searchResults;
  final String searchQuery;

  /// Keyed by artist id so a selection survives switching between the
  /// popular grid and search results.
  final Map<String, Artist> selectedArtists;

  bool get isSearching => searchQuery.trim().isNotEmpty;
  int get selectedCount => selectedArtists.length;
  bool get canContinue => selectedCount >= AppConstants.minSingersToSelect;
  bool isSelected(String artistId) => selectedArtists.containsKey(artistId);

  ArtistSelectionState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    bool? isDone,
    String? error,
    List<Artist>? popularArtists,
    List<Artist>? searchResults,
    String? searchQuery,
    Map<String, Artist>? selectedArtists,
  }) {
    return ArtistSelectionState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isDone: isDone ?? this.isDone,
      error: error,
      popularArtists: popularArtists ?? this.popularArtists,
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedArtists: selectedArtists ?? this.selectedArtists,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSubmitting,
        isDone,
        error,
        popularArtists,
        searchResults,
        searchQuery,
        selectedArtists,
      ];
}
