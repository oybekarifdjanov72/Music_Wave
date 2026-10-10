import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../home/cubit/home_cubit.dart';
import '../../home/screens/home_screen.dart';
import '../../player/widgets/mini_player_bar.dart';
import '../../playlists/screens/playlists_screen.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../../profile/screens/profile_screen.dart';
import '../../search/cubit/search_cubit.dart';
import '../../search/screens/search_screen.dart';
import '../cubit/nav_cubit.dart';
import '../widgets/neon_bottom_nav_bar.dart';

/// Hosts the 4 bottom-nav tabs in an [IndexedStack] (so switching tabs
/// never rebuilds/loses their state) plus the persistent mini player.
/// [PlayerCubit] and [PlaylistsCubit] are provided above this screen (see
/// `main.dart`) since pushed routes/sheets need them too; the per-tab
/// cubits below only need to live as long as this screen does.
class MainNavScreen extends StatelessWidget {
  const MainNavScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomeCubit()),
        BlocProvider(create: (_) => SearchCubit()),
        BlocProvider(create: (_) => ProfileCubit()),
        BlocProvider(create: (_) => NavCubit()),
      ],
      child: const _MainNavBody(),
    );
  }
}

class _MainNavBody extends StatelessWidget {
  const _MainNavBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavCubit, int>(
      builder: (context, index) {
        return Scaffold(
          body: IndexedStack(
            index: index,
            children: const [
              HomeScreen(),
              SearchScreen(),
              PlaylistsScreen(),
              ProfileScreen(),
            ],
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MiniPlayerBar(),
              NeonBottomNavBar(
                currentIndex: index,
                onTap: (i) => context.read<NavCubit>().changeTab(i),
              ),
            ],
          ),
        );
      },
    );
  }
}
