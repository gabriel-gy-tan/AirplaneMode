import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'state/settings_controller.dart';
import 'theme/app_theme.dart';
import 'theme/backgrounds.dart';

class AirplaneModeApp extends StatelessWidget {
  const AirplaneModeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    return MaterialApp(
      title: 'AirplaneMode',
      debugShowCheckedModeBanner: false,
      theme: switch (settings.theme) {
        AppThemeName.aero => AppTheme.aero(),
        AppThemeName.phantom => AppTheme.phantom(),
        AppThemeName.persona3 => AppTheme.persona3(),
      },
      themeAnimationDuration: settings.reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 400),
      themeAnimationCurve: Curves.easeInOut,
      home: const _HomeShell(),
    );
  }
}

class _HomeShell extends StatelessWidget {
  const _HomeShell();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned.fill(child: AppBackground()),
        HomeScreen(),
      ],
    );
  }
}
