import 'package:flutter/material.dart';

import '../../../core/models/artist_model.dart';
import '../../../core/widgets/artist_avatar.dart';

/// Row of the artists picked at onboarding — tapping one jumps into their
/// top tracks (handled by the parent via [onArtistTap]).
class ArtistChipRow extends StatelessWidget {
  const ArtistChipRow({super.key, required this.artists, required this.onArtistTap});

  final List<Artist> artists;
  final void Function(Artist artist) onArtistTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: artists.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final artist = artists[index];
          return ArtistAvatar(artist: artist, size: 72, onTap: () => onArtistTap(artist));
        },
      ),
    );
  }
}
