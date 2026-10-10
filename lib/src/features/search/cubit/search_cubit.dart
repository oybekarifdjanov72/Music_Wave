import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/models/genre_model.dart';
import '../../../core/repositories/music_repository.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/utils/debouncer.dart';
import 'search_state.dart';

/// Drives the Search screen: genre/category browsing with infinite-scroll
/// category tracks, debounced merged search (Deezer + iTunes on page one),
/// and infinite-scroll pagination for every page after that.
class SearchCubit extends Cubit<SearchState> {
  SearchCubit({MusicRepository? musicRepository, LocalStorageService? storage})
      : _repository = musicRepository ?? getIt<MusicRepository>(),
        _storage = storage ?? getIt<LocalStorageService>(),
        super(const SearchState()) {
    _init();
  }

  final MusicRepository _repository;
  final LocalStorageService _storage;
  final Debouncer _debouncer = Debouncer(delay: AppConstants.searchDebounce);

  Future<void> _init() async {
    emit(state.copyWith(recentSearches: _storage.getRecentSearches()));
    final result = await _repository.getGenres();
    result.when(
      success: (genres) => emit(state.copyWith(genres: genres, isLoadingGenres: false)),
      failure: (_) => emit(state.copyWith(isLoadingGenres: false)),
    );
  }

  /// Called on every keystroke — debounced so we don't fire a request per
  /// character.
  void onQueryChanged(String query) {
    emit(state.copyWith(query: query, clearSelectedGenre: query.trim().isNotEmpty));
    _debouncer.run(() => runSearch(query));
  }

  /// Runs immediately (no debounce) — used for tapping a recent-search chip.
  Future<void> searchNow(String query) async {
    emit(state.copyWith(query: query));
    await runSearch(query);
  }

  Future<void> runSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      emit(state.copyWith(results: const [], isSearching: false, clearError: true));
      return;
    }

    emit(state.copyWith(isSearching: true, clearError: true));
    final result = await _repository.searchTracks(query: trimmed, offset: 0, limit: AppConstants.defaultPageLimit);

    result.when(
      success: (page) {
        emit(
          state.copyWith(
            results: page.items,
            isSearching: false,
            hasMore: page.hasMore,
            nextOffset: page.nextOffset,
          ),
        );
        _storage.addRecentSearch(trimmed, maxEntries: AppConstants.maxRecentSearches);
        emit(state.copyWith(recentSearches: _storage.getRecentSearches()));
      },
      failure: (failure) => emit(
        state.copyWith(isSearching: false, error: failure.message),
      ),
    );
  }

  /// Infinite scroll for search results.
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || !state.hasQuery) return;

    emit(state.copyWith(isLoadingMore: true));
    final result = await _repository.searchTracks(
      query: state.query.trim(),
      offset: state.nextOffset,
      limit: AppConstants.defaultPageLimit,
    );

    result.when(
      success: (page) {
        final seen = state.results.map((t) => t.id).toSet();
        final appended = [...state.results, ...page.items.where((t) => seen.add(t.id))];
        emit(
          state.copyWith(
            results: appended,
            isLoadingMore: false,
            hasMore: page.hasMore,
            nextOffset: page.nextOffset,
          ),
        );
      },
      failure: (_) => emit(state.copyWith(isLoadingMore: false)),
    );
  }

  /// Category Selection: Loads category songs in a paginated grid.
  Future<void> selectGenre(Genre genre) async {
    if (state.selectedGenre?.id == genre.id) {
      emit(state.copyWith(clearSelectedGenre: true));
      return;
    }
    emit(state.copyWith(
      selectedGenre: genre,
      isLoadingCategoryTracks: true,
      categoryTracks: const [],
    ));

    final result = await _repository.getCategoryTracks(
      genreName: genre.name,
      offset: 0,
      limit: AppConstants.defaultPageLimit,
    );

    result.when(
      success: (page) => emit(state.copyWith(
        categoryTracks: page.items,
        hasMoreCategoryTracks: page.hasMore,
        categoryNextOffset: page.nextOffset,
        isLoadingCategoryTracks: false,
      )),
      failure: (_) => emit(state.copyWith(
        categoryTracks: const [],
        isLoadingCategoryTracks: false,
      )),
    );
  }

  /// Infinite scroll for category tracks.
  Future<void> loadMoreCategoryTracks() async {
    if (state.isLoadingMoreCategoryTracks ||
        !state.hasMoreCategoryTracks ||
        state.selectedGenre == null) {
      return;
    }

    emit(state.copyWith(isLoadingMoreCategoryTracks: true));
    final result = await _repository.getCategoryTracks(
      genreName: state.selectedGenre!.name,
      offset: state.categoryNextOffset,
      limit: AppConstants.defaultPageLimit,
    );

    result.when(
      success: (page) {
        final seen = state.categoryTracks.map((t) => t.id).toSet();
        final appended = [...state.categoryTracks, ...page.items.where((t) => seen.add(t.id))];
        emit(
          state.copyWith(
            categoryTracks: appended,
            isLoadingMoreCategoryTracks: false,
            hasMoreCategoryTracks: page.hasMore,
            categoryNextOffset: page.nextOffset,
          ),
        );
      },
      failure: (_) => emit(state.copyWith(isLoadingMoreCategoryTracks: false)),
    );
  }

  void clearSelectedGenre() {
    emit(state.copyWith(clearSelectedGenre: true));
  }

  Future<void> clearRecentSearches() async {
    await _storage.clearRecentSearches();
    emit(state.copyWith(recentSearches: const []));
  }

  @override
  Future<void> close() {
    _debouncer.dispose();
    return super.close();
  }
}
