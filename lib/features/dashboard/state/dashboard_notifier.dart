import 'package:flutter_riverpod/legacy.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/utils/pay_cycle_service.dart';
import '../models/analytics_models.dart';
import '../services/analytics_engine_service.dart';

/// StateNotifier coordinating financial analytics aggregation,
/// timeframe filtering, and drill-down period inspections.
class DashboardNotifier extends StateNotifier<DashboardState> {
  final AppDatabase _db;
  final AnalyticsEngineService _engine;

  List<ItemEntry> _cachedEntries = [];
  List<FinanceItem> _cachedItems = [];
  List<Category> _cachedCategories = [];
  List<DebtMetadataData> _cachedDebts = [];
  List<PeriodMetricSummary> _allSummaries = [];

  DashboardNotifier(
    this._db, [
    this._engine = const AnalyticsEngineService(),
  ]) : super(const DashboardState(isLoading: true));

  /// Loads all required records from Drift SQLite and computes dashboard metrics.
  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final tracker = await (_db.select(_db.trackers)..limit(1)).getSingleOrNull();
      final currencySymbol = tracker?.currencySymbol ?? '£';
      final cycleStartDay = tracker?.cycleStartDay ?? 15;

      _cachedCategories = await _db.select(_db.categories).get();
      _cachedItems = await _db.select(_db.financeItems).get();
      _cachedEntries = await _db.select(_db.itemEntries).get();
      _cachedDebts = await _db.select(_db.debtMetadata).get();

      // Collect all distinct period keys sorted chronologically
      final periodKeysSet = _cachedEntries.map((e) => e.periodKey).toSet();

      // If empty, supply the current active pay cycle period
      if (periodKeysSet.isEmpty) {
        final currentKey = PayCycleService.getPeriodKey(DateTime.now(), cycleStartDay);
        periodKeysSet.add(currentKey);
      }

      final sortedPeriodKeys = periodKeysSet.toList()..sort();

      // Compute all chronological period summaries
      _allSummaries = _engine.computePeriodSummaries(
        entries: _cachedEntries,
        items: _cachedItems,
        categories: _cachedCategories,
        sortedPeriodKeys: sortedPeriodKeys,
      );

      final aggregateData = _recalculateData(
        timeframe: state.selectedTimeframe,
        selectedPeriodKey: state.selectedPeriodKey,
      );

      state = state.copyWith(
        currencySymbol: currencySymbol,
        data: aggregateData,
        selectedPeriodKey: aggregateData.selectedPeriodSummary?.periodKey,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to calculate insights: $e',
      );
    }
  }

  /// Changes the rolling timeframe (3 Months, 6 Months, 1 Year, All Time).
  void setTimeframe(AnalyticsTimeframe timeframe) {
    if (state.selectedTimeframe == timeframe && state.data != null) return;

    final aggregateData = _recalculateData(
      timeframe: timeframe,
      selectedPeriodKey: null, // Reset to latest period in new window
    );

    state = state.copyWith(
      selectedTimeframe: timeframe,
      selectedPeriodKey: aggregateData.selectedPeriodSummary?.periodKey,
      data: aggregateData,
    );
  }

  /// Selects a specific period from the chart or list to drill into its category breakdown.
  void selectPeriod(String periodKey) {
    if (state.selectedPeriodKey == periodKey) return;

    final aggregateData = _recalculateData(
      timeframe: state.selectedTimeframe,
      selectedPeriodKey: periodKey,
    );

    state = state.copyWith(
      selectedPeriodKey: periodKey,
      data: aggregateData,
    );
  }

  DashboardAggregateData _recalculateData({
    required AnalyticsTimeframe timeframe,
    required String? selectedPeriodKey,
  }) {
    final activePeriods = _engine.filterByTimeframe(
      allSummaries: _allSummaries,
      timeframe: timeframe,
    );

    // Determine targeted period summary for detail drill-down (defaults to latest)
    PeriodMetricSummary? targetPeriod;
    if (selectedPeriodKey != null) {
      targetPeriod = activePeriods.where((p) => p.periodKey == selectedPeriodKey).firstOrNull;
    }
    targetPeriod ??= activePeriods.isNotEmpty ? activePeriods.last : null;

    // Targeted periods for category breakdown (either single selected period, or all active)
    final breakdownPeriods = targetPeriod != null
        ? [targetPeriod.periodKey]
        : activePeriods.map((p) => p.periodKey).toList();

    final categoryBreakdowns = _engine.computeCategoryBreakdowns(
      periodKeys: breakdownPeriods,
      entries: _cachedEntries,
      items: _cachedItems,
      categories: _cachedCategories,
    );

    // Compute averages across active periods
    final periodCount = activePeriods.isNotEmpty ? activePeriods.length : 1;
    final totalIncome = activePeriods.fold(0.0, (sum, p) => sum + p.totalIncome);
    final totalOutflows = activePeriods.fold(0.0, (sum, p) => sum + p.totalOutflows);
    final totalDisposable = activePeriods.fold(0.0, (sum, p) => sum + p.disposableIncome);

    final avgIncome = totalIncome / periodCount;
    final avgOutflows = totalOutflows / periodCount;
    final avgDisposable = totalDisposable / periodCount;

    final remainingDebt = _engine.computeRemainingDebt(
      debtMetadataList: _cachedDebts,
      entries: _cachedEntries,
      items: _cachedItems,
    );

    final totalDebtPaidInTimeframe = activePeriods.fold(0.0, (sum, p) => sum + p.totalDebtPayments);

    return DashboardAggregateData(
      timeframe: timeframe,
      periodSummaries: activePeriods,
      selectedPeriodSummary: targetPeriod,
      categoryBreakdowns: categoryBreakdowns,
      averageMonthlyIncome: avgIncome,
      averageMonthlyOutflows: avgOutflows,
      averageDisposableIncome: avgDisposable,
      totalDebtRemaining: remainingDebt,
      totalDebtPaidInTimeframe: totalDebtPaidInTimeframe,
    );
  }
}

/// Global Riverpod provider for [DashboardNotifier].
final dashboardNotifierProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DashboardNotifier(db);
});
