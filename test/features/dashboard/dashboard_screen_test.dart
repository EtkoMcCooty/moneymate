import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/core/database/app_database.dart';
import 'package:moneymate/core/database/database_provider.dart';
import 'package:moneymate/features/dashboard/views/dashboard_screen.dart';

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
        home: DashboardScreen(),
      ),
    );
  }

  group('DashboardScreen Widget Tests', () {
    testWidgets('renders empty state when database has no financial data', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // App bar title
      expect(find.text('Insights'), findsOneWidget);

      // Empty state prompt
      expect(find.text('No tracking data yet'), findsOneWidget);
      expect(
        find.textContaining('Add items in your Tracker or import a spreadsheet'),
        findsOneWidget,
      );
    });

    testWidgets('renders KPI cards, timeframe chips, trend chart, and category breakdown when data exists', (tester) async {
      // 1. Seed Tracker & Categories
      final trackerId = await db.into(db.trackers).insert(
            TrackersCompanion.insert(
              name: 'My Tracker',
              currencySymbol: const Value('£'),
            ),
          );

      final incomeCatId = await db.into(db.categories).insert(
            CategoriesCompanion.insert(
              trackerId: trackerId,
              name: 'Income',
              categoryType: 'income',
            ),
          );
      final householdCatId = await db.into(db.categories).insert(
            CategoriesCompanion.insert(
              trackerId: trackerId,
              name: 'Household',
              categoryType: 'expense',
            ),
          );

      // 2. Seed Items
      final salaryItemId = await db.into(db.financeItems).insert(
            FinanceItemsCompanion.insert(categoryId: incomeCatId, name: 'Salary'),
          );
      final rentItemId = await db.into(db.financeItems).insert(
            FinanceItemsCompanion.insert(categoryId: householdCatId, name: 'Rent'),
          );

      // 3. Seed Entries across 2 months
      await db.into(db.itemEntries).insert(
            ItemEntriesCompanion.insert(itemId: salaryItemId, periodKey: '2026-01', amount: const Value(3000.0)),
          );
      await db.into(db.itemEntries).insert(
            ItemEntriesCompanion.insert(itemId: rentItemId, periodKey: '2026-01', amount: const Value(1200.0)),
          );
      await db.into(db.itemEntries).insert(
            ItemEntriesCompanion.insert(itemId: salaryItemId, periodKey: '2026-02', amount: const Value(3200.0)),
          );
      await db.into(db.itemEntries).insert(
            ItemEntriesCompanion.insert(itemId: rentItemId, periodKey: '2026-02', amount: const Value(1200.0)),
          );

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Verify App Bar
      expect(find.text('Insights'), findsOneWidget);

      // Verify Timeframe Chips and tap 3 Months
      expect(find.text('3 Months'), findsOneWidget);
      expect(find.text('6 Months'), findsOneWidget);
      expect(find.text('1 Year'), findsOneWidget);
      expect(find.text('All Time'), findsOneWidget);

      await tester.tap(find.text('3 Months'));
      await tester.pumpAndSettle();

      // Verify KPI Cards
      expect(find.text('Disposable Income'), findsWidgets);
      expect(find.text('Money In vs Out'), findsOneWidget);

      // Verify Trend Chart Presence
      expect(find.byKey(const Key('dashboard_trend_chart')), findsOneWidget);

      // Scroll down to Category Breakdown Section ("Where your money goes")
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.text('Where your money goes'), findsOneWidget);
      expect(find.text('Household'), findsWidgets);
    });
  });
}
