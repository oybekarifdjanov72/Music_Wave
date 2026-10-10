import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../core/storage/local_storage_service.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    AuthRepository? authRepository,
    LocalStorageService? storage,
    ImagePicker? imagePicker,
  })  : _auth = authRepository ?? getIt<AuthRepository>(),
        _storage = storage ?? getIt<LocalStorageService>(),
        _picker = imagePicker ?? ImagePicker(),
        super(const ProfileState()) {
    refresh();
  }

  final AuthRepository _auth;
  final LocalStorageService _storage;
  final ImagePicker _picker;

  void refresh() {
    emit(
      state.copyWith(
        user: _auth.currentUser,
        chosenArtists: _storage.getChosenArtists(),
        profileImagePath: _storage.getProfileImagePath(),
      ),
    );
  }

  Future<void> pickAndSaveAvatar() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file == null) return;

      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        final base64String = 'data:image/png;base64,${base64Encode(bytes)}';
        await _storage.saveProfileImagePath(base64String);
        emit(state.copyWith(profileImagePath: base64String));
      } else {
        final savedPath = await _storage.persistProfileImage(file.path);
        emit(state.copyWith(profileImagePath: savedPath));
      }
    } catch (_) {
      // Non-blocking catch
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    emit(state.copyWith(isSignedOut: true));
  }
}
