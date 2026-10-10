import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'firebase_options.dart';
import 'src/app.dart';
import 'src/core/di/service_locator.dart';
import 'src/features/player/cubit/player_cubit.dart';
import 'src/features/playlists/cubit/playlists_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupServiceLocator();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => PlayerCubit()),
        BlocProvider(create: (_) => PlaylistsCubit()),
      ],
      child: const NeonWaveApp(),
    ),
  );
}
