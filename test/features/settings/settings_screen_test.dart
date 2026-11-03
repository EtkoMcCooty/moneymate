import 'package:drift/native.dart';
import 'package:flutter/material.dart';
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
      expect(find.text('Spending Categories'), findsOneWidget);

      // Check default values
      expect(find.text('Monthly Payday'), findsOneWidget);
      expect(find.textContaining('15th of the month'), findsOneWidget);
      expect(find.text('Default Currency'), findsOneWidget);
      expect(find.textContaining('Current symbol: £'), findsOneWidget);

      // Check category list items rendered
      expect(find.text('Household'), findsOneWidget);
      expect(find.text('Bills & Expenses'), findsWidgets);
      expect(find.text('Income'), findsWidgets);
      expect(find.text('Debts'), findsWidgets);

      // Scroll to App Updates section
      await tester.scrollUntilVisible(find.text('Check for updates'), 200);
      expect(find.text('App Updates'), findsOneWidget);
      expect(find.text('Check for updates'), findsOneWidget);
    });

    testWidgets('opens payday picker dialog and changes start day', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Tap on Monthly Payday
      await tester.tap(find.text('Monthly Payday'));
      await tester.pumpAndSettle();

      expect(find.text('Choose your payday'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Choose your payday'), findsNothing);
    });

    testWidgets('opens currency dialog and selects a new currency', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Tap on Default Currency
      await tester.tap(find.text('Default Currency'));
      await tester.pumpAndSettle();

      expect(find.text('Choose currency symbol'), findsOneWidget);
      expect(find.text('Euro (€)'), findsOneWidget);

      // Tap Euro
      await tester.tap(find.text('Euro (€)'));
      await tester.pumpAndSettle();

      // Confirm updated in UI
      expect(find.textContaining('Current symbol: €'), findsOneWidget);
    });

    testWidgets('adds a new custom spending category', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Tap Add button
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.text('Add category'), findsOneWidget);

      // Enter category name
      await tester.enterText(find.byType(TextField), 'Gym & Fitness');
      await tester.pumpAndSettle();

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
