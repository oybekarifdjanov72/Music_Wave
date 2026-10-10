import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/models/artist_model.dart';
import '../../../core/repositories/music_repository.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/utils/debouncer.dart';
import 'artist_selection_state.dart';

/// Powers onboarding's "pick 3 or more singers" step (and, in edit mode,
/// Profile's "update your artists" screen). The chosen artists are what
/// the Home screen's "Made For You" section is built from.
class ArtistSelectionCubit extends Cubit<ArtistSelectionState> {
  ArtistSelectionCubit({
    MusicRepository? musicRepository,
    LocalStorageService? storage,
    bool isEditing = false,
  })  : _repository = musicRepository ?? getIt<MusicRepository>(),
        _storage = storage ?? getIt<LocalStorageService>(),
        _isEditing = isEditing,
        super(const ArtistSelectionState()) {
    _load();
  }

  final MusicRepository _repository;
  final LocalStorageService _storage;
  final bool _isEditing;
  final Debouncer _debouncer = Debouncer();

  Future<void> _load() async {
    emit(state.copyWith(isLoading: true, error: null));

    final preselected = _isEditing
        ? {for (final a in _storage.getChosenArtists()) a.id: a}
        : <String, Artist>{};

    final result = await _repository.getPopularArtists(limit: 40);
    result.when(
      success: (artists) => emit(
        state.copyWith(
          isLoading: false,
          popularArtists: artists,
          selectedArtists: preselected,
        ),
      ),
      failure: (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
    );
  }

  void retry() => _load();

  void onSearchChanged(String query) {
    emit(state.copyWith(searchQuery: query));
    _debouncer.run(() => _search(query));
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      emit(state.copyWith(searchResults: const []));
      return;
    }
    final result = await _repository.searchArtists(query: query.trim());
    result.when(
      success: (artists) => emit(state.copyWith(searchResults: artists)),
      failure: (_) => emit(state.copyWith(searchResults: const [])),
    );
  }

  void toggleArtist(Artist artist) {
    final updated = Map<String, Artist>.from(state.selectedArtists);
    if (updated.containsKey(artist.id)) {
      updated.remove(artist.id);
    } else {
      updated[artist.id] = artist;
    }
    emit(state.copyWith(selectedArtists: updated));
  }

  Future<void> submit() async {
    if (!state.canContinue) return;
    emit(state.copyWith(isSubmitting: true));
    await _storage.saveChosenArtists(state.selectedArtists.values.toList());
    emit(state.copyWith(isSubmitting: false, isDone: true));
  }

  @override
  Future<void> close() {
    _debouncer.dispose();
    return super.close();
  }
}
