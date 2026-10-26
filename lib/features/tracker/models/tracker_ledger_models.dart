import 'package:flutter/foundation.dart' hide Category;
import '../../../core/database/app_database.dart';

@immutable
class FinanceItemWithEntry {
  final FinanceItem item;
  final ItemEntry? entry;
  final DebtMetadataData? debtMetadata;

  const FinanceItemWithEntry({
    required this.item,
    this.entry,
    this.debtMetadata,
  });

  double get amount => entry?.amount ?? 0.0;
  double get extraPayment => entry?.extraPayment ?? 0.0;
  String? get note => entry?.note;
}

@immutable
class CategorySection {
  final Category category;
  final List<FinanceItemWithEntry> items;
  final bool isCollapsed;

  const CategorySection({
    required this.category,
    required this.items,
    this.isCollapsed = false,
  });

  double get totalAmount => items.fold(0.0, (sum, i) => sum + i.amount);

  CategorySection copyWith({
    Category? category,
    List<FinanceItemWithEntry>? items,
    bool? isCollapsed,
  }) {
    return CategorySection(
      category: category ?? this.category,
      items: items ?? this.items,
      isCollapsed: isCollapsed ?? this.isCollapsed,
    );
  }
}

@immutable
class TrackerLedgerSummary {
  final double totalIncome;
  final double totalExpenses;
  final double totalDebtPayments;
  final double totalSavingsAndInvestments;

  const TrackerLedgerSummary({
    this.totalIncome = 0.0,
    this.totalExpenses = 0.0,
    this.totalDebtPayments = 0.0,
    this.totalSavingsAndInvestments = 0.0,
  });

  /// Disposable income: Total Income minus (Expenses + Debt Payments + Savings/Investments)
  double get disposableIncome =>
      totalIncome - (totalExpenses + totalDebtPayments + totalSavingsAndInvestments);
}

@immutable
class TrackerLedgerState {
  final String selectedPeriodKey;
  final int cycleStartDay;
  final String currencySymbol;
  final List<CategorySection> sections;
  final TrackerLedgerSummary summary;
  final bool isLoading;
  final String? errorMessage;

  const TrackerLedgerState({
    required this.selectedPeriodKey,
    this.cycleStartDay = 15,
    this.currencySymbol = '£',
    this.sections = const [],
    this.summary = const TrackerLedgerSummary(),
    this.isLoading = false,
    this.errorMessage,
  });

  TrackerLedgerState copyWith({
    String? selectedPeriodKey,
    int? cycleStartDay,
    String? currencySymbol,
    List<CategorySection>? sections,
    TrackerLedgerSummary? summary,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TrackerLedgerState(
      selectedPeriodKey: selectedPeriodKey ?? this.selectedPeriodKey,
      cycleStartDay: cycleStartDay ?? this.cycleStartDay,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      sections: sections ?? this.sections,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
