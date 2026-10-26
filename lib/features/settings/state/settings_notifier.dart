import 'package:drift/drift.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../models/settings_state.dart';

/// Notifier managing user tracker settings, pay cycle start day, currency preferences,
/// and spending categories with local Drift persistence.
class SettingsNotifier extends StateNotifier<SettingsState> {
  final AppDatabase _db;

  SettingsNotifier(this._db) : super(const SettingsState(isLoading: true));

  /// Loads current tracker settings and categories, seeding defaults if first launch.
  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      var tracker = await (_db.select(_db.trackers)..limit(1)).getSingleOrNull();

      if (tracker == null) {
        // First launch: initialize default tracker and standard categories
        final trackerId = await _db.into(_db.trackers).insert(
              TrackersCompanion.insert(
                name: 'My Tracker',
                cycleStartDay: const Value(15),
                currencySymbol: const Value('£'),
                createdAt: Value(DateTime.now()),
                updatedAt: Value(DateTime.now()),
              ),
            );

        const defaultCategories = [
          ('Income', 'income', 0),
          ('Household', 'expense', 1),
          ('Personal', 'expense', 2),
          ('Other', 'expense', 3),
          ('Debts', 'debt', 4),
          ('Savings', 'savings', 5),
          ('Investments', 'investment', 6),
        ];

        for (final (name, type, order) in defaultCategories) {
          await _db.into(_db.categories).insert(
                CategoriesCompanion.insert(
                  trackerId: trackerId,
                  name: name,
                  categoryType: type,
                  sortOrder: Value(order),
                ),
              );
        }

        tracker = await (_db.select(_db.trackers)..where((t) => t.id.equals(trackerId))).getSingle();
      }

      final categories = await (_db.select(_db.categories)
            ..where((c) => c.trackerId.equals(tracker!.id))
            ..orderBy([(c) => OrderingTerm(expression: c.sortOrder)]))
          .get();

      state = SettingsState(
        tracker: tracker,
        categories: categories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load settings: $e',
      );
    }
  }

  /// Updates the pay cycle start day (1 to 31).
  Future<void> updateCycleStartDay(int day) async {
    if (state.tracker == null) return;
    try {
      await (_db.update(_db.trackers)..where((t) => t.id.equals(state.tracker!.id))).write(
        TrackersCompanion(
          cycleStartDay: Value(day),
          updatedAt: Value(DateTime.now()),
        ),
      );
      final updatedTracker = await (_db.select(_db.trackers)
            ..where((t) => t.id.equals(state.tracker!.id)))
          .getSingle();

      state = state.copyWith(tracker: updatedTracker);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to update pay cycle: $e');
    }
  }

  /// Updates the default currency symbol (e.g. £, $, €).
  Future<void> updateCurrencySymbol(String symbol) async {
    if (state.tracker == null) return;
    try {
      await (_db.update(_db.trackers)..where((t) => t.id.equals(state.tracker!.id))).write(
        TrackersCompanion(
          currencySymbol: Value(symbol),
          updatedAt: Value(DateTime.now()),
        ),
      );
      final updatedTracker = await (_db.select(_db.trackers)
            ..where((t) => t.id.equals(state.tracker!.id)))
          .getSingle();

      state = state.copyWith(tracker: updatedTracker);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to update currency: $e');
    }
  }

  /// Adds a new category to the active tracker.
  Future<void> addCategory({
    required String name,
    required String categoryType,
  }) async {
    if (state.tracker == null) return;
    try {
      final nextOrder = state.categories.isEmpty ? 0 : state.categories.length;
      await _db.into(_db.categories).insert(
            CategoriesCompanion.insert(
              trackerId: state.tracker!.id,
              name: name,
              categoryType: categoryType,
              sortOrder: Value(nextOrder),
            ),
          );

      final categories = await (_db.select(_db.categories)
            ..where((c) => c.trackerId.equals(state.tracker!.id))
            ..orderBy([(c) => OrderingTerm(expression: c.sortOrder)]))
          .get();

      state = state.copyWith(categories: categories);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to add category: $e');
    }
  }

  /// Deletes a category by [categoryId].
  Future<void> deleteCategory(int categoryId) async {
    if (state.tracker == null) return;
    try {
      await (_db.delete(_db.categories)..where((c) => c.id.equals(categoryId))).go();

      final categories = await (_db.select(_db.categories)
            ..where((c) => c.trackerId.equals(state.tracker!.id))
            ..orderBy([(c) => OrderingTerm(expression: c.sortOrder)]))
          .get();

      state = state.copyWith(categories: categories);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to delete category: $e');
    }
  }
}

/// Provider exposing the [SettingsNotifier].
final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final notifier = SettingsNotifier(db);
  notifier.loadSettings();
  return notifier;
});
