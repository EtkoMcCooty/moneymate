import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/core/database/app_database.dart';
import 'package:moneymate/core/database/database_provider.dart';
import 'package:moneymate/features/tracker/state/tracker_ledger_notifier.dart';
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

  group('TrackerLedgerNotifier - Item Management CRUD', () {
    test('creates new finance item with optional due day', () async {
      final householdSec =
          notifier.state.sections.firstWhere((s) => s.category.name == 'Household');

      await notifier.addItem(
        categoryId: householdSec.category.id,
        name: 'Council Tax',
        dueDay: 25,
      );

      final updatedHousehold =
          notifier.state.sections.firstWhere((s) => s.category.id == householdSec.category.id);
      expect(updatedHousehold.items.any((i) => i.item.name == 'Council Tax'), isTrue);

      final itemWithEntry =
          updatedHousehold.items.firstWhere((i) => i.item.name == 'Council Tax');
      expect(itemWithEntry.item.dueDay, equals(25));
      expect(itemWithEntry.item.isArchived, isFalse);

      // Verify database persistence
      final persisted = await (db.select(db.financeItems)
            ..where((i) => i.id.equals(itemWithEntry.item.id)))
          .getSingle();
      expect(persisted.name, equals('Council Tax'));
      expect(persisted.dueDay, equals(25));
    });

    test('creates debt item with principal balance and interest rate', () async {
      final debtsSec =
          notifier.state.sections.firstWhere((s) => s.category.name == 'Debts');

      await notifier.addItem(
        categoryId: debtsSec.category.id,
        name: 'Monzo Flex',
        dueDay: 29,
        totalPrincipal: 1200.0,
        interestRate: 19.9,
      );

      final updatedDebts =
          notifier.state.sections.firstWhere((s) => s.category.id == debtsSec.category.id);
      final debtItem = updatedDebts.items.firstWhere((i) => i.item.name == 'Monzo Flex');

      expect(debtItem.debtMetadata, isNotNull);
      expect(debtItem.debtMetadata!.totalPrincipal, equals(1200.0));
      expect(debtItem.debtMetadata!.interestRate, equals(19.9));

      // Verify database persistence
      final persistedMeta = await (db.select(db.debtMetadata)
            ..where((d) => d.itemId.equals(debtItem.item.id)))
          .getSingle();
      expect(persistedMeta.totalPrincipal, equals(1200.0));
      expect(persistedMeta.interestRate, equals(19.9));
    });

    test('updates existing finance item and debt metadata', () async {
      final debtsSec =
          notifier.state.sections.firstWhere((s) => s.category.name == 'Debts');

      await notifier.addItem(
        categoryId: debtsSec.category.id,
        name: 'Old Loan',
        dueDay: 10,
        totalPrincipal: 5000.0,
        interestRate: 5.0,
      );

      final created = notifier.state.sections
          .firstWhere((s) => s.category.id == debtsSec.category.id)
          .items
          .firstWhere((i) => i.item.name == 'Old Loan');

      await notifier.updateItem(
        itemId: created.item.id,
        categoryId: debtsSec.category.id,
        name: 'Consolidated Loan',
        dueDay: 15,
        totalPrincipal: 4500.0,
        interestRate: 4.5,
      );

      final updated = notifier.state.sections
          .firstWhere((s) => s.category.id == debtsSec.category.id)
          .items
          .firstWhere((i) => i.item.id == created.item.id);

      expect(updated.item.name, equals('Consolidated Loan'));
      expect(updated.item.dueDay, equals(15));
      expect(updated.debtMetadata?.totalPrincipal, equals(4500.0));
      expect(updated.debtMetadata?.interestRate, equals(4.5));
    });

    test('archives finance item so it is excluded from active ledger', () async {
      final personalSec =
          notifier.state.sections.firstWhere((s) => s.category.name == 'Personal');

      await notifier.addItem(
        categoryId: personalSec.category.id,
        name: 'Gym Membership',
        dueDay: 1,
      );

      final created = notifier.state.sections
          .firstWhere((s) => s.category.id == personalSec.category.id)
          .items
          .firstWhere((i) => i.item.name == 'Gym Membership');

      await notifier.archiveItem(created.item.id);

      final updatedPersonal = notifier.state.sections
          .firstWhere((s) => s.category.id == personalSec.category.id);
      expect(updatedPersonal.items.any((i) => i.item.id == created.item.id), isFalse);

      // Verify still exists in DB as archived
      final persisted = await (db.select(db.financeItems)
            ..where((i) => i.id.equals(created.item.id)))
          .getSingle();
      expect(persisted.isArchived, isTrue);
    });
  });

  group('TrackerScreen - Item CRUD UI Integration', () {
    testWidgets('allows adding an item to a category section via dialog', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
          ],
          child: const MaterialApp(
            home: TrackerScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Look for the "Add item" button in Household section
      final addBtnFinder = find.byKey(const Key('add_item_button_Household'));
      expect(addBtnFinder, findsOneWidget);

      await tester.ensureVisible(addBtnFinder);
      await tester.pumpAndSettle();
      await tester.tap(addBtnFinder);
      await tester.pumpAndSettle();

      // Modal dialog should open
      expect(find.text('Add New Item'), findsOneWidget);
      expect(find.byKey(const Key('item_name_field')), findsOneWidget);

      await tester.enterText(find.byKey(const Key('item_name_field')), 'Internet');
      await tester.enterText(find.byKey(const Key('item_due_day_field')), '18');

      await tester.tap(find.byKey(const Key('save_item_button')));
      await tester.pumpAndSettle();

      // Should now see Internet in the list
      expect(find.text('Internet'), findsOneWidget);
      expect(find.text('Due 18th of month'), findsOneWidget);
    });
  });
}
