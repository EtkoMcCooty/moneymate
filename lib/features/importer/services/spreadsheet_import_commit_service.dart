import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../models/import_workflow_models.dart';
import '../models/parsed_spreadsheet.dart';

/// Provider for [SpreadsheetImportCommitService].
final spreadsheetImportCommitServiceProvider =
    Provider<SpreadsheetImportCommitService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SpreadsheetImportCommitService(db);
});

/// Service that atomically commits parsed spreadsheet rows, line items,
/// recurring due days, and monthly entries into the local Drift SQLite database.
class SpreadsheetImportCommitService {
  final AppDatabase _db;

  SpreadsheetImportCommitService(this._db);

  /// Executes an atomic transaction persisting [mappings] and their [periodHeaders]
  /// for the specified [trackerId].
  ///
  /// Guarantees that if any constraint or SQL error occurs, the entire batch
  /// is rolled back to prevent partial, orphaned, or corrupted data.
  Future<ImportSummaryResult> commitImport({
    required int trackerId,
    required List<ImportRowMapping> mappings,
    required List<ParsedPeriodHeader> periodHeaders,
    bool replaceExisting = true,
  }) async {
    return _db.transaction<ImportSummaryResult>(() async {
      // 1. Fetch existing categories for tracker
      final existingCategories = await (_db.select(_db.categories)
            ..where((c) => c.trackerId.equals(trackerId)))
          .get();

      final categoryCache = <String, int>{};
      for (final cat in existingCategories) {
        categoryCache[cat.name.toLowerCase()] = cat.id;
      }

      // Filter out excluded items
      final activeMappings = mappings.where((m) => !m.isExcluded).toList();
      final affectedCategoryIds = <int>{};
      var insertedItemsCount = 0;
      var insertedEntriesCount = 0;

      // 2. Ensure all needed categories exist
      for (final mapping in activeMappings) {
        final lowerCat = mapping.targetCategoryName.trim().toLowerCase();
        if (!categoryCache.containsKey(lowerCat)) {
          final newCatId = await _db.into(_db.categories).insert(
                CategoriesCompanion.insert(
                  trackerId: trackerId,
                  name: mapping.targetCategoryName.trim(),
                  categoryType: mapping.targetCategoryType,
                  sortOrder: Value(categoryCache.length),
                ),
              );
          categoryCache[lowerCat] = newCatId;
        }
      }

      // 3. If replacing existing items, clean up previous items and entries for tracker
      if (replaceExisting) {
        final allCatIds = categoryCache.values.toList();
        final existingTrackerItems = await (_db.select(_db.financeItems)
              ..where((i) => i.categoryId.isIn(allCatIds)))
            .get();
        final existingItemIds = existingTrackerItems.map((i) => i.id).toList();

        if (existingItemIds.isNotEmpty) {
          await (_db.delete(_db.itemEntries)
                ..where((e) => e.itemId.isIn(existingItemIds)))
              .go();
          await (_db.delete(_db.debtMetadata)
                ..where((d) => d.itemId.isIn(existingItemIds)))
              .go();
          await (_db.delete(_db.financeItems)
                ..where((i) => i.id.isIn(existingItemIds)))
              .go();
        }
      }

      // Cache existing items by categoryId::cleanName
      final allCatIds = categoryCache.values.toList();
      final existingTrackerItems = await (_db.select(_db.financeItems)
            ..where((i) => i.categoryId.isIn(allCatIds)))
          .get();
      final existingItemsByCatAndName = <String, FinanceItem>{};
      for (final it in existingTrackerItems) {
        existingItemsByCatAndName['${it.categoryId}::${it.name.trim().toLowerCase()}'] = it;
      }

      // 4. Insert or update line items, debts, and period entries
      for (final mapping in activeMappings) {
        final lowerCat = mapping.targetCategoryName.trim().toLowerCase();
        final categoryId = categoryCache[lowerCat]!;
        affectedCategoryIds.add(categoryId);

        final itemKey = '$categoryId::${mapping.cleanName.trim().toLowerCase()}';
        int itemId;

        if (existingItemsByCatAndName.containsKey(itemKey)) {
          final existingItem = existingItemsByCatAndName[itemKey]!;
          itemId = existingItem.id;
          if (mapping.dueDay != null && mapping.dueDay != existingItem.dueDay) {
            await (_db.update(_db.financeItems)..where((i) => i.id.equals(itemId)))
                .write(FinanceItemsCompanion(dueDay: Value(mapping.dueDay)));
          }
        } else {
          itemId = await _db.into(_db.financeItems).insert(
                FinanceItemsCompanion.insert(
                  categoryId: categoryId,
                  name: mapping.cleanName.trim(),
                  dueDay: Value(mapping.dueDay),
                ),
              );
          existingItemsByCatAndName[itemKey] = FinanceItem(
            id: itemId,
            categoryId: categoryId,
            name: mapping.cleanName.trim(),
            dueDay: mapping.dueDay,
            isArchived: false,
          );
        }
        insertedItemsCount++;

        if (mapping.isDebt) {
          final existingDebt = await (_db.select(_db.debtMetadata)
                ..where((d) => d.itemId.equals(itemId)))
              .getSingleOrNull();
          if (existingDebt == null) {
            await _db.into(_db.debtMetadata).insert(
                  DebtMetadataCompanion.insert(
                    itemId: itemId,
                    totalPrincipal: const Value(0.0),
                    interestRate: const Value(0.0),
                  ),
                );
          }
        }

        // Insert monthly period entries
        for (final period in periodHeaders) {
          final cell = mapping.periodValues[period.normalizedKey] ??
              mapping.periodValues[period.rawHeader];
          if (cell != null && cell.amount != null) {
            var safePeriodKey = period.normalizedKey.trim();
            if (safePeriodKey.length != 7 ||
                !RegExp(r'^\d{4}-\d{2}$').hasMatch(safePeriodKey)) {
              final now = DateTime.now();
              safePeriodKey =
                  '${now.year}-${now.month.toString().padLeft(2, '0')}';
            }

            await _db.into(_db.itemEntries).insert(
                  ItemEntriesCompanion.insert(
                    itemId: itemId,
                    periodKey: safePeriodKey,
                    amount: Value(cell.amount!),
                    extraPayment: const Value(0.0),
                    note: Value(cell.note),
                  ),
                  mode: InsertMode.insertOrReplace,
                );
            insertedEntriesCount++;
          }
        }
      }

      final uniquePeriodKeys =
          periodHeaders.map((p) => p.normalizedKey).toSet().toList()..sort();

      return ImportSummaryResult(
        itemsCount: insertedItemsCount,
        entriesCount: insertedEntriesCount,
        categoriesCount: affectedCategoryIds.length,
        periodKeys: uniquePeriodKeys,
      );
    });
  }
}
