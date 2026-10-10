import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/models/track_model.dart';
import '../../../core/repositories/playlist_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/shimmer_widgets.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/track_tile.dart';
import '../../player/cubit/player_cubit.dart';
import '../../playlists/widgets/add_to_playlist_sheet.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import '../widgets/genre_chip_grid.dart';
import '../widgets/search_results_list.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _categoryScrollController = ScrollController();
  final PlaylistRepository _playlistRepository = getIt<PlaylistRepository>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onSearchScroll);
    _categoryScrollController.addListener(_onCategoryScroll);
  }

  void _onSearchScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 300;
    if (_scrollController.position.pixels >= threshold) {
      context.read<SearchCubit>().loadMore();
    }
  }

  void _onCategoryScroll() {
    if (!_categoryScrollController.hasClients) return;
    final threshold = _categoryScrollController.position.maxScrollExtent - 300;
    if (_categoryScrollController.position.pixels >= threshold) {
      context.read<SearchCubit>().loadMoreCategoryTracks();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onSearchScroll);
    _scrollController.dispose();
    _categoryScrollController.removeListener(_onCategoryScroll);
    _categoryScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _toggleLike(Track track) async {
    await _playlistRepository.toggleLiked(track);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        final cubit = context.read<SearchCubit>();
        return Scaffold(
          appBar: AppBar(title: const Text('Search')),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AppTextField(
                    controller: _searchController,
                    hintText: 'Artists, songs, albums...',
                    prefixIcon: Icons.search,
                    onChanged: cubit.onQueryChanged,
                    textInputAction: TextInputAction.search,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(child: _buildBody(context, state, cubit)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SearchState state, SearchCubit cubit) {
    if (state.selectedGenre != null && !state.hasQuery) {
      return _buildCategorySongsView(context, state, cubit);
    }

    if (state.isBrowsing) {
      return _buildBrowse(context, state, cubit);
    }

    if (state.isSearching) {
      return ListView.builder(
        itemCount: 6,
        itemBuilder: (_, __) => const TrackTileShimmer(),
      );
    }

    if (state.error != null) {
      return ErrorView(message: state.error!, onRetry: () => cubit.runSearch(state.query));
    }

    if (state.results.isEmpty) {
      return const EmptyView(
        message: 'No results found',
        subtitle: 'Try a different artist, song, or spelling.',
        icon: Icons.search_off_rounded,
      );
    }

    return SearchResultsList(
      controller: _scrollController,
      tracks: state.results,
      isLoadingMore: state.isLoadingMore,
      isLiked: (id) => _playlistRepository.isLiked(id),
      onToggleLike: _toggleLike,
      onMore: (track) => AddToPlaylistSheet.show(context, track),
      onTrackTap: (index) => context.read<PlayerCubit>().playQueue(state.results, index),
    );
  }

  Widget _buildBrowse(BuildContext context, SearchState state, SearchCubit cubit) {
    return ListView(
      children: [
        if (state.recentSearches.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent searches', style: AppTextStyles.sectionTitle),
                GestureDetector(
                  onTap: cubit.clearRecentSearches,
                  child: Text('Clear', style: AppTextStyles.link),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.recentSearches.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final query = state.recentSearches[index];
                return ActionChip(
                  label: Text(query, style: AppTextStyles.bodyMuted),
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(color: AppColors.surfaceBorder),
                  onPressed: () {
                    _searchController.text = query;
                    cubit.searchNow(query);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
        const SectionHeader(title: 'Browse Categories'),
        if (state.isLoadingGenres)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: AppLoader(),
          )
        else
          GenreChipGrid(
            genres: state.genres,
            selectedGenreId: state.selectedGenre?.id,
            onTap: cubit.selectGenre,
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Vertical GridView for Category Songs with Category Name header and infinite scroll
  Widget _buildCategorySongsView(BuildContext context, SearchState state, SearchCubit cubit) {
    final genreName = state.selectedGenre!.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 16, 12),
          child: Row(
            children: [
              IconButton(
                onPressed: cubit.clearSelectedGenre,
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '$genreName Songs',
                  style: AppTextStyles.screenTitle.copyWith(fontSize: 22),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: state.isLoadingCategoryTracks
              ? GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: 6,
                  itemBuilder: (_, __) => const TrackCardShimmer(width: double.infinity),
                )
              : state.categoryTracks.isEmpty
                  ? EmptyView(message: 'No songs found in $genreName.')
                  : GridView.builder(
                      controller: _categoryScrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: state.categoryTracks.length + (state.isLoadingMoreCategoryTracks ? 2 : 0),
                      itemBuilder: (context, index) {
                        if (index >= state.categoryTracks.length) {
                          return const Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(color: AppColors.cyanAccent, strokeWidth: 2.4),
                            ),
                          );
                        }
                        final track = state.categoryTracks[index];
                        return TrackCard(
                          track: track,
                          width: double.infinity,
                          onTap: () => context.read<PlayerCubit>().playQueue(state.categoryTracks, index),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
