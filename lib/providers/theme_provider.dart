/// theme_provider.dart
///
/// Manages the application's visual theme (light / dark / system) and persists
/// the user's preference via [SharedPreferences].

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key used to store the selected theme index in [SharedPreferences].
const _kThemeModeKey = 'theme_mode';

/// Provides the current [ThemeMode] and exposes mutation methods.
///
/// Persist the user's preference between app launches using [SharedPreferences].
/// Register this as a [ChangeNotifierProvider] at the top of the widget tree.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  /// The currently active [ThemeMode].
  ThemeMode get themeMode => _themeMode;

  /// Convenience getter — `true` when the active mode is [ThemeMode.dark].
  bool get isDark => _themeMode == ThemeMode.dark;

  /// Convenience getter — `true` when the active mode is [ThemeMode.light].
  bool get isLight => _themeMode == ThemeMode.light;

  /// Convenience getter — `true` when the active mode is [ThemeMode.system].
  bool get isSystem => _themeMode == ThemeMode.system;

  // ──────────────────────────────────────────────────────────────────────────
  // Persistence
  // ──────────────────────────────────────────────────────────────────────────

  /// Loads the previously persisted [ThemeMode] from [SharedPreferences].
  ///
  /// If no preference is found (e.g. first launch) the mode defaults to
  /// [ThemeMode.system]. Call this once during app initialisation before
  /// [runApp] or inside an early [initState].
  Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final index = prefs.getInt(_kThemeModeKey);
      if (index != null && index >= 0 && index < ThemeMode.values.length) {
        _themeMode = ThemeMode.values[index];
      } else {
        _themeMode = ThemeMode.system;
      }
      notifyListeners();
    } catch (_) {
      // If loading fails keep the default (system).
      _themeMode = ThemeMode.system;
    }
  }

  /// Persists [mode] to [SharedPreferences] and notifies all listeners.
  Future<void> setTheme(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kThemeModeKey, mode.index);
    } catch (_) {
      // Persistence failure is non-fatal; the UI still reflects the change
      // for the current session.
    }
  }

  /// Toggles between [ThemeMode.light] and [ThemeMode.dark].
  ///
  /// If the current mode is [ThemeMode.system] it switches to [ThemeMode.dark].
  void toggleTheme() {
    setTheme(_themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }
}
