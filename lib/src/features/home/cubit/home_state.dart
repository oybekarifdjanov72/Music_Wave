import 'package:equatable/equatable.dart';

import '../../../core/models/artist_model.dart';
import '../../../core/models/track_model.dart';

class HomeState extends Equatable {
  const HomeState({
    this.isPopularLoading = true,
    this.isMadeForYouLoading = true,
    this.isBestForTodayLoading = true,
    this.isPopularLoadingMore = false,
    this.isMadeForYouLoadingMore = false,
    this.isBestForTodayLoadingMore = false,
    this.popularNextOffset = 12,
    this.madeForYouArtistIndex = 6,
    this.popularError,
    this.madeForYouError,
    this.userName,
    this.yourArtists = const [],
    this.madeForYou = const [],
    this.popularRightNow = const [],
    this.bestForToday = const [],
    this.recentlyPlayed = const [],
  });

  final bool isPopularLoading;
  final bool isMadeForYouLoading;
  final bool isBestForTodayLoading;

  final bool isPopularLoadingMore;
  final bool isMadeForYouLoadingMore;
  final bool isBestForTodayLoadingMore;
  final int popularNextOffset;
  final int madeForYouArtistIndex;

  final String? popularError;
  final String? madeForYouError;
  final String? userName;

  final List<Artist> yourArtists;
  final List<Track> madeForYou;
  final List<Track> popularRightNow;
  final List<Track> bestForToday;
  final List<Track> recentlyPlayed;

  HomeState copyWith({
    bool? isPopularLoading,
    bool? isMadeForYouLoading,
    bool? isBestForTodayLoading,
    bool? isPopularLoadingMore,
    bool? isMadeForYouLoadingMore,
    bool? isBestForTodayLoadingMore,
    int? popularNextOffset,
    int? madeForYouArtistIndex,
    String? popularError,
    String? madeForYouError,
    String? userName,
    List<Artist>? yourArtists,
    List<Track>? madeForYou,
    List<Track>? popularRightNow,
    List<Track>? bestForToday,
    List<Track>? recentlyPlayed,
  }) {
    return HomeState(
      isPopularLoading: isPopularLoading ?? this.isPopularLoading,
      isMadeForYouLoading: isMadeForYouLoading ?? this.isMadeForYouLoading,
      isBestForTodayLoading: isBestForTodayLoading ?? this.isBestForTodayLoading,
      isPopularLoadingMore: isPopularLoadingMore ?? this.isPopularLoadingMore,
      isMadeForYouLoadingMore: isMadeForYouLoadingMore ?? this.isMadeForYouLoadingMore,
      isBestForTodayLoadingMore: isBestForTodayLoadingMore ?? this.isBestForTodayLoadingMore,
      popularNextOffset: popularNextOffset ?? this.popularNextOffset,
      madeForYouArtistIndex: madeForYouArtistIndex ?? this.madeForYouArtistIndex,
      popularError: popularError,
      madeForYouError: madeForYouError,
      userName: userName ?? this.userName,
      yourArtists: yourArtists ?? this.yourArtists,
      madeForYou: madeForYou ?? this.madeForYou,
      popularRightNow: popularRightNow ?? this.popularRightNow,
      bestForToday: bestForToday ?? this.bestForToday,
      recentlyPlayed: recentlyPlayed ?? this.recentlyPlayed,
    );
  }

  @override
  List<Object?> get props => [
        isPopularLoading,
        isMadeForYouLoading,
        isBestForTodayLoading,
        isPopularLoadingMore,
        isMadeForYouLoadingMore,
        isBestForTodayLoadingMore,
        popularNextOffset,
        madeForYouArtistIndex,
        popularError,
        madeForYouError,
        userName,
        yourArtists,
        madeForYou,
        popularRightNow,
        bestForToday,
        recentlyPlayed,
      ];
}
