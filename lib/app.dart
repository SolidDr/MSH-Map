import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/core/constants/app_strings.dart';
import 'src/core/router/app_router.dart';
import 'src/core/theme/msh_theme.dart';
import 'src/core/providers/theme_provider.dart';
import 'src/core/providers/accessibility_provider.dart';
import 'src/shared/widgets/welcome_overlay.dart';

class MshMapApp extends ConsumerWidget {
  const MshMapApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final accessibilitySettings = ref.watch(accessibilityProvider);

    // Bestimme das Theme basierend auf Modus und Accessibility
    var lightTheme = MshTheme.light;
    var darkTheme = MshTheme.dark;

    if (accessibilitySettings.highContrast) {
      lightTheme = MshTheme.highContrast;
      darkTheme = MshTheme.highContrast;
    }

    return WelcomeOverlay(
      child: MaterialApp.router(
        title: AppStrings.appName,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: _convertAppThemeMode(themeMode),
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          // Wende Accessibility Text Scaling an
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(accessibilitySettings.textScale),
              boldText: accessibilitySettings.boldText,
            ),
            child: child!,
          );
        },
      ),
    );
  }

  ThemeMode _convertAppThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
