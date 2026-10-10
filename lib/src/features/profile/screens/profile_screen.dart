import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/artist_avatar.dart';
import '../../../core/widgets/buttons.dart';
import '../../playlists/cubit/playlists_cubit.dart';
import '../../playlists/cubit/playlists_state.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/profile_stat_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  ImageProvider? _getAvatarImageProvider(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('data:image') || path.length > 500) {
      try {
        final cleanBase64 = path.contains(',') ? path.split(',').last : path;
        final bytes = base64Decode(cleanBase64);
        return MemoryImage(bytes);
      } catch (_) {
        return null;
      }
    }
    if (!kIsWeb && File(path).existsSync()) {
      return FileImage(File(path));
    }
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.isSignedOut) {
          Navigator.of(context).pushNamedAndRemoveUntil(RouteNames.splash, (_) => false);
        }
      },
      builder: (context, state) {
        final user = state.user;
        final playlistsState = context.watch<PlaylistsCubit>().state;
        final likedCount = _likedCount(playlistsState);
        final playlistCount = playlistsState.playlists.where((p) => !p.isLikedSongs).length;
        final imageProvider = _getAvatarImageProvider(state.profileImagePath);

        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => context.read<ProfileCubit>().pickAndSaveAvatar(),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.surface,
                                border: Border.all(color: AppColors.cyanAccent, width: 2),
                                boxShadow: AppShadows.neonGlow(blur: 18, opacity: 0.4),
                                image: imageProvider != null
                                    ? DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: imageProvider != null
                                  ? null
                                  : Center(
                                      child: Text(
                                        _initials(user?.fullName ?? '?'),
                                        style: AppTextStyles.displayTitle.copyWith(
                                          color: AppColors.cyanAccent,
                                          fontSize: 36,
                                        ),
                                      ),
                                    ),
                            ),
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.surfaceElevated,
                                border: Border.all(color: AppColors.cyanAccent, width: 1.2),
                              ),
                              child: const Icon(Icons.camera_alt_rounded, size: 16, color: AppColors.cyanAccent),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(user?.fullName ?? 'Guest', style: AppTextStyles.screenTitle),
                      const SizedBox(height: 4),
                      Text(user?.email ?? '', style: AppTextStyles.bodyMuted),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    ProfileStatCard(value: '$playlistCount', label: 'Playlists', icon: Icons.queue_music_rounded),
                    const SizedBox(width: 12),
                    ProfileStatCard(value: '$likedCount', label: 'Liked Songs', icon: Icons.favorite_rounded),
                    const SizedBox(width: 12),
                    ProfileStatCard(
                      value: '${state.chosenArtists.length}',
                      label: 'Artists',
                      icon: Icons.person_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Your Artists', style: AppTextStyles.sectionTitle),
                    GestureDetector(
                      onTap: () async {
                        await Navigator.of(context).pushNamed(RouteNames.artistSelection, arguments: true);
                        if (context.mounted) context.read<ProfileCubit>().refresh();
                      },
                      child: Text('Edit', style: AppTextStyles.link),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (state.chosenArtists.isEmpty)
                  Text('No artists selected yet.', style: AppTextStyles.bodyMuted)
                else
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.chosenArtists.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, index) => ArtistAvatar(artist: state.chosenArtists[index], size: 68),
                    ),
                  ),
                const SizedBox(height: 36),
                AppSecondaryButton(
                  label: 'Sign Out',
                  onPressed: () => context.read<ProfileCubit>().signOut(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _likedCount(PlaylistsState state) {
    for (final p in state.playlists) {
      if (p.isLikedSongs) return p.tracks.length;
    }
    return 0;
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}
