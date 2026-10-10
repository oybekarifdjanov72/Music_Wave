import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_text_styles.dart';
import '../cubit/splash_cubit.dart';
import '../cubit/splash_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SplashCubit()..checkStatus(),
      child: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          switch (state.destination) {
            case SplashDestination.checking:
              break;
            case SplashDestination.unauthenticated:
              Navigator.of(context).pushReplacementNamed(RouteNames.login);
            case SplashDestination.needsArtistSelection:
              Navigator.of(context).pushReplacementNamed(RouteNames.artistSelection);
            case SplashDestination.authenticated:
              Navigator.of(context).pushReplacementNamed(RouteNames.mainNav);
          }
        },
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppShadows.neonGlow(blur: 30, opacity: 0.55),
                      border: Border.all(color: AppColors.cyanAccent, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.asset(
                        'assets/icons/music_wave_logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppConstants.appName,
                    style: AppTextStyles.displayTitle.copyWith(
                      shadows: AppShadows.neonTextGlow(blur: 12),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(color: AppColors.cyanAccent, strokeWidth: 2.4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
