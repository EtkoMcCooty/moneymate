import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/core/database/app_database.dart';
import 'package:moneymate/features/tracker/state/tracker_ledger_notifier.dart';

void main() {
  late AppDatabase db;
  late TrackerLedgerNotifier notifier;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    notifier = TrackerLedgerNotifier(db);
    await notifier.loadLedger(periodKey: '2026-01');
  });

  tearDown(() async {
    await db.close();
  });

  group('TrackerLedgerNotifier', () {
    test('loads categories and initializes with zero balances when empty', () async {
      final state = notifier.state;
      expect(state.isLoading, isFalse);
      expect(state.selectedPeriodKey, equals('2026-01'));
      expect(state.sections.length, equals(7));

      final sectionNames = state.sections.map((s) => s.category.name).toList();
      expect(sectionNames, containsAll([
        'Income',
        'Household',
        'Personal',
        'Other',
        'Debts',
        'Savings',
        'Investments',
      ]));

      // Check summary calculations with empty items
      expect(state.summary.totalIncome, equals(0.0));
      expect(state.summary.totalExpenses, equals(0.0));
      expect(state.summary.totalDebtPayments, equals(0.0));
      expect(state.summary.totalSavingsAndInvestments, equals(0.0));
      expect(state.summary.disposableIncome, equals(0.0));
    });

    test('calculates correct summary totals and disposable income with items and entries', () async {
      final state = notifier.state;
      final incomeCat = state.sections.firstWhere((s) => s.category.name == 'Income').category;
      final householdCat = state.sections.firstWhere((s) => s.category.name == 'Household').category;
      final debtsCat = state.sections.firstWhere((s) => s.category.name == 'Debts').category;
      final savingsCat = state.sections.firstWhere((s) => s.category.name == 'Savings').category;

      // Insert line items
      final salaryItemId = await db.into(db.financeItems).insert(
            FinanceItemsCompanion.insert(categoryId: incomeCat.id, name: 'Monthly Salary'),
          );
      final rentItemId = await db.into(db.financeItems).insert(
            FinanceItemsCompanion.insert(categoryId: householdCat.id, name: 'Rent'),
          );
      final loanItemId = await db.into(db.financeItems).insert(
            FinanceItemsCompanion.insert(categoryId: debtsCat.id, name: 'Bank Loan'),
          );
      final isaItemId = await db.into(db.financeItems).insert(
            FinanceItemsCompanion.insert(categoryId: savingsCat.id, name: 'ISA Savings'),
          );

      // Insert entries for period 2026-01
      await db.into(db.itemEntries).insert(
            ItemEntriesCompanion.insert(
              itemId: salaryItemId,
              periodKey: '2026-01',
              amount: const Value(3000.0),
            ),
          );
      await db.into(db.itemEntries).insert(
            ItemEntriesCompanion.insert(
              itemId: rentItemId,
              periodKey: '2026-01',
              amount: const Value(1200.0),
            ),
          );
      await db.into(db.itemEntries).insert(
            ItemEntriesCompanion.insert(
              itemId: loanItemId,
              periodKey: '2026-01',
              amount: const Value(200.0),
            ),
          );
      await db.into(db.itemEntries).insert(
            ItemEntriesCompanion.insert(
              itemId: isaItemId,
              periodKey: '2026-01',
              amount: const Value(300.0),
            ),
          );

      // Reload ledger
      await notifier.loadLedger(periodKey: '2026-01');

      final updatedState = notifier.state;
      expect(updatedState.summary.totalIncome, equals(3000.0));
      expect(updatedState.summary.totalExpenses, equals(1200.0));
      expect(updatedState.summary.totalDebtPayments, equals(200.0));
      expect(updatedState.summary.totalSavingsAndInvestments, equals(300.0));

      // Disposable Income = 3000 - (1200 + 200 + 300) = 1300.0
      expect(updatedState.summary.disposableIncome, equals(1300.0));
    });

    test('switches period and isolates monthly entry values', () async {
      final state = notifier.state;
      final incomeCat = state.sections.firstWhere((s) => s.category.name == 'Income').category;

      final salaryItemId = await db.into(db.financeItems).insert(
            FinanceItemsCompanion.insert(categoryId: incomeCat.id, name: 'Salary'),
          );

      // Entry in 2026-01: £3000
      await db.into(db.itemEntries).insert(
            ItemEntriesCompanion.insert(
              itemId: salaryItemId,
              periodKey: '2026-01',
              amount: const Value(3000.0),
            ),
          );

      // Entry in 2026-02: £3200
      await db.into(db.itemEntries).insert(
            ItemEntriesCompanion.insert(
              itemId: salaryItemId,
              periodKey: '2026-02',
              amount: const Value(3200.0),
            ),
          );

      await notifier.selectPeriod('2026-01');
      expect(notifier.state.summary.totalIncome, equals(3000.0));

      await notifier.selectPeriod('2026-02');
      expect(notifier.state.summary.totalIncome, equals(3200.0));
    });
  });
}
