import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/core/database/app_database.dart';
import 'package:moneymate/features/importer/models/import_workflow_models.dart';
import 'package:moneymate/features/importer/models/parsed_spreadsheet.dart';
import 'package:moneymate/features/importer/services/spreadsheet_import_commit_service.dart';

void main() {
  late AppDatabase db;
  late SpreadsheetImportCommitService commitService;
  late int trackerId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    commitService = SpreadsheetImportCommitService(db);

    // Seed default tracker
    trackerId = await db.into(db.trackers).insert(
          TrackersCompanion.insert(
            name: 'Test Budget',
            cycleStartDay: const Value(15),
            currencySymbol: const Value('£'),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('SpreadsheetImportCommitService', () {
    test('successfully imports categories, items, and period entries atomically', () async {
      final periodHeaders = [
        const ParsedPeriodHeader(rawHeader: 'Jan 26', normalizedKey: '2026-01', columnIndex: 1),
        const ParsedPeriodHeader(rawHeader: 'Feb 26', normalizedKey: '2026-02', columnIndex: 2),
      ];

      final mappings = [
        const ImportRowMapping(
          rowIndex: 1,
          originalLabel: 'Wage',
          cleanName: 'Wage',
          targetCategoryName: 'Income',
          targetCategoryType: 'income',
          periodValues: {
            'Jan 26': ParsedCell(amount: 2500.0, rawValue: '2500'),
            'Feb 26': ParsedCell(amount: 2550.0, rawValue: '2550', note: 'Bonus included'),
          },
        ),
        const ImportRowMapping(
          rowIndex: 2,
          originalLabel: 'Rent (29th)',
          cleanName: 'Rent',
          dueDay: 29,
          targetCategoryName: 'Household',
          targetCategoryType: 'expense',
          periodValues: {
            'Jan 26': ParsedCell(amount: 850.0, rawValue: '850'),
            'Feb 26': ParsedCell(amount: 850.0, rawValue: '850'),
          },
        ),
        const ImportRowMapping(
          rowIndex: 3,
          originalLabel: 'Credit Card',
          cleanName: 'Credit Card',
          isDebt: true,
          targetCategoryName: 'Debts',
          targetCategoryType: 'debt',
          periodValues: {
            'Jan 26': ParsedCell(amount: 150.0, rawValue: '150'),
            'Feb 26': ParsedCell(amount: 150.0, rawValue: '150'),
          },
        ),
      ];

      final summary = await commitService.commitImport(
        trackerId: trackerId,
        mappings: mappings,
        periodHeaders: periodHeaders,
      );

      expect(summary.itemsCount, equals(3));
      expect(summary.entriesCount, equals(6));
      expect(summary.categoriesCount, equals(3));
      expect(summary.periodKeys, equals(['2026-01', '2026-02']));

      // Verify categories created in Drift
      final categories = await db.select(db.categories).get();
      expect(categories.length, equals(3));
      expect(categories.map((c) => c.name), containsAll(['Income', 'Household', 'Debts']));

      // Verify items created
      final items = await db.select(db.financeItems).get();
      expect(items.length, equals(3));
      final rentItem = items.firstWhere((i) => i.name == 'Rent');
      expect(rentItem.dueDay, equals(29));

      // Verify debt metadata created
      final debts = await db.select(db.debtMetadata).get();
      expect(debts.length, equals(1));

      // Verify entries created
      final entries = await db.select(db.itemEntries).get();
      expect(entries.length, equals(6));
      final bonusEntry = entries.firstWhere((e) => e.note == 'Bonus included');
      expect(bonusEntry.periodKey, equals('2026-02'));
      expect(bonusEntry.amount, equals(2550.0));
    });

    test('skips excluded rows during atomic commit', () async {
      final periodHeaders = [
        const ParsedPeriodHeader(rawHeader: 'Jan 26', normalizedKey: '2026-01', columnIndex: 1),
      ];

      final mappings = [
        const ImportRowMapping(
          rowIndex: 1,
          originalLabel: 'Included Item',
          cleanName: 'Included Item',
          targetCategoryName: 'Personal',
          targetCategoryType: 'expense',
          isExcluded: false,
          periodValues: {
            'Jan 26': ParsedCell(amount: 50.0, rawValue: '50'),
          },
        ),
        const ImportRowMapping(
          rowIndex: 2,
          originalLabel: 'Excluded Item',
          cleanName: 'Excluded Item',
          targetCategoryName: 'Personal',
          targetCategoryType: 'expense',
          isExcluded: true,
          periodValues: {
            'Jan 26': ParsedCell(amount: 100.0, rawValue: '100'),
          },
        ),
      ];

      final summary = await commitService.commitImport(
        trackerId: trackerId,
        mappings: mappings,
        periodHeaders: periodHeaders,
      );

      expect(summary.itemsCount, equals(1));
      expect(summary.entriesCount, equals(1));

      final items = await db.select(db.financeItems).get();
      expect(items.length, equals(1));
      expect(items.first.name, equals('Included Item'));
    });
  });
}
