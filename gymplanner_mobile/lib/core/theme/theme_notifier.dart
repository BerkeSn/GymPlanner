import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends Notifier<bool> {
  static const String _key = 'isDarkMode';

  @override
  bool build() {
    _loadTheme();
    return true; // Varsayılan: dark tema
  }

  Future<void> _loadTheme() async {
    final prefs =
        await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_key) ?? true;
    state = isDark;
  }

  Future<void> toggleTheme() async {
    final prefs =
        await SharedPreferences.getInstance();
    state = !state;
    await prefs.setBool(_key, state);
  }
}

final themeProvider =
    NotifierProvider<ThemeNotifier, bool>(
      () => ThemeNotifier(),
    );
