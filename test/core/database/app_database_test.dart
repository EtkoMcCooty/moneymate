import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    // Open in-memory database for isolated unit testing
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('AppDatabase Foundation & Tables', () {
    test('creates and retrieves a tracker with default values', () async {
      final trackerId = await db.into(db.trackers).insert(
            TrackersCompanion.insert(
              name: 'My Personal Tracker',
              cycleStartDay: const Value(15),
              currencySymbol: const Value('£'),
              createdAt: Value(DateTime.now()),
              updatedAt: Value(DateTime.now()),
            ),
          );

      final tracker = await (db.select(db.trackers)..where((t) => t.id.equals(trackerId))).getSingle();
      expect(tracker.name, equals('My Personal Tracker'));
      expect(tracker.cycleStartDay, equals(15));
      expect(tracker.currencySymbol, equals('£'));
    });

    test('creates categories linked to tracker with ordering', () async {
      final trackerId = await db.into(db.trackers).insert(
            TrackersCompanion.insert(
              name: 'Household Tracker',
              cycleStartDay: const Value(1),
              currencySymbol: const Value('£'),
              createdAt: Value(DateTime.now()),
              updatedAt: Value(DateTime.now()),
            ),
          );

      await db.into(db.categories).insert(
            CategoriesCompanion.insert(
              trackerId: trackerId,
              name: 'Income',
              categoryType: 'income',
              sortOrder: const Value(1),
            ),
          );

      await db.into(db.categories).insert(
            CategoriesCompanion.insert(
              trackerId: trackerId,
              name: 'Household',
              categoryType: 'expense',
              sortOrder: const Value(2),
            ),
          );

      final categories = await (db.select(db.categories)
            ..where((c) => c.trackerId.equals(trackerId))
            ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
          .get();

      expect(categories.length, equals(2));
      expect(categories[0].name, equals('Income'));
      expect(categories[1].name, equals('Household'));
    });

    test('creates finance items with optional due dates and item entries with notes', () async {
      final trackerId = await db.into(db.trackers).insert(
            TrackersCompanion.insert(
              name: 'Main Tracker',
              cycleStartDay: const Value(15),
              currencySymbol: const Value('£'),
              createdAt: Value(DateTime.now()),
              updatedAt: Value(DateTime.now()),
            ),
          );

      final catId = await db.into(db.categories).insert(
            CategoriesCompanion.insert(
              trackerId: trackerId,
              name: 'Household Bills',
              categoryType: 'expense',
              sortOrder: const Value(1),
            ),
          );

      final itemId = await db.into(db.financeItems).insert(
            FinanceItemsCompanion.insert(
              categoryId: catId,
              name: 'Rent',
              dueDay: const Value(29),
            ),
          );

      final item = await (db.select(db.financeItems)..where((i) => i.id.equals(itemId))).getSingle();
      expect(item.name, equals('Rent'));
      expect(item.dueDay, equals(29));
      expect(item.isArchived, isFalse);

      final entryId = await db.into(db.itemEntries).insert(
            ItemEntriesCompanion.insert(
              itemId: itemId,
              periodKey: '2026-01',
              amount: const Value(850.00),
              note: const Value('[1] Rent paid early'),
            ),
          );

      final entry = await (db.select(db.itemEntries)..where((e) => e.id.equals(entryId))).getSingle();
      expect(entry.periodKey, equals('2026-01'));
      expect(entry.amount, equals(850.00));
      expect(entry.note, equals('[1] Rent paid early'));
    });

    test('manages app settings key-value entries', () async {
      await db.into(db.appSettings).insert(
            AppSettingsCompanion.insert(
              key: 'default_currency',
              value: 'GBP',
            ),
          );

      final setting = await (db.select(db.appSettings)..where((s) => s.key.equals('default_currency'))).getSingle();
      expect(setting.value, equals('GBP'));
    });
  });
}
