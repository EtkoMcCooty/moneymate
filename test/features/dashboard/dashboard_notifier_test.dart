import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/core/database/app_database.dart';
import 'package:moneymate/features/dashboard/models/analytics_models.dart';
import 'package:moneymate/features/dashboard/state/dashboard_notifier.dart';

void main() {
  late AppDatabase db;
  late DashboardNotifier notifier;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    notifier = DashboardNotifier(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('DashboardNotifier', () {
    test('initializes with empty state when database has no records', () async {
      await notifier.loadDashboard();
      final state = notifier.state;

      expect(state.isLoading, isFalse);
      expect(state.hasData, isFalse);
      expect(state.selectedTimeframe, equals(AnalyticsTimeframe.sixMonths));
    });

    test('loads data and aggregates metrics when database has entries', () async {
      // 1. Create tracker
      final trackerId = await db.into(db.trackers).insert(
            TrackersCompanion.insert(
              name: 'Test Tracker',
              currencySymbol: const Value('£'),
            ),
          );

      // 2. Create categories
      final incomeCatId = await db.into(db.categories).insert(
            CategoriesCompanion.insert(
              trackerId: trackerId,
              name: 'Income',
              categoryType: 'income',
            ),
          );
      final expenseCatId = await db.into(db.categories).insert(
            CategoriesCompanion.insert(
              trackerId: trackerId,
              name: 'Household',
              categoryType: 'expense',
            ),
          );

      // 3. Create items
      final salaryItemId = await db.into(db.financeItems).insert(
            FinanceItemsCompanion.insert(categoryId: incomeCatId, name: 'Salary'),
          );
      final rentItemId = await db.into(db.financeItems).insert(
            FinanceItemsCompanion.insert(categoryId: expenseCatId, name: 'Rent'),
          );

      // 4. Create entries across 2 periods
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

      await notifier.loadDashboard();
      final state = notifier.state;

      expect(state.isLoading, isFalse);
      expect(state.hasData, isTrue);
      expect(state.data!.periodSummaries.length, equals(2));
      expect(state.data!.periodSummaries.first.totalIncome, equals(3000.0));
      expect(state.data!.periodSummaries.last.totalIncome, equals(3200.0));
      expect(state.data!.averageDisposableIncome, equals(1900.0)); // ((3000-1200) + (3200-1200)) / 2 = (1800 + 2000) / 2
    });

    test('updating timeframe updates filtered summaries in state', () async {
      // Create tracker & items
      final trackerId = await db.into(db.trackers).insert(TrackersCompanion.insert(name: 'Tracker'));
      final catId = await db.into(db.categories).insert(
            CategoriesCompanion.insert(trackerId: trackerId, name: 'Income', categoryType: 'income'),
          );
      final itemId = await db.into(db.financeItems).insert(
            FinanceItemsCompanion.insert(categoryId: catId, name: 'Salary'),
          );

      // Add entries for 5 months
      for (int i = 1; i <= 5; i++) {
        await db.into(db.itemEntries).insert(
              ItemEntriesCompanion.insert(
                itemId: itemId,
                periodKey: '2026-0$i',
                amount: const Value(2000.0),
              ),
            );
      }

      await notifier.loadDashboard();
      expect(notifier.state.data!.periodSummaries.length, equals(5));

      // Switch to 3 months
      notifier.setTimeframe(AnalyticsTimeframe.threeMonths);
      expect(notifier.state.selectedTimeframe, equals(AnalyticsTimeframe.threeMonths));
      expect(notifier.state.data!.periodSummaries.length, equals(3));
      expect(notifier.state.data!.periodSummaries.first.periodKey, equals('2026-03'));
      expect(notifier.state.data!.periodSummaries.last.periodKey, equals('2026-05'));
    });
  });
}
