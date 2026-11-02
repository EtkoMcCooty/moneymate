import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/core/database/app_database.dart';
import 'package:moneymate/core/database/database_provider.dart';
import 'package:moneymate/features/tracker/state/tracker_ledger_notifier.dart';
import 'package:moneymate/features/tracker/views/entry_editor_dialog.dart';
import 'package:moneymate/features/tracker/views/tracker_screen.dart';

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

  group('TrackerLedgerNotifier - In-Line Entry & Note Updates', () {
    test('creates new item entry with amount, extra payment, and context note', () async {
      final household =
          notifier.state.sections.firstWhere((s) => s.category.name == 'Household');

      await notifier.addItem(
        categoryId: household.category.id,
        name: 'Rent',
        dueDay: 29,
      );

      final rentItem = notifier.state.sections
          .firstWhere((s) => s.category.id == household.category.id)
          .items
          .firstWhere((i) => i.item.name == 'Rent');

      await notifier.updateEntry(
        itemId: rentItem.item.id,
        amount: 850.0,
        note: '[1] Half Nursery fees included',
      );

      final updatedHousehold = notifier.state.sections
          .firstWhere((s) => s.category.id == household.category.id);
      final updatedRent = updatedHousehold.items.firstWhere((i) => i.item.name == 'Rent');

      expect(updatedRent.amount, equals(850.0));
      expect(updatedRent.note, equals('[1] Half Nursery fees included'));
      expect(updatedHousehold.totalAmount, equals(850.0));

      // Check database persistence
      final persisted = await (db.select(db.itemEntries)
            ..where((e) =>
                e.itemId.equals(rentItem.item.id) & e.periodKey.equals('2026-01')))
          .getSingle();
      expect(persisted.amount, equals(850.0));
      expect(persisted.note, equals('[1] Half Nursery fees included'));
    });

    test('updates existing entry and recalculates totals and disposable income', () async {
      final income =
          notifier.state.sections.firstWhere((s) => s.category.name == 'Income');
      final household =
          notifier.state.sections.firstWhere((s) => s.category.name == 'Household');

      await notifier.addItem(categoryId: income.category.id, name: 'Salary');
      await notifier.addItem(categoryId: household.category.id, name: 'Bills');

      final salary = notifier.state.sections
          .firstWhere((s) => s.category.id == income.category.id)
          .items
          .firstWhere((i) => i.item.name == 'Salary');
      final bills = notifier.state.sections
          .firstWhere((s) => s.category.id == household.category.id)
          .items
          .firstWhere((i) => i.item.name == 'Bills');

      // Set initial salary to £3,000
      await notifier.updateEntry(itemId: salary.item.id, amount: 3000.0);
      expect(notifier.state.summary.totalIncome, equals(3000.0));
      expect(notifier.state.summary.disposableIncome, equals(3000.0));

      // Set initial bills to £1,000
      await notifier.updateEntry(itemId: bills.item.id, amount: 1000.0);
      expect(notifier.state.summary.totalExpenses, equals(1000.0));
      expect(notifier.state.summary.disposableIncome, equals(2000.0));

      // Update bills entry to £1,200 with note
      await notifier.updateEntry(
        itemId: bills.item.id,
        amount: 1200.0,
        note: 'Council tax increase',
      );
      expect(notifier.state.summary.totalExpenses, equals(1200.0));
      expect(notifier.state.summary.disposableIncome, equals(1800.0));
    });

    test('debt extra payments are included in debt totals and disposable income, and can be cleared', () async {
      final income =
          notifier.state.sections.firstWhere((s) => s.category.name == 'Income');
      final debts =
          notifier.state.sections.firstWhere((s) => s.category.name == 'Debts');

      await notifier.addItem(categoryId: income.category.id, name: 'Salary');
      await notifier.addItem(categoryId: debts.category.id, name: 'Credit Card');

      final salary = notifier.state.sections
          .firstWhere((s) => s.category.id == income.category.id)
          .items
          .firstWhere((i) => i.item.name == 'Salary');
      final debtItem = notifier.state.sections
          .firstWhere((s) => s.category.id == debts.category.id)
          .items
          .firstWhere((i) => i.item.name == 'Credit Card');

      await notifier.updateEntry(itemId: salary.item.id, amount: 2000.0);
      // Min payment: 150, extra payment: 50 -> total paid: 200
      await notifier.updateEntry(
        itemId: debtItem.item.id,
        amount: 150.0,
        extraPayment: 50.0,
      );

      final updatedDebts = notifier.state.sections
          .firstWhere((s) => s.category.id == debts.category.id);
      expect(updatedDebts.totalAmount, equals(200.0));
      expect(notifier.state.summary.totalDebtPayments, equals(200.0));
      expect(notifier.state.summary.disposableIncome, equals(1800.0));

      // Clear extra payment (pass 0.0)
      await notifier.updateEntry(
        itemId: debtItem.item.id,
        amount: 150.0,
        extraPayment: 0.0,
      );

      final clearedDebts = notifier.state.sections
          .firstWhere((s) => s.category.id == debts.category.id);
      expect(clearedDebts.totalAmount, equals(150.0));
      expect(notifier.state.summary.totalDebtPayments, equals(150.0));
      expect(notifier.state.summary.disposableIncome, equals(1850.0));
    });
  });

  group('TrackerScreen - Entry & Note Editing UI Integration', () {
    testWidgets('opens EntryEditorDialog on tapping item amount and updates entry', (tester) async {
      final household =
          notifier.state.sections.firstWhere((s) => s.category.name == 'Household');

      await notifier.addItem(
        categoryId: household.category.id,
        name: 'Electric & Gas',
        dueDay: 15,
      );

      final item = notifier.state.sections
          .firstWhere((s) => s.category.id == household.category.id)
          .items
          .firstWhere((i) => i.item.name == 'Electric & Gas');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            trackerLedgerNotifierProvider.overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(
            home: TrackerScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure Household section is expanded
      expect(find.text('Electric & Gas'), findsOneWidget);
      expect(find.text('£0.00'), findsWidgets);

      // Tap on the entry edit action or amount for Electric & Gas
      final entryButton = find.byKey(Key('edit_entry_${item.item.id}'));
      expect(entryButton, findsOneWidget);
      await tester.ensureVisible(entryButton);
      await tester.pumpAndSettle();
      await tester.tap(entryButton);
      await tester.pumpAndSettle();

      // Verify EntryEditorDialog is shown
      expect(find.byType(EntryEditorDialog), findsOneWidget);
      expect(find.text('Edit Entry'), findsOneWidget);

      // Enter amount
      await tester.enterText(find.byKey(const Key('entry_amount_field')), '145.50');
      // Enter note
      await tester.enterText(
          find.byKey(const Key('entry_note_field')), '[1] Winter heating adjustment');

      // Tap Save
      await tester.tap(find.byKey(const Key('entry_save_button')));
      await tester.pumpAndSettle();

      // Verify dialog is dismissed
      expect(find.byType(EntryEditorDialog), findsNothing);

      // Verify updated amount is rendered
      expect(find.text('£145.50'), findsWidgets);
      // Verify note is rendered in subtitle
      expect(find.textContaining('Winter heating adjustment'), findsOneWidget);
    });
  });
}
