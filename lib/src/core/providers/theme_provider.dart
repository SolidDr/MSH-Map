import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme Mode Provider - verwaltet Dark/Light Mode (Riverpod 3.x)
final themeModeProvider = NotifierProvider<AppThemeModeNotifier, AppThemeMode>(
  AppThemeModeNotifier.new,
);

class AppThemeModeNotifier extends Notifier<AppThemeMode> {
  static const _key = 'theme_mode';

  @override
  AppThemeMode build() {
    _loadAppThemeMode();
    return AppThemeMode.light;
  }

  Future<void> _loadAppThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value != null) {
      state = AppThemeMode.values.firstWhere(
        (mode) => mode.name == value,
        orElse: () => AppThemeMode.light,
      );
    }
  }

  Future<void> setAppThemeMode(AppThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }

  void toggleTheme() {
    final newMode = state == AppThemeMode.light ? AppThemeMode.dark : AppThemeMode.light;
    setAppThemeMode(newMode);
  }
}

/// Theme Mode Enum
enum AppThemeMode {
  light,
  dark,
  system,
}
