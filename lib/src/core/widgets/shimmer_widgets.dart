import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_colors.dart';

/// Every shimmer placeholder used in the app, kept together in one file —
/// each mirrors the exact layout of the real widget it stands in for so
/// there's no layout jump when the data arrives.
class TrackTileShimmer extends StatelessWidget {
  const TrackTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return _shimmer(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            _box(52, 52, radius: 10),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _box(double.infinity, 14),
                  const SizedBox(height: 8),
                  _box(120, 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrackCardShimmer extends StatelessWidget {
  const TrackCardShimmer({super.key, this.width = 140});

  final double width;

  @override
  Widget build(BuildContext context) {
    return _shimmer(
      SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _box(width, width, radius: 12),
            const SizedBox(height: 8),
            _box(width * 0.8, 14),
            const SizedBox(height: 6),
            _box(width * 0.5, 12),
          ],
        ),
      ),
    );
  }
}

class ArtistAvatarShimmer extends StatelessWidget {
  const ArtistAvatarShimmer({super.key, this.size = 104});

  final double size;

  @override
  Widget build(BuildContext context) {
    return _shimmer(
      SizedBox(
        width: size,
        child: Column(
          children: [
            ClipOval(child: _box(size, size)),
            const SizedBox(height: 8),
            _box(size * 0.7, 10),
          ],
        ),
      ),
    );
  }
}

/// A horizontal row of [TrackCardShimmer]s — drop-in replacement for a
/// Home section while it loads.
class SectionShimmerRow extends StatelessWidget {
  const SectionShimmerRow({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, __) => const TrackCardShimmer(),
      ),
    );
  }
}

Widget _shimmer(Widget child) {
  return Shimmer.fromColors(
    baseColor: AppColors.surface,
    highlightColor: AppColors.surfaceElevated,
    child: child,
  );
}

Widget _box(double width, double height, {double radius = 6}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(radius)),
  );
}
