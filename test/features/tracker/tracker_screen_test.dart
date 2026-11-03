import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/core/database/app_database.dart';
import 'package:moneymate/core/database/database_provider.dart';
import 'package:moneymate/core/theme/app_theme.dart';
import 'package:moneymate/features/tracker/views/tracker_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());

    // Seed default tracker and standard categories
    final trackerId = await db.into(db.trackers).insert(
          TrackersCompanion.insert(
            name: 'My Tracker',
            cycleStartDay: const Value(15),
            currencySymbol: const Value('£'),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );

    final incomeCatId = await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            trackerId: trackerId,
            name: 'Income',
            categoryType: 'income',
            sortOrder: const Value(0),
          ),
        );

    final householdCatId = await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            trackerId: trackerId,
            name: 'Household',
            categoryType: 'expense',
            sortOrder: const Value(1),
          ),
        );

    // Insert sample items and entries
    final salaryItemId = await db.into(db.financeItems).insert(
          FinanceItemsCompanion.insert(categoryId: incomeCatId, name: 'Salary'),
        );
    final rentItemId = await db.into(db.financeItems).insert(
          FinanceItemsCompanion.insert(categoryId: householdCatId, name: 'Rent'),
        );

    await db.into(db.itemEntries).insert(
          ItemEntriesCompanion.insert(
            itemId: salaryItemId,
            periodKey: '2026-01',
            amount: const Value(2500.0),
          ),
        );
    await db.into(db.itemEntries).insert(
          ItemEntriesCompanion.insert(
            itemId: rentItemId,
            periodKey: '2026-01',
            amount: const Value(950.0),
          ),
        );
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
        home: TrackerScreen(),
      ),
    );
  }

  group('TrackerScreen Widget Tests', () {
    testWidgets('renders monthly tracker, disposable income card, and category sections', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Check title and summary
      expect(find.text('Monthly Tracker'), findsOneWidget);
      expect(find.text('Disposable Income'), findsOneWidget);
      expect(find.text('Leftover after bills, debts & savings'), findsOneWidget);

      // Check metrics labels
      expect(find.text('Income'), findsWidgets);
      expect(find.text('Bills'), findsOneWidget);
      expect(find.text('Debts'), findsWidgets);
      expect(find.text('Savings'), findsWidgets);

      // Check category section titles
      expect(find.text('Household'), findsOneWidget);
      expect(find.text('Budget & Spending Sections'), findsOneWidget);
    });

    testWidgets('navigates to next and previous pay period', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Tap next month
      await tester.tap(find.byTooltip('Next month'));
      await tester.pumpAndSettle();

      // Tap previous month
      await tester.tap(find.byTooltip('Previous month'));
      await tester.pumpAndSettle();

      expect(find.text('Disposable Income'), findsOneWidget);
    });

    testWidgets('expands and collapses category sections', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Tap on Household section header to toggle
      await tester.tap(find.text('Household'));
      await tester.pumpAndSettle();

      expect(find.text('Household'), findsOneWidget);
    });

    testWidgets('applies green color for income buttons and red for expense/debt buttons', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      final incomeBtn = tester.widget<OutlinedButton>(find.byKey(const Key('add_item_button_Income')));
      final householdBtn = tester.widget<OutlinedButton>(find.byKey(const Key('add_item_button_Household')));

      final incomeColor = incomeBtn.style?.foregroundColor?.resolve({});
      final expenseColor = householdBtn.style?.foregroundColor?.resolve({});

      expect(incomeColor, equals(AppTheme.incomeColor));
      expect(expenseColor, equals(AppTheme.expenseColor));
    });
  });
}
