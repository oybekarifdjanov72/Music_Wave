import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/models/track_model.dart';
import '../../../core/repositories/music_repository.dart';
import '../../../core/repositories/music_repository_impl.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/utils/date_seed_shuffle.dart';
import 'home_state.dart';

/// Builds every Home section independently. Local data (Your Artists,
/// Recently Played) is emitted immediately so the screen renders instantly,
/// while individual network sections show localized shimmer placeholders
/// and support horizontal infinite scrolling.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit({MusicRepository? musicRepository, LocalStorageService? storage})
      : _repository = musicRepository ?? getIt<MusicRepository>(),
        _storage = storage ?? getIt<LocalStorageService>(),
        super(HomeState(
          userName: (storage ?? getIt<LocalStorageService>()).getCurrentUser()?.fullName,
          yourArtists: (storage ?? getIt<LocalStorageService>()).getChosenArtists(),
          recentlyPlayed: (storage ?? getIt<LocalStorageService>()).getRecentlyPlayed(),
        )) {
    load();
  }

  final MusicRepository _repository;
  final LocalStorageService _storage;

  Future<void> load() async {
    // 1. Refresh local persistent data immediately (frame 1)
    final artists = _storage.getChosenArtists();
    final recentlyPlayed = _storage.getRecentlyPlayed();
    final userName = _storage.getCurrentUser()?.fullName;

    emit(state.copyWith(
      userName: userName,
      yourArtists: artists,
      recentlyPlayed: recentlyPlayed,
      isPopularLoading: true,
      isMadeForYouLoading: true,
      isBestForTodayLoading: true,
      popularError: null,
      madeForYouError: null,
    ));

    // 2. Asynchronously fetch popular chart tracks & artist top tracks
    final chartFuture = _repository.getChartTracks(limit: AppConstants.homeSectionLimit);

    final madeForYou = <Track>[];
    for (final artist in artists.take(6)) {
      final result = await _repository.getArtistTopTracks(artistId: artist.id, limit: 5);
      final tracks = result.dataOrNull ?? const [];
      madeForYou.addAll(tracks);
      if (madeForYou.length >= AppConstants.homeSectionLimit) break;
    }

    final chartResult = await chartFuture;
    final popularRightNow = (chartResult.dataOrNull?.isNotEmpty ?? false)
        ? chartResult.dataOrNull!
        : MusicRepositoryImpl.fallbackTracks;

    if (madeForYou.isEmpty && popularRightNow.isNotEmpty) {
      madeForYou.addAll(popularRightNow.take(AppConstants.homeSectionLimit));
    }

    final combinedForToday = <String, Track>{};
    for (final t in [...madeForYou, ...popularRightNow]) {
      combinedForToday[t.id] = t;
    }
    final bestForToday =
        shuffleForToday(combinedForToday.values.toList()).take(AppConstants.homeSectionLimit).toList();

    emit(state.copyWith(
      isPopularLoading: false,
      isMadeForYouLoading: false,
      isBestForTodayLoading: false,
      popularRightNow: popularRightNow,
      madeForYou: madeForYou.take(AppConstants.homeSectionLimit).toList(),
      bestForToday: bestForToday,
    ));
  }

  /// Horizontal Pagination: Loads more popular chart songs when scrolling right.
  Future<void> loadMorePopular() async {
    if (state.isPopularLoadingMore) return;
    emit(state.copyWith(isPopularLoadingMore: true));

    final result = await _repository.searchTracks(
      query: 'top charts pop hip hop rock',
      offset: state.popularNextOffset,
      limit: 10,
    );

    result.when(
      success: (page) {
        final seen = state.popularRightNow.map((t) => t.id).toSet();
        final appended = [...state.popularRightNow, ...page.items.where((t) => seen.add(t.id))];
        emit(state.copyWith(
          popularRightNow: appended,
          popularNextOffset: state.popularNextOffset + 10,
          isPopularLoadingMore: false,
        ));
      },
      failure: (_) => emit(state.copyWith(isPopularLoadingMore: false)),
    );
  }

  /// Horizontal Pagination: Loads more artist tracks then appends recommended music.
  Future<void> loadMoreMadeForYou() async {
    if (state.isMadeForYouLoadingMore) return;
    emit(state.copyWith(isMadeForYouLoadingMore: true));

    final artists = state.yourArtists;
    final newTracks = <Track>[];

    if (state.madeForYouArtistIndex < artists.length) {
      final nextBatch = artists.skip(state.madeForYouArtistIndex).take(3);
      for (final artist in nextBatch) {
        final res = await _repository.getArtistTopTracks(artistId: artist.id, limit: 5);
        newTracks.addAll(res.dataOrNull ?? const []);
      }
    }

    if (newTracks.isEmpty) {
      final searchResult = await _repository.searchTracks(
        query: 'popular music hits',
        offset: state.madeForYou.length,
        limit: 10,
      );
      newTracks.addAll(searchResult.dataOrNull?.items ?? const []);
    }

    final seen = state.madeForYou.map((t) => t.id).toSet();
    final appended = [...state.madeForYou, ...newTracks.where((t) => seen.add(t.id))];

    emit(state.copyWith(
      madeForYou: appended,
      madeForYouArtistIndex: state.madeForYouArtistIndex + 3,
      isMadeForYouLoadingMore: false,
    ));
  }

  /// Horizontal Pagination: Loads more mix tracks for "Best For Today".
  Future<void> loadMoreBestForToday() async {
    if (state.isBestForTodayLoadingMore) return;
    emit(state.copyWith(isBestForTodayLoadingMore: true));

    final result = await _repository.searchTracks(
      query: 'best song hits of today',
      offset: state.bestForToday.length,
      limit: 10,
    );

    result.when(
      success: (page) {
        final seen = state.bestForToday.map((t) => t.id).toSet();
        final appended = [...state.bestForToday, ...page.items.where((t) => seen.add(t.id))];
        emit(state.copyWith(
          bestForToday: appended,
          isBestForTodayLoadingMore: false,
        ));
      },
      failure: (_) => emit(state.copyWith(isBestForTodayLoadingMore: false)),
    );
  }

  Future<void> refresh() => load();
}
