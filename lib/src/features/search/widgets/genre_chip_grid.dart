import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/models/genre_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_text_styles.dart';

/// Grid of category/genre cards used to browse when there's no search
/// query yet — tapping one filters by that genre (see [SearchCubit.selectGenre]).
class GenreChipGrid extends StatelessWidget {
  const GenreChipGrid({
    super.key,
    required this.genres,
    required this.selectedGenreId,
    required this.onTap,
  });

  final List<Genre> genres;
  final String? selectedGenreId;
  final void Function(Genre genre) onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.7,
      ),
      itemCount: genres.length,
      itemBuilder: (context, index) {
        final genre = genres[index];
        final selected = genre.id == selectedGenreId;
        return GestureDetector(
          onTap: () => onTap(genre),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.surface,
              border: Border.all(
                color: selected ? AppColors.cyanAccent : AppColors.surfaceBorder,
                width: selected ? 1.6 : 1,
              ),
              boxShadow: selected ? AppShadows.neonGlow(blur: 12, opacity: 0.3) : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (genre.pictureUrl.isNotEmpty)
                  Opacity(
                    opacity: 0.35,
                    child: CachedNetworkImage(imageUrl: genre.pictureUrl, fit: BoxFit.cover),
                  ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.transparent, Colors.black54],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      genre.name,
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
