import 'package:flutter/material.dart';

import '../../../core/models/track_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/track_tile.dart';

/// A horizontal, snap-scrolling row of [TrackCard]s with infinite scroll
/// pagination — used by every Home section ("Popular Right Now", "Made For You"...).
class TrackHorizontalList extends StatefulWidget {
  const TrackHorizontalList({
    super.key,
    required this.tracks,
    required this.onTrackTap,
    this.onLoadMore,
    this.isLoadingMore = false,
  });

  final List<Track> tracks;
  final void Function(int index) onTrackTap;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;

  @override
  State<TrackHorizontalList> createState() => _TrackHorizontalListState();
}

class _TrackHorizontalListState extends State<TrackHorizontalList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients || widget.onLoadMore == null || widget.isLoadingMore) return;
    final threshold = _scrollController.position.maxScrollExtent - 250;
    if (_scrollController.position.pixels >= threshold) {
      widget.onLoadMore!();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = widget.tracks.length + (widget.isLoadingMore ? 1 : 0);

    return SizedBox(
      height: 210,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: totalCount,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          if (index == widget.tracks.length) {
            return const SizedBox(
              width: 100,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: AppColors.cyanAccent, strokeWidth: 2.4),
                ),
              ),
            );
          }
          return TrackCard(track: widget.tracks[index], onTap: () => widget.onTrackTap(index));
        },
      ),
    );
  }
}
