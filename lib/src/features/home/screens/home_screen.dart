import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/models/artist_model.dart';
import '../../../core/models/track_model.dart';
import '../../../core/network/result.dart';
import '../../../core/repositories/music_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/shimmer_widgets.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/track_tile.dart';
import '../../player/cubit/player_cubit.dart';
import '../../playlists/cubit/playlists_cubit.dart';
import '../../playlists/widgets/add_to_playlist_sheet.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/artist_chip_row.dart';
import '../widgets/track_horizontal_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting(String? userName) {
    final hour = DateTime.now().hour;
    final base = hour < 12
        ? 'Good morning'
        : hour < 18
            ? 'Good afternoon'
            : 'Good evening';
    final name = userName?.trim();
    if (name == null || name.isEmpty) return base;
    return '$base, $name';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final cubit = context.read<HomeCubit>();

        return Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              color: AppColors.cyanAccent,
              backgroundColor: AppColors.surface,
              onRefresh: cubit.refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  // Greeting header renders instantly on frame 1
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Text(_greeting(state.userName), style: AppTextStyles.displayTitle),
                  ),

                  // Your Artists (local persistence) renders instantly on frame 1
                  if (state.yourArtists.isNotEmpty) ...[
                    const SectionHeader(title: 'Your Artists'),
                    ArtistChipRow(
                      artists: state.yourArtists,
                      onArtistTap: (artist) => _openArtistSheet(context, artist),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Best For Today section with targeted shimmer and horizontal scroll pagination
                  const SectionHeader(title: 'Best For Today'),
                  state.isBestForTodayLoading
                      ? const SectionShimmerRow()
                      : state.bestForToday.isEmpty
                          ? const _SectionEmpty(message: 'Nothing to show yet — try refreshing.')
                          : TrackHorizontalList(
                              tracks: state.bestForToday,
                              onTrackTap: (i) => _play(context, state.bestForToday, i),
                              onLoadMore: cubit.loadMoreBestForToday,
                              isLoadingMore: state.isBestForTodayLoadingMore,
                            ),
                  const SizedBox(height: 24),

                  // Popular Right Now section with targeted shimmer and horizontal scroll pagination
                  const SectionHeader(title: 'Popular Right Now'),
                  state.isPopularLoading
                      ? const SectionShimmerRow()
                      : state.popularRightNow.isEmpty
                          ? const _SectionEmpty(message: 'Charts are unavailable right now.')
                          : TrackHorizontalList(
                              tracks: state.popularRightNow,
                              onTrackTap: (i) => _play(context, state.popularRightNow, i),
                              onLoadMore: cubit.loadMorePopular,
                              isLoadingMore: state.isPopularLoadingMore,
                            ),
                  const SizedBox(height: 24),

                  // Made For You section with targeted shimmer and horizontal scroll pagination
                  if (state.madeForYou.isNotEmpty || state.isMadeForYouLoading) ...[
                    const SectionHeader(title: 'Made For You'),
                    state.isMadeForYouLoading
                        ? const SectionShimmerRow()
                        : TrackHorizontalList(
                            tracks: state.madeForYou,
                            onTrackTap: (i) => _play(context, state.madeForYou, i),
                            onLoadMore: cubit.loadMoreMadeForYou,
                            isLoadingMore: state.isMadeForYouLoadingMore,
                          ),
                    const SizedBox(height: 24),
                  ],

                  // Recently Played (local persistence) renders instantly on frame 1
                  if (state.recentlyPlayed.isNotEmpty) ...[
                    const SectionHeader(title: 'Recently Played'),
                    ...state.recentlyPlayed.take(5).map(
                          (track) => TrackTile(
                            track: track,
                            onTap: () => _play(
                              context,
                              state.recentlyPlayed,
                              state.recentlyPlayed.indexOf(track),
                            ),
                            isLiked: context.watch<PlaylistsCubit>().isLiked(track.id),
                            onToggleLike: () => context.read<PlaylistsCubit>().toggleLiked(track),
                            onMore: () => AddToPlaylistSheet.show(context, track),
                          ),
                        ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _play(BuildContext context, List<Track> queue, int index) {
    context.read<PlayerCubit>().playQueue(queue, index);
  }

  void _openArtistSheet(BuildContext context, Artist artist) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => _ArtistTopTracksSheet(artist: artist),
    );
  }
}

class _SectionEmpty extends StatelessWidget {
  const _SectionEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(message, style: AppTextStyles.bodyMuted),
    );
  }
}

/// Small bottom sheet showing an artist's top tracks — opened by tapping
/// one of "Your Artists" on Home.
class _ArtistTopTracksSheet extends StatefulWidget {
  const _ArtistTopTracksSheet({required this.artist});

  final Artist artist;

  @override
  State<_ArtistTopTracksSheet> createState() => _ArtistTopTracksSheetState();
}

class _ArtistTopTracksSheetState extends State<_ArtistTopTracksSheet> {
  final MusicRepository _repository = getIt<MusicRepository>();
  List<Track>? _tracks;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cleanId = widget.artist.id.replaceAll('deezer_', '');
    var result = await _repository.getArtistTopTracks(artistId: cleanId, limit: 15);

    // If fetching by artist ID fails or returns empty, search by artist name so
    // artists like Madonna or HONNE always show their real top tracks!
    if (result.isFailure || (result.dataOrNull?.isEmpty ?? true)) {
      final searchResult = await _repository.searchTracks(query: widget.artist.name, limit: 15);
      if (searchResult.isSuccess && (searchResult.dataOrNull?.items.isNotEmpty ?? false)) {
        result = Result.success(searchResult.dataOrNull!.items);
      }
    }

    if (!mounted) return;
    result.when(
      success: (tracks) => setState(() => _tracks = tracks),
      failure: (failure) => setState(() => _error = failure.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Top tracks · ${widget.artist.name}', style: AppTextStyles.sectionTitle),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _error != null
                  ? ErrorView(message: _error!, onRetry: _load)
                  : _tracks == null
                      ? ListView.builder(
                          controller: scrollController,
                          itemCount: 6,
                          itemBuilder: (_, __) => const TrackTileShimmer(),
                        )
                      : _tracks!.isEmpty
                          ? const EmptyView(message: 'No tracks found for this artist.')
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: _tracks!.length,
                              itemBuilder: (context, index) {
                                return TrackTile(
                                  track: _tracks![index],
                                  onTap: () => context.read<PlayerCubit>().playQueue(_tracks!, index),
                                );
                              },
                            ),
            ),
          ],
        );
      },
    );
  }
}
