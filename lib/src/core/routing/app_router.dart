import 'package:flutter/material.dart';

import '../../features/artist_selection/screens/artist_selection_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/main_nav/screens/main_nav_screen.dart';
import '../../features/player/screens/now_playing_screen.dart';
import '../../features/playlists/screens/playlist_detail_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../models/playlist_model.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return _page(const SplashScreen(), settings);
      case RouteNames.login:
        return _page(const LoginScreen(), settings);
      case RouteNames.signUp:
        return _page(const SignUpScreen(), settings);
      case RouteNames.artistSelection:
        final isEditing = (settings.arguments as bool?) ?? false;
        return _page(ArtistSelectionScreen(isEditing: isEditing), settings);
      case RouteNames.mainNav:
        return _page(const MainNavScreen(), settings);
      case RouteNames.playlistDetail:
        final playlist = settings.arguments as Playlist;
        return _page(PlaylistDetailScreen(playlist: playlist), settings);
      case RouteNames.nowPlaying:
        return PageRouteBuilder(
          settings: settings,
          opaque: false,
          barrierColor: Colors.black54,
          pageBuilder: (_, __, ___) => const NowPlayingScreen(),
          transitionsBuilder: (_, animation, __, child) {
            final offset = Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
            return SlideTransition(position: offset, child: child);
          },
        );
      default:
        return _page(
          Scaffold(body: Center(child: Text('No route defined for ${settings.name}'))),
          settings,
        );
    }
  }

  static MaterialPageRoute<dynamic> _page(Widget child, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => child, settings: settings);
  }
}
