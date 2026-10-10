import 'package:equatable/equatable.dart';

import '../../../core/models/app_user_model.dart';
import '../../../core/models/artist_model.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.user,
    this.chosenArtists = const [],
    this.profileImagePath,
    this.isSignedOut = false,
  });

  final AppUser? user;
  final List<Artist> chosenArtists;
  final String? profileImagePath;
  final bool isSignedOut;

  ProfileState copyWith({
    AppUser? user,
    List<Artist>? chosenArtists,
    String? profileImagePath,
    bool clearProfileImage = false,
    bool? isSignedOut,
  }) {
    return ProfileState(
      user: user ?? this.user,
      chosenArtists: chosenArtists ?? this.chosenArtists,
      profileImagePath: clearProfileImage ? null : (profileImagePath ?? this.profileImagePath),
      isSignedOut: isSignedOut ?? this.isSignedOut,
    );
  }

  @override
  List<Object?> get props => [user, chosenArtists, profileImagePath, isSignedOut];
}
