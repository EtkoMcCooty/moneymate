import 'package:flutter_riverpod/legacy.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';

const String _themeModeSettingKey = 'theme_mode';

/// Notifier managing application theme mode (System, Light, Dark)
/// with persistent storage in Drift SQLite AppSettings table.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final AppDatabase _db;

  ThemeModeNotifier(this._db) : super(ThemeMode.system) {
    loadSavedTheme();
  }

  /// Loads saved theme mode from SQLite settings, defaulting to [ThemeMode.system].
  Future<void> loadSavedTheme() async {
    try {
      final setting = await (_db.select(_db.appSettings)
            ..where((s) => s.key.equals(_themeModeSettingKey)))
          .getSingleOrNull();

      if (setting != null) {
        state = _parseThemeMode(setting.value);
      }
    } catch (_) {
      state = ThemeMode.system;
    }
  }

  /// Sets the theme mode in memory and persists to SQLite.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      await _db.into(_db.appSettings).insertOnConflictUpdate(
            AppSettingsCompanion.insert(
              key: _themeModeSettingKey,
              value: mode.name,
            ),
          );
    } catch (_) {
      // Retain reactive UI state even if storage write fails
    }
  }

  static ThemeMode _parseThemeMode(String value) {
    switch (value.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}

/// Provider exposing [ThemeModeNotifier] and current [ThemeMode].
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ThemeModeNotifier(db);
});
