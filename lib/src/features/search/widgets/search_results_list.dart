import 'package:flutter/material.dart';

import '../../../core/models/track_model.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/track_tile.dart';

/// Paginated results list. [controller] should be watched by the parent
/// to trigger [onLoadMore] near the bottom — kept dumb here on purpose so
/// the scroll-position logic lives in one place (the screen).
class SearchResultsList extends StatelessWidget {
  const SearchResultsList({
    super.key,
    required this.controller,
    required this.tracks,
    required this.isLoadingMore,
    required this.onTrackTap,
    required this.isLiked,
    required this.onToggleLike,
    required this.onMore,
  });

  final ScrollController controller;
  final List<Track> tracks;
  final bool isLoadingMore;
  final void Function(int index) onTrackTap;
  final bool Function(String trackId) isLiked;
  final void Function(Track track) onToggleLike;
  final void Function(Track track) onMore;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: tracks.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= tracks.length) return const InlineLoader();
        final track = tracks[index];
        return TrackTile(
          track: track,
          onTap: () => onTrackTap(index),
          isLiked: isLiked(track.id),
          onToggleLike: () => onToggleLike(track),
          onMore: () => onMore(track),
        );
      },
    );
  }
}
