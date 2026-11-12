import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/core/database/app_database.dart';
import 'package:moneymate/core/database/database_provider.dart';
import 'package:moneymate/features/settings/views/settings_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestApp() {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
      child: const MaterialApp(
        home: SettingsScreen(),
      ),
    );
  }

  group('SettingsScreen Widget Tests', () {
    testWidgets('renders all settings sections cleanly', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Check section headers
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Payday & Pay Period'), findsOneWidget);
      expect(find.text('Currency'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);

      // Check default values
      expect(find.text('Monthly Payday'), findsOneWidget);
      expect(find.textContaining('15th of the month'), findsOneWidget);
      expect(find.text('Default Currency'), findsOneWidget);
      expect(find.textContaining('Current symbol: £'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.byKey(const Key('theme_mode_segmented_button')), findsOneWidget);

      // Scroll to categories
      await tester.scrollUntilVisible(find.text('Spending Categories'), 200);
      expect(find.text('Spending Categories'), findsOneWidget);
      expect(find.text('Household'), findsOneWidget);
      expect(find.text('Bills & Expenses'), findsWidgets);
      expect(find.text('Income'), findsWidgets);
      expect(find.text('Debts'), findsWidgets);

      // Scroll to App Updates section
      await tester.scrollUntilVisible(find.text('Check for updates'), 200);
      expect(find.text('App Updates'), findsOneWidget);
      expect(find.text('Check for updates'), findsOneWidget);
    });

    testWidgets('renders appearance section and toggles theme mode', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Appearance'), 200);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.byKey(const Key('theme_mode_segmented_button')), findsOneWidget);
      expect(find.text('Follow system theme'), findsOneWidget);

      // Tap Dark
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(find.text('Dark theme active'), findsOneWidget);

      // Tap Light
      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();

      expect(find.text('Light theme active'), findsOneWidget);
    });

    testWidgets('opens payday picker dialog and changes start day', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Tap on Monthly Payday
      await tester.tap(find.text('Monthly Payday'));
      await tester.pumpAndSettle();

      expect(find.text('Choose your payday'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);

      // Save new day
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Choose your payday'), findsNothing);
    });

    testWidgets('opens currency picker dialog and selects new symbol', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Ensure Currency is visible and tap Default Currency
      await tester.scrollUntilVisible(find.text('Default Currency'), 200);
      await tester.tap(find.text('Default Currency'));
      await tester.pumpAndSettle();

      expect(find.text('Choose currency symbol'), findsOneWidget);

      // Select USD ($)
      await tester.tap(find.textContaining('Dollar'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Current symbol: \$'), findsOneWidget);
    });

    testWidgets('opens add category dialog and creates new category', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Scroll to Add button and tap
      await tester.scrollUntilVisible(find.widgetWithText(TextButton, 'Add'), 200);
      await tester.tap(find.widgetWithText(TextButton, 'Add'));
      await tester.pumpAndSettle();

      expect(find.text('Add category'), findsOneWidget);

      // Enter name
      await tester.enterText(find.byType(TextField), 'Gym & Fitness');

      // Tap Add in dialog
      await tester.tap(find.widgetWithText(FilledButton, 'Add'));
      await tester.pumpAndSettle();

      // Verify category rendered in list
      expect(find.text('Gym & Fitness'), findsOneWidget);
    });

    testWidgets('shows import spreadsheet tile and opens status dialog', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.byKey(const Key('settings_import_spreadsheet_tile')), 200);
      final importTile = find.byKey(const Key('settings_import_spreadsheet_tile'));
      expect(importTile, findsOneWidget);

      await tester.tap(importTile);
      await tester.pumpAndSettle();

      expect(find.text('Import spreadsheet'), findsWidgets);
      expect(find.text('Got it'), findsOneWidget);

      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();

      expect(find.text('Got it'), findsNothing);
    });
  });
}
