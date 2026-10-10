import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../core/storage/local_storage_service.dart';
import 'splash_state.dart';

/// Decides where the app lands on cold start: sign in, "pick your
/// singers" onboarding, or straight into the main app — purely by reading
/// local session state, no network call needed.
class SplashCubit extends Cubit<SplashState> {
  SplashCubit({AuthRepository? authRepository, LocalStorageService? storage})
      : _auth = authRepository ?? getIt<AuthRepository>(),
        _storage = storage ?? getIt<LocalStorageService>(),
        super(const SplashState());

  final AuthRepository _auth;
  final LocalStorageService _storage;

  Future<void> checkStatus() async {
    // A short, deliberate pause so the splash brand moment doesn't just
    // flash by instantly on a fast device.
    await Future<void>.delayed(const Duration(milliseconds: 900));

    final user = _auth.currentUser;
    if (user == null) {
      emit(const SplashState(destination: SplashDestination.unauthenticated));
      return;
    }

    if (!_storage.hasSelectedSingers) {
      emit(const SplashState(destination: SplashDestination.needsArtistSelection));
      return;
    }

    emit(const SplashState(destination: SplashDestination.authenticated));
  }
}
