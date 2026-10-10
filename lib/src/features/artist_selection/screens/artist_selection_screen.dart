import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/artist_model.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/toast_util.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/artist_avatar.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/shimmer_widgets.dart';
import '../../../core/widgets/state_views.dart';
import '../cubit/artist_selection_cubit.dart';
import '../cubit/artist_selection_state.dart';
import '../widgets/selection_progress_banner.dart';

class ArtistSelectionScreen extends StatelessWidget {
  const ArtistSelectionScreen({super.key, this.isEditing = false});

  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ArtistSelectionCubit(isEditing: isEditing),
      child: _ArtistSelectionView(isEditing: isEditing),
    );
  }
}

class _ArtistSelectionView extends StatefulWidget {
  const _ArtistSelectionView({required this.isEditing});

  final bool isEditing;

  @override
  State<_ArtistSelectionView> createState() => _ArtistSelectionViewState();
}

class _ArtistSelectionViewState extends State<_ArtistSelectionView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ArtistSelectionCubit, ArtistSelectionState>(
      listener: (context, state) {
        if (state.isDone) {
          if (widget.isEditing) {
            ToastUtil.success(context, 'Your artists have been updated.');
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pushNamedAndRemoveUntil(RouteNames.splash, (_) => false);
          }
        }
      },
      builder: (context, state) {
        final cubit = context.read<ArtistSelectionCubit>();
        final displayedArtists = state.isSearching ? state.searchResults : state.popularArtists;

        return Scaffold(
          appBar: widget.isEditing ? AppBar(title: const Text('Edit your artists')) : null,
          body: SafeArea(
            child: Column(
              children: [
                if (!widget.isEditing) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pick your singers', style: AppTextStyles.displayTitle),
                        const SizedBox(height: 6),
                        Text(
                          "We'll build your Home screen around the artists you love.",
                          style: AppTextStyles.bodyMuted,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AppTextField(
                    controller: _searchController,
                    hintText: 'Search for an artist',
                    prefixIcon: Icons.search,
                    onChanged: cubit.onSearchChanged,
                  ),
                ),
                SelectionProgressBanner(selectedCount: state.selectedCount),
                Expanded(child: _buildBody(state, cubit, displayedArtists)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: AppPrimaryButton(
                    label: widget.isEditing ? 'Save changes' : 'Continue',
                    enabled: state.canContinue,
                    isLoading: state.isSubmitting,
                    onPressed: state.canContinue ? cubit.submit : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    ArtistSelectionState state,
    ArtistSelectionCubit cubit,
    List<Artist> displayedArtists,
  ) {
    if (state.isLoading) {
      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 14,
          crossAxisSpacing: 8,
          childAspectRatio: 0.74,
        ),
        itemCount: 9,
        itemBuilder: (_, __) => const ArtistAvatarShimmer(size: 104),
      );
    }

    if (state.error != null && displayedArtists.isEmpty) {
      return ErrorView(message: state.error!, onRetry: cubit.retry);
    }

    if (displayedArtists.isEmpty) {
      return const EmptyView(
        message: 'No artists found',
        subtitle: 'Try searching for a different name.',
        icon: Icons.person_search_rounded,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 14,
        crossAxisSpacing: 8,
        childAspectRatio: 0.74,
      ),
      itemCount: displayedArtists.length,
      itemBuilder: (context, index) {
        final artist = displayedArtists[index];
        return ArtistAvatar(
          artist: artist,
          size: 104,
          selected: state.isSelected(artist.id),
          onTap: () => cubit.toggleArtist(artist),
        );
      },
    );
  }
}
