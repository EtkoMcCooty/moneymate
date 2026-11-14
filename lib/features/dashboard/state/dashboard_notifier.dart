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
      final recordedKeys = _cachedEntries
          .where((e) => e.amount > 0 || e.extraPayment > 0)
          .map((e) => e.periodKey)
          .toSet();

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
        selectedPeriodKey: state.filteredMonthKey ?? state.selectedPeriodKey,
        isExplicitMonthFilter: state.isMonthFiltered,
      );

      state = state.copyWith(
        currencySymbol: currencySymbol,
        cycleStartDay: cycleStartDay,
        recordedPeriodKeys: recordedKeys,
        data: aggregateData,
        selectedPeriodKey: aggregateData.selectedPeriodSummary?.periodKey,
        clearSelectedPeriodKey: aggregateData.selectedPeriodSummary == null,
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
    if (state.selectedTimeframe == timeframe &&
        !state.isMonthFiltered &&
        state.data != null) {
      return;
    }

    final aggregateData = _recalculateData(
      timeframe: timeframe,
      selectedPeriodKey: null,
    );

    state = state.copyWith(
      selectedTimeframe: timeframe,
      clearSelectedPeriodKey: true,
      clearFilteredMonthKey: true,
      data: aggregateData,
    );
  }

  /// Filters the dashboard to inspect a specific pay cycle month and compare it against averages.
  void filterByMonth(String periodKey) {
    final aggregateData = _recalculateData(
      timeframe: state.selectedTimeframe,
      selectedPeriodKey: periodKey,
      isExplicitMonthFilter: true,
    );

    state = state.copyWith(
      filteredMonthKey: periodKey,
      selectedPeriodKey: periodKey,
      data: aggregateData,
    );
  }

  /// Clears the single-month filter and returns to the timeframe average overview.
  void clearMonthFilter() {
    final aggregateData = _recalculateData(
      timeframe: state.selectedTimeframe,
      selectedPeriodKey: null,
    );

    state = state.copyWith(
      clearFilteredMonthKey: true,
      clearSelectedPeriodKey: true,
      data: aggregateData,
    );
  }

  /// Selects a specific period from the chart or list to drill into its category breakdown.
  void selectPeriod(String periodKey) {
    if (state.selectedPeriodKey == periodKey &&
        state.data?.selectedPeriodSummary?.periodKey == periodKey) {
      return;
    }

    final aggregateData = _recalculateData(
      timeframe: state.selectedTimeframe,
      selectedPeriodKey: periodKey,
      isExplicitMonthFilter: state.isMonthFiltered,
    );

    state = state.copyWith(
      selectedPeriodKey: periodKey,
      filteredMonthKey: state.isMonthFiltered ? periodKey : state.filteredMonthKey,
      data: aggregateData,
    );
  }

  DashboardAggregateData _recalculateData({
    required AnalyticsTimeframe timeframe,
    required String? selectedPeriodKey,
    bool isExplicitMonthFilter = false,
  }) {
    final activePeriods = _engine.filterByTimeframe(
      allSummaries: _allSummaries,
      timeframe: timeframe,
    );

    // Determine targeted period summary for detail drill-down (null means timeframe overview)
    PeriodMetricSummary? targetPeriod;
    if (selectedPeriodKey != null) {
      targetPeriod =
          _allSummaries.where((p) => p.periodKey == selectedPeriodKey).firstOrNull;
      if (targetPeriod == null && isExplicitMonthFilter) {
        targetPeriod = PeriodMetricSummary(
          periodKey: selectedPeriodKey,
          displayLabel: AnalyticsEngineService.formatPeriodLabel(selectedPeriodKey),
        );
      }
    }

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
    final totalSavingsRate = activePeriods.fold(0.0, (sum, p) => sum + p.savingsRate);

    final avgIncome = totalIncome / periodCount;
    final avgOutflows = totalOutflows / periodCount;
    final avgDisposable = totalDisposable / periodCount;
    final avgSavingsRate = activePeriods.isNotEmpty ? totalSavingsRate / periodCount : 0.0;

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
      averageSavingsRate: avgSavingsRate,
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
