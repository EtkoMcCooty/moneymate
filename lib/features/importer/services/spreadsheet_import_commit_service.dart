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

      // 3. Insert line items, debts, and period entries
      for (final mapping in activeMappings) {
        final lowerCat = mapping.targetCategoryName.trim().toLowerCase();
        final categoryId = categoryCache[lowerCat]!;
        affectedCategoryIds.add(categoryId);

        final itemId = await _db.into(_db.financeItems).insert(
              FinanceItemsCompanion.insert(
                categoryId: categoryId,
                name: mapping.cleanName.trim(),
                dueDay: Value(mapping.dueDay),
              ),
            );
        insertedItemsCount++;

        if (mapping.isDebt) {
          await _db.into(_db.debtMetadata).insert(
                DebtMetadataCompanion.insert(
                  itemId: itemId,
                  totalPrincipal: const Value(0.0),
                  interestRate: const Value(0.0),
                ),
              );
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
