import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/utils/pay_cycle_service.dart';
import '../models/tracker_ledger_models.dart';

/// StateNotifier managing tracker ledger state, periods, collapsible sections,
/// and live financial totals (Income, Bills & Expenses, Debts, Savings, Disposable Income).
class TrackerLedgerNotifier extends StateNotifier<TrackerLedgerState> {
  final AppDatabase _db;

  TrackerLedgerNotifier(this._db)
      : super(
          TrackerLedgerState(
            selectedPeriodKey:
                PayCycleService.getPeriodKey(DateTime.now(), 15),
            isLoading: true,
          ),
        );

  /// Loads tracker ledger data for [periodKey] (defaults to active period).
  Future<void> loadLedger({String? periodKey}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      var tracker = await (_db.select(_db.trackers)..limit(1)).getSingleOrNull();

      if (tracker == null) {
        // Seed initial default tracker & categories if not yet created
        final trackerId = await _db.into(_db.trackers).insert(
              TrackersCompanion.insert(
                name: 'My Tracker',
                cycleStartDay: const Value(15),
                currencySymbol: const Value('£'),
                createdAt: Value(DateTime.now()),
                updatedAt: Value(DateTime.now()),
              ),
            );

        const defaultCategories = [
          ('Income', 'income', 0),
          ('Household', 'expense', 1),
          ('Personal', 'expense', 2),
          ('Other', 'expense', 3),
          ('Debts', 'debt', 4),
          ('Savings', 'savings', 5),
          ('Investments', 'investment', 6),
        ];

        for (final (name, type, order) in defaultCategories) {
          await _db.into(_db.categories).insert(
                CategoriesCompanion.insert(
                  trackerId: trackerId,
                  name: name,
                  categoryType: type,
                  sortOrder: Value(order),
                ),
              );
        }

        tracker = await (_db.select(_db.trackers)..where((t) => t.id.equals(trackerId))).getSingle();
      }

      final activeTracker = tracker;

      final effectivePeriodKey = periodKey ??
          (state.selectedPeriodKey.isNotEmpty
              ? state.selectedPeriodKey
              : PayCycleService.getPeriodKey(DateTime.now(), activeTracker.cycleStartDay));

      // Fetch all categories for this tracker
      final categories = await (_db.select(_db.categories)
            ..where((c) => c.trackerId.equals(activeTracker.id))
            ..orderBy([(c) => OrderingTerm(expression: c.sortOrder)]))
          .get();

      final sections = <CategorySection>[];
      var totalIncome = 0.0;
      var totalExpenses = 0.0;
      var totalDebtPayments = 0.0;
      var totalSavingsAndInvestments = 0.0;

      for (final category in categories) {
        // Fetch unarchived items for this category
        final items = await (_db.select(_db.financeItems)
              ..where((i) => i.categoryId.equals(category.id) & i.isArchived.equals(false)))
            .get();

        final itemsWithEntries = <FinanceItemWithEntry>[];
        for (final item in items) {
          final entry = await (_db.select(_db.itemEntries)
                ..where((e) =>
                    e.itemId.equals(item.id) & e.periodKey.equals(effectivePeriodKey)))
              .getSingleOrNull();

          DebtMetadataData? debtMetadata;
          if (category.categoryType == 'debt') {
            debtMetadata = await (_db.select(_db.debtMetadata)
                  ..where((d) => d.itemId.equals(item.id)))
                .getSingleOrNull();
          }

          itemsWithEntries.add(
            FinanceItemWithEntry(
              item: item,
              entry: entry,
              debtMetadata: debtMetadata,
            ),
          );
        }

        final section = CategorySection(
          category: category,
          items: itemsWithEntries,
        );
        sections.add(section);

        final sectionTotal = section.totalAmount;
        switch (category.categoryType.toLowerCase()) {
          case 'income':
            totalIncome += sectionTotal;
            break;
          case 'expense':
            totalExpenses += sectionTotal;
            break;
          case 'debt':
            totalDebtPayments += sectionTotal;
            break;
          case 'savings':
          case 'investment':
            totalSavingsAndInvestments += sectionTotal;
            break;
        }
      }

      final summary = TrackerLedgerSummary(
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        totalDebtPayments: totalDebtPayments,
        totalSavingsAndInvestments: totalSavingsAndInvestments,
      );

      state = TrackerLedgerState(
        selectedPeriodKey: effectivePeriodKey,
        cycleStartDay: activeTracker.cycleStartDay,
        currencySymbol: activeTracker.currencySymbol,
        sections: sections,
        summary: summary,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load tracker: $e',
      );
    }
  }

  /// Switches active pay cycle period and recalculates monthly totals.
  Future<void> selectPeriod(String periodKey) async {
    await loadLedger(periodKey: periodKey);
  }

  /// Toggles whether a category section is visually collapsed or expanded.
  void toggleCategoryCollapsed(int categoryId) {
    final updatedSections = state.sections.map((section) {
      if (section.category.id == categoryId) {
        return section.copyWith(isCollapsed: !section.isCollapsed);
      }
      return section;
    }).toList();

    state = state.copyWith(sections: updatedSections);
  }
}

/// Provider exposing [TrackerLedgerNotifier] and [TrackerLedgerState].
final trackerLedgerNotifierProvider =
    StateNotifierProvider<TrackerLedgerNotifier, TrackerLedgerState>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final notifier = TrackerLedgerNotifier(db);
  notifier.loadLedger();
  return notifier;
});
