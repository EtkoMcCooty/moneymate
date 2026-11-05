import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_theme.dart';
import '../models/analytics_models.dart';

/// Pure domain calculation service for aggregating financial metrics,
/// rolling timeframe summaries, category allocations, and debt balances.
class AnalyticsEngineService {
  const AnalyticsEngineService();

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const List<Color> _palette = [
    AppTheme.primaryColor,
    AppTheme.secondaryColor,
    AppTheme.debtColor,
    AppTheme.savingsColor,
    AppTheme.accentColor,
    Color(0xFF8B5CF6), // Violet 500
    Color(0xFFF59E0B), // Amber 500
    Color(0xFFEC4899), // Pink 500
  ];

  /// Aggregates raw entries, items, and categories into chronological monthly metric summaries.
  List<PeriodMetricSummary> computePeriodSummaries({
    required List<ItemEntry> entries,
    required List<FinanceItem> items,
    required List<Category> categories,
    required List<String> sortedPeriodKeys,
  }) {
    final itemMap = {for (final item in items) item.id: item};
    final categoryMap = {for (final cat in categories) cat.id: cat};

    // Group entries by periodKey
    final entriesByPeriod = <String, List<ItemEntry>>{};
    for (final entry in entries) {
      entriesByPeriod.putIfAbsent(entry.periodKey, () => []).add(entry);
    }

    final summaries = <PeriodMetricSummary>[];

    for (final key in sortedPeriodKeys) {
      final periodEntries = entriesByPeriod[key] ?? [];

      double income = 0.0;
      double expenses = 0.0;
      double debtPayments = 0.0;
      double savings = 0.0;

      for (final entry in periodEntries) {
        final item = itemMap[entry.itemId];
        if (item == null) continue;
        final category = categoryMap[item.categoryId];
        if (category == null) continue;

        final type = category.categoryType.toLowerCase();
        if (type == 'income') {
          income += entry.amount;
        } else if (type == 'expense') {
          expenses += entry.amount;
        } else if (type == 'debt') {
          debtPayments += (entry.amount + entry.extraPayment);
        } else if (type == 'savings' || type == 'investment') {
          savings += entry.amount;
        } else {
          expenses += entry.amount;
        }
      }

      summaries.add(
        PeriodMetricSummary(
          periodKey: key,
          displayLabel: formatPeriodLabel(key),
          totalIncome: income,
          totalExpenses: expenses,
          totalDebtPayments: debtPayments,
          totalSavings: savings,
        ),
      );
    }

    return summaries;
  }

  /// Filters sorted period summaries to match the selected [AnalyticsTimeframe].
  List<PeriodMetricSummary> filterByTimeframe({
    required List<PeriodMetricSummary> allSummaries,
    required AnalyticsTimeframe timeframe,
  }) {
    if (allSummaries.isEmpty) return [];

    final limit = timeframe.monthLimit;
    if (limit == null || allSummaries.length <= limit) {
      return List.unmodifiable(allSummaries);
    }

    // Take the most recent [limit] periods in chronological order
    final startIndex = allSummaries.length - limit;
    return List.unmodifiable(allSummaries.sublist(startIndex));
  }

  /// Computes category-level spending and allocation breakdowns across [periodKeys].
  List<CategoryMetricBreakdown> computeCategoryBreakdowns({
    required List<String> periodKeys,
    required List<ItemEntry> entries,
    required List<FinanceItem> items,
    required List<Category> categories,
  }) {
    if (periodKeys.isEmpty || entries.isEmpty) return [];

    final allowedPeriods = periodKeys.toSet();
    final itemMap = {for (final item in items) item.id: item};
    final categoryMap = {for (final cat in categories) cat.id: cat};

    final categoryTotals = <int, double>{};

    for (final entry in entries) {
      if (!allowedPeriods.contains(entry.periodKey)) continue;

      final item = itemMap[entry.itemId];
      if (item == null) continue;
      final category = categoryMap[item.categoryId];
      if (category == null) continue;

      // Exclude income from outflow category allocations
      if (category.categoryType.toLowerCase() == 'income') continue;

      final outflow = category.categoryType.toLowerCase() == 'debt'
          ? (entry.amount + entry.extraPayment)
          : entry.amount;

      categoryTotals[category.id] = (categoryTotals[category.id] ?? 0.0) + outflow;
    }

    final totalSpending = categoryTotals.values.fold(0.0, (sum, val) => sum + val);

    final breakdowns = <CategoryMetricBreakdown>[];
    int colorIndex = 0;

    for (final entry in categoryTotals.entries) {
      final category = categoryMap[entry.key];
      if (category == null) continue;

      final amount = entry.value;
      if (amount <= 0.0) continue;

      final percentage = totalSpending > 0.0
          ? (amount / totalSpending) * 100.0
          : 0.0;

      final color = _palette[colorIndex % _palette.length];
      colorIndex++;

      breakdowns.add(
        CategoryMetricBreakdown(
          categoryId: category.id,
          categoryName: category.name,
          categoryType: category.categoryType,
          totalAmount: amount,
          percentage: double.parse(percentage.toStringAsFixed(1)),
          color: color,
        ),
      );
    }

    // Sort descending by highest spending
    breakdowns.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return breakdowns;
  }

  /// Computes total remaining debt principal balance across all debts.
  double computeRemainingDebt({
    required List<DebtMetadataData> debtMetadataList,
    required List<ItemEntry> entries,
    required List<FinanceItem> items,
  }) {
    if (debtMetadataList.isEmpty) return 0.0;

    final debtItemIds = debtMetadataList.map((d) => d.itemId).toSet();

    // Map itemId -> total payments made
    final paymentsByItem = <int, double>{};
    for (final entry in entries) {
      if (debtItemIds.contains(entry.itemId)) {
        final paid = entry.amount + entry.extraPayment;
        paymentsByItem[entry.itemId] = (paymentsByItem[entry.itemId] ?? 0.0) + paid;
      }
    }

    double totalRemaining = 0.0;
    for (final debt in debtMetadataList) {
      final paid = paymentsByItem[debt.itemId] ?? 0.0;
      final remaining = max(0.0, debt.totalPrincipal - paid);
      totalRemaining += remaining;
    }

    return totalRemaining;
  }

  /// Formats period keys (e.g. '2026-03') into friendly labels (e.g. 'Mar 26').
  static String formatPeriodLabel(String periodKey) {
    final parts = periodKey.split('-');
    if (parts.length != 2) return periodKey;

    final yearStr = parts[0];
    final monthStr = parts[1];

    final monthInt = int.tryParse(monthStr) ?? 1;
    final monthIdx = (monthInt - 1).clamp(0, 11);
    final monthName = _monthNames[monthIdx];

    final shortYear = yearStr.length >= 4 ? yearStr.substring(2) : yearStr;
    return '$monthName $shortYear';
  }
}
