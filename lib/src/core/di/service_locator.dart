import 'package:get_it/get_it.dart';

import '../audio/audio_player_service.dart';
import '../repositories/auth_repository.dart';
import '../repositories/music_repository.dart';
import '../repositories/music_repository_impl.dart';
import '../repositories/playlist_repository.dart';
import '../services/deezer_service.dart';
import '../services/itunes_service.dart';
import '../storage/local_storage_service.dart';

/// One place that wires the whole dependency graph together. Every cubit
/// still takes its dependencies through its constructor (so tests can pass
/// fakes/mocks directly) — this locator only exists so `main.dart` and
/// `BlocProvider`s don't have to construct that graph by hand.
final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  final storage = await LocalStorageService.create();
  getIt.registerSingleton<LocalStorageService>(storage);

  getIt.registerLazySingleton<DeezerService>(() => DeezerService());
  getIt.registerLazySingleton<ItunesService>(() => ItunesService());

  getIt.registerLazySingleton<MusicRepository>(
    () => MusicRepositoryImpl(
      deezerService: getIt<DeezerService>(),
      itunesService: getIt<ItunesService>(),
    ),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => FirebaseAuthRepository(),
  );

  getIt.registerLazySingleton<PlaylistRepository>(
    () => LocalPlaylistRepository(storage: getIt<LocalStorageService>()),
  );

  getIt.registerLazySingleton<AudioPlayerService>(() => AudioPlayerService());
}
