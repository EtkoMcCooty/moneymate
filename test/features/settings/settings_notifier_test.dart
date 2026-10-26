import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/core/database/app_database.dart';
import 'package:moneymate/features/settings/state/settings_notifier.dart';

void main() {
  late AppDatabase db;
  late SettingsNotifier notifier;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    notifier = SettingsNotifier(db);
    await notifier.loadSettings();
  });

  tearDown(() async {
    await db.close();
  });

  group('SettingsNotifier', () {
    test('initializes with default tracker and default categories', () async {
      final state = notifier.state;
      expect(state.isLoading, isFalse);
      expect(state.tracker, isNotNull);
      expect(state.tracker!.cycleStartDay, equals(15));
      expect(state.tracker!.currencySymbol, equals('£'));

      // Check default categories seeded
      expect(state.categories.length, equals(7));
      final categoryNames = state.categories.map((c) => c.name).toList();
      expect(categoryNames, containsAll([
        'Income',
        'Household',
        'Personal',
        'Other',
        'Debts',
        'Savings',
        'Investments',
      ]));
    });

    test('updates pay cycle start day in state and database', () async {
      await notifier.updateCycleStartDay(1);

      expect(notifier.state.tracker!.cycleStartDay, equals(1));

      final persistedTracker = await (db.select(db.trackers)..where((t) => t.id.equals(notifier.state.tracker!.id))).getSingle();
      expect(persistedTracker.cycleStartDay, equals(1));
    });

    test('updates currency symbol in state and database', () async {
      await notifier.updateCurrencySymbol('\$');

      expect(notifier.state.tracker!.currencySymbol, equals('\$'));

      final persistedTracker = await (db.select(db.trackers)..where((t) => t.id.equals(notifier.state.tracker!.id))).getSingle();
      expect(persistedTracker.currencySymbol, equals('\$'));
    });

    test('adds a new category and persists it', () async {
      await notifier.addCategory(name: 'Subscriptions', categoryType: 'expense');

      expect(notifier.state.categories.any((c) => c.name == 'Subscriptions'), isTrue);

      final dbCategories = await db.select(db.categories).get();
      expect(dbCategories.any((c) => c.name == 'Subscriptions'), isTrue);
    });

    test('deletes a category and removes it from state and database', () async {
      final initialCount = notifier.state.categories.length;
      final categoryToDelete = notifier.state.categories.firstWhere((c) => c.name == 'Other');

      await notifier.deleteCategory(categoryToDelete.id);

      expect(notifier.state.categories.length, equals(initialCount - 1));
      expect(notifier.state.categories.any((c) => c.id == categoryToDelete.id), isFalse);

      final dbCategories = await db.select(db.categories).get();
      expect(dbCategories.any((c) => c.id == categoryToDelete.id), isFalse);
    });
  });
}
