import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/core/database/app_database.dart';
import 'package:moneymate/features/dashboard/models/analytics_models.dart';
import 'package:moneymate/features/dashboard/services/analytics_engine_service.dart';

void main() {
  const service = AnalyticsEngineService();

  group('AnalyticsEngineService - Period Summaries and Calculations', () {
    final categories = [
      const Category(id: 1, trackerId: 1, name: 'Income', categoryType: 'income', sortOrder: 0),
      const Category(id: 2, trackerId: 1, name: 'Household', categoryType: 'expense', sortOrder: 1),
      const Category(id: 3, trackerId: 1, name: 'Personal', categoryType: 'expense', sortOrder: 2),
      const Category(id: 4, trackerId: 1, name: 'Debts', categoryType: 'debt', sortOrder: 3),
      const Category(id: 5, trackerId: 1, name: 'Savings', categoryType: 'savings', sortOrder: 4),
      const Category(id: 6, trackerId: 1, name: 'Investments', categoryType: 'investment', sortOrder: 5),
    ];

    final items = [
      const FinanceItem(id: 1, categoryId: 1, name: 'Salary', isArchived: false),
      const FinanceItem(id: 2, categoryId: 2, name: 'Rent', isArchived: false),
      const FinanceItem(id: 3, categoryId: 3, name: 'Groceries', isArchived: false),
      const FinanceItem(id: 4, categoryId: 4, name: 'Credit Card', isArchived: false),
      const FinanceItem(id: 5, categoryId: 5, name: 'ISA Savings', isArchived: false),
    ];

    test('computes correct totals and disposable income for period', () {
      final entries = [
        const ItemEntry(id: 1, itemId: 1, periodKey: '2026-03', amount: 3500.0, extraPayment: 0.0),
        const ItemEntry(id: 2, itemId: 2, periodKey: '2026-03', amount: 1200.0, extraPayment: 0.0),
        const ItemEntry(id: 3, itemId: 3, periodKey: '2026-03', amount: 300.0, extraPayment: 0.0),
        const ItemEntry(id: 4, itemId: 4, periodKey: '2026-03', amount: 200.0, extraPayment: 50.0), // Debt total: 250
        const ItemEntry(id: 5, itemId: 5, periodKey: '2026-03', amount: 450.0, extraPayment: 0.0),
      ];

      final summaries = service.computePeriodSummaries(
        entries: entries,
        items: items,
        categories: categories,
        sortedPeriodKeys: ['2026-03'],
      );

      expect(summaries.length, equals(1));
      final s = summaries.first;
      expect(s.periodKey, equals('2026-03'));
      expect(s.totalIncome, equals(3500.0));
      expect(s.totalExpenses, equals(1500.0)); // 1200 + 300
      expect(s.totalDebtPayments, equals(250.0)); // 200 + 50 extra
      expect(s.totalSavings, equals(450.0));
      expect(s.totalOutflows, equals(2200.0)); // 1500 + 250 + 450
      expect(s.disposableIncome, equals(1300.0)); // 3500 - 2200
      expect(s.savingsRate, closeTo(12.86, 0.01)); // (450 / 3500) * 100
    });

    test('handles zero income and negative disposable income cleanly', () {
      final entries = [
        const ItemEntry(id: 1, itemId: 2, periodKey: '2026-03', amount: 1000.0, extraPayment: 0.0),
      ];

      final summaries = service.computePeriodSummaries(
        entries: entries,
        items: items,
        categories: categories,
        sortedPeriodKeys: ['2026-03'],
      );

      final s = summaries.first;
      expect(s.totalIncome, equals(0.0));
      expect(s.totalExpenses, equals(1000.0));
      expect(s.totalOutflows, equals(1000.0));
      expect(s.disposableIncome, equals(-1000.0));
      expect(s.savingsRate, equals(0.0));
    });
  });

  group('AnalyticsEngineService - Timeframe Filtering', () {
    final summaries = List.generate(
      12,
      (i) => PeriodMetricSummary(
        periodKey: '2026-${(i + 1).toString().padLeft(2, '0')}',
        displayLabel: 'Period ${i + 1}',
        totalIncome: 3000.0,
        totalExpenses: 1500.0,
      ),
    );

    test('filters 3 months timeframe to last 3 periods', () {
      final filtered = service.filterByTimeframe(
        allSummaries: summaries,
        timeframe: AnalyticsTimeframe.threeMonths,
      );
      expect(filtered.length, equals(3));
      expect(filtered.map((s) => s.periodKey).toList(), equals(['2026-10', '2026-11', '2026-12']));
    });

    test('filters 6 months timeframe to last 6 periods', () {
      final filtered = service.filterByTimeframe(
        allSummaries: summaries,
        timeframe: AnalyticsTimeframe.sixMonths,
      );
      expect(filtered.length, equals(6));
      expect(filtered.first.periodKey, equals('2026-07'));
      expect(filtered.last.periodKey, equals('2026-12'));
    });

    test('filters 1 year timeframe to last 12 periods', () {
      final filtered = service.filterByTimeframe(
        allSummaries: summaries,
        timeframe: AnalyticsTimeframe.oneYear,
      );
      expect(filtered.length, equals(12));
    });

    test('returns all periods for allTime', () {
      final filtered = service.filterByTimeframe(
        allSummaries: summaries,
        timeframe: AnalyticsTimeframe.allTime,
      );
      expect(filtered.length, equals(12));
    });

    test('handles fewer periods than timeframe window', () {
      final shortList = summaries.take(2).toList();
      final filtered = service.filterByTimeframe(
        allSummaries: shortList,
        timeframe: AnalyticsTimeframe.sixMonths,
      );
      expect(filtered.length, equals(2));
    });
  });

  group('AnalyticsEngineService - Category Breakdown', () {
    final categories = [
      const Category(id: 1, trackerId: 1, name: 'Income', categoryType: 'income', sortOrder: 0),
      const Category(id: 2, trackerId: 1, name: 'Household', categoryType: 'expense', sortOrder: 1),
      const Category(id: 3, trackerId: 1, name: 'Personal', categoryType: 'expense', sortOrder: 2),
      const Category(id: 4, trackerId: 1, name: 'Debts', categoryType: 'debt', sortOrder: 3),
    ];

    final items = [
      const FinanceItem(id: 1, categoryId: 1, name: 'Salary', isArchived: false),
      const FinanceItem(id: 2, categoryId: 2, name: 'Rent', isArchived: false),
      const FinanceItem(id: 3, categoryId: 3, name: 'Hobbies', isArchived: false),
      const FinanceItem(id: 4, categoryId: 4, name: 'Loan', isArchived: false),
    ];

    test('computes spending breakdown excluding income', () {
      final entries = [
        const ItemEntry(id: 1, itemId: 1, periodKey: '2026-01', amount: 3000.0, extraPayment: 0.0),
        const ItemEntry(id: 2, itemId: 2, periodKey: '2026-01', amount: 800.0, extraPayment: 0.0),
        const ItemEntry(id: 3, itemId: 3, periodKey: '2026-01', amount: 200.0, extraPayment: 0.0),
      ];

      final breakdowns = service.computeCategoryBreakdowns(
        periodKeys: ['2026-01'],
        entries: entries,
        items: items,
        categories: categories,
      );

      // Outflows: 800 + 200 = 1000
      expect(breakdowns.length, equals(2));
      final household = breakdowns.firstWhere((b) => b.categoryName == 'Household');
      expect(household.totalAmount, equals(800.0));
      expect(household.percentage, equals(80.0));

      final personal = breakdowns.firstWhere((b) => b.categoryName == 'Personal');
      expect(personal.totalAmount, equals(200.0));
      expect(personal.percentage, equals(20.0));
    });
  });

  group('AnalyticsEngineService - Debt & Labels', () {
    test('computes remaining debt principal minus total payments', () {
      final debts = [
        const DebtMetadataData(id: 1, itemId: 10, totalPrincipal: 5000.0, interestRate: 0.0),
        const DebtMetadataData(id: 2, itemId: 11, totalPrincipal: 2000.0, interestRate: 0.0),
      ];

      final items = [
        const FinanceItem(id: 10, categoryId: 4, name: 'Car Loan', isArchived: false),
        const FinanceItem(id: 11, categoryId: 4, name: 'Credit Card', isArchived: false),
      ];

      final entries = [
        const ItemEntry(id: 1, itemId: 10, periodKey: '2026-01', amount: 200.0, extraPayment: 50.0),
        const ItemEntry(id: 2, itemId: 10, periodKey: '2026-02', amount: 200.0, extraPayment: 0.0),
        const ItemEntry(id: 3, itemId: 11, periodKey: '2026-01', amount: 100.0, extraPayment: 0.0),
      ];

      final remaining = service.computeRemainingDebt(
        debtMetadataList: debts,
        entries: entries,
        items: items,
      );

      // Total principal: 7000. Total payments: (250 + 200) + 100 = 550.
      // Remaining: 7000 - 550 = 6450
      expect(remaining, equals(6450.0));
    });

    test('formats period label friendly (e.g. 2026-03 -> Mar 26)', () {
      expect(AnalyticsEngineService.formatPeriodLabel('2026-03'), equals('Mar 26'));
      expect(AnalyticsEngineService.formatPeriodLabel('2025-12'), equals('Dec 25'));
    });
  });
}
