import 'package:material_ui/material_ui.dart';

/// Supported rolling timeframe filters for analytics.
enum AnalyticsTimeframe {
  threeMonths,
  sixMonths,
  oneYear,
  allTime;

  String get label => switch (this) {
        AnalyticsTimeframe.threeMonths => '3 Months',
        AnalyticsTimeframe.sixMonths => '6 Months',
        AnalyticsTimeframe.oneYear => '1 Year',
        AnalyticsTimeframe.allTime => 'All Time',
      };

  int? get monthLimit => switch (this) {
        AnalyticsTimeframe.threeMonths => 3,
        AnalyticsTimeframe.sixMonths => 6,
        AnalyticsTimeframe.oneYear => 12,
        AnalyticsTimeframe.allTime => null,
      };
}

/// Aggregated metrics for an individual pay cycle / month.
@immutable
class PeriodMetricSummary {
  final String periodKey; // Format: YYYY-MM (e.g. '2026-03')
  final String displayLabel; // Format: e.g. 'Mar 26'
  final double totalIncome;
  final double totalExpenses; // Household, Personal, Other
  final double totalDebtPayments; // Amount + extra payments
  final double totalSavings; // Savings + Investments

  const PeriodMetricSummary({
    required this.periodKey,
    required this.displayLabel,
    this.totalIncome = 0.0,
    this.totalExpenses = 0.0,
    this.totalDebtPayments = 0.0,
    this.totalSavings = 0.0,
  });

  /// Total money paid out during this period (Expenses + Debts + Savings).
  double get totalOutflows => totalExpenses + totalDebtPayments + totalSavings;

  /// Disposable income left after all outflows: Income - Total Outflows.
  double get disposableIncome => totalIncome - totalOutflows;

  /// Savings rate as a percentage of income (0.0 to 100.0).
  double get savingsRate =>
      totalIncome > 0 ? (totalSavings / totalIncome) * 100.0 : 0.0;
}

/// Spending and allocation breakdown for an individual category.
@immutable
class CategoryMetricBreakdown {
  final int categoryId;
  final String categoryName;
  final String categoryType; // 'expense', 'debt', 'savings', 'investment'
  final double totalAmount;
  final double percentage; // 0.0 to 100.0
  final Color color;

  const CategoryMetricBreakdown({
    required this.categoryId,
    required this.categoryName,
    required this.categoryType,
    required this.totalAmount,
    required this.percentage,
    required this.color,
  });
}

/// Comprehensive aggregated dataset for the selected timeframe.
@immutable
class DashboardAggregateData {
  final AnalyticsTimeframe timeframe;
  final List<PeriodMetricSummary> periodSummaries; // Sorted chronologically
  final PeriodMetricSummary? selectedPeriodSummary; // For drill-down inspection
  final List<CategoryMetricBreakdown> categoryBreakdowns;
  final double averageMonthlyIncome;
  final double averageMonthlyOutflows;
  final double averageDisposableIncome;
  final double totalDebtRemaining;
  final double totalDebtPaidInTimeframe;

  const DashboardAggregateData({
    required this.timeframe,
    this.periodSummaries = const [],
    this.selectedPeriodSummary,
    this.categoryBreakdowns = const [],
    this.averageMonthlyIncome = 0.0,
    this.averageMonthlyOutflows = 0.0,
    this.averageDisposableIncome = 0.0,
    this.totalDebtRemaining = 0.0,
    this.totalDebtPaidInTimeframe = 0.0,
  });
}

/// Reactive state container for the dashboard screen.
@immutable
class DashboardState {
  final AnalyticsTimeframe selectedTimeframe;
  final String? selectedPeriodKey;
  final String currencySymbol;
  final DashboardAggregateData? data;
  final bool isLoading;
  final String? errorMessage;

  const DashboardState({
    this.selectedTimeframe = AnalyticsTimeframe.sixMonths,
    this.selectedPeriodKey,
    this.currencySymbol = '£',
    this.data,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get hasData =>
      data != null &&
      data!.periodSummaries.isNotEmpty &&
      data!.periodSummaries.any((p) => p.totalIncome > 0 || p.totalOutflows > 0);

  DashboardState copyWith({
    AnalyticsTimeframe? selectedTimeframe,
    String? selectedPeriodKey,
    String? currencySymbol,
    DashboardAggregateData? data,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DashboardState(
      selectedTimeframe: selectedTimeframe ?? this.selectedTimeframe,
      selectedPeriodKey: selectedPeriodKey ?? this.selectedPeriodKey,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
