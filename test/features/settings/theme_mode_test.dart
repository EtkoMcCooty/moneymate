import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moneymate/app.dart';
import 'package:moneymate/core/database/app_database.dart';
import 'package:moneymate/core/database/database_provider.dart';
import 'package:moneymate/features/settings/state/theme_mode_notifier.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('ThemeModeNotifier Unit Tests', () {
    test('initializes with default ThemeMode.system when no setting exists', () async {
      final notifier = ThemeModeNotifier(db);
      expect(notifier.state, equals(ThemeMode.system));

      await notifier.loadSavedTheme();
      expect(notifier.state, equals(ThemeMode.system));
    });

    test('persists setThemeMode to database and reloads correctly', () async {
      final notifier = ThemeModeNotifier(db);

      // Set to dark mode
      await notifier.setThemeMode(ThemeMode.dark);
      expect(notifier.state, equals(ThemeMode.dark));

      // Verify row in SQLite AppSettings table
      final stored = await (db.select(db.appSettings)
            ..where((s) => s.key.equals('theme_mode')))
          .getSingle();
      expect(stored.value, equals('dark'));

      // New notifier loads the persisted value
      final freshNotifier = ThemeModeNotifier(db);
      await freshNotifier.loadSavedTheme();
      expect(freshNotifier.state, equals(ThemeMode.dark));

      // Set to light mode
      await freshNotifier.setThemeMode(ThemeMode.light);
      expect(freshNotifier.state, equals(ThemeMode.light));

      final updated = await (db.select(db.appSettings)
            ..where((s) => s.key.equals('theme_mode')))
          .getSingle();
      expect(updated.value, equals('light'));
    });
  });

  group('MoneyMateApp Theme Integration Tests', () {
    testWidgets('MoneyMateApp listens to themeModeProvider and applies ThemeMode', (tester) async {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MoneyMateApp(),
        ),
      );
      await tester.pumpAndSettle();

      MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.themeMode, equals(ThemeMode.system));

      // Change to dark mode
      await container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
      await tester.pumpAndSettle();

      app = tester.widget(find.byType(MaterialApp));
      expect(app.themeMode, equals(ThemeMode.dark));

      // Change to light mode
      await container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
      await tester.pumpAndSettle();

      app = tester.widget(find.byType(MaterialApp));
      expect(app.themeMode, equals(ThemeMode.light));
    });
  });
}
