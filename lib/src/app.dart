import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import 'core/constants/app_constants.dart';
import 'core/routing/app_router.dart';
import 'core/routing/route_names.dart';
import 'core/theme/app_theme.dart';

/// Root widget: dark-only theme, named-route navigation, and the
/// toastification wrapper every [ToastUtil] call needs.
class NeonWaveApp extends StatelessWidget {
  const NeonWaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        initialRoute: RouteNames.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
