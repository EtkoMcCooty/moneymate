import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/core/database/app_database.dart';
import 'package:moneymate/features/importer/models/import_workflow_models.dart';
import 'package:moneymate/features/importer/models/parsed_spreadsheet.dart';
import 'package:moneymate/features/importer/services/smart_matcher_service.dart';
import 'package:moneymate/features/importer/services/spreadsheet_import_commit_service.dart';
import 'package:moneymate/features/importer/services/spreadsheet_parser_service.dart';

Uint8List createSpreadsheetWithInColumnSections() {
  final excel = Excel.createExcel();
  excel.rename('Sheet1', '2026');
  final sheet = excel['2026'];

  // Row 1: Header row with pay cycle date span
  sheet.appendRow([
    TextCellValue('Time Period is 15th (prev month) - 14th (cur month)'),
    TextCellValue('Oct 15th - Nov 14th'),
    TextCellValue('Nov 15th - Dec 14th'),
  ]);

  // Row 2: Empty
  sheet.appendRow([TextCellValue('')]);

  // Row 3: Wage
  sheet.appendRow([
    TextCellValue('Wage'),
    const DoubleCellValue(2311.87),
    const DoubleCellValue(2311.87),
  ]);

  // Row 4: Total Income (should be skipped!)
  sheet.appendRow([
    TextCellValue('Total Income'),
    const DoubleCellValue(2311.87),
    const DoubleCellValue(2311.87),
  ]);

  // Row 5: Household (in-column section header, no amounts!)
  sheet.appendRow([
    TextCellValue('Household'),
    null,
    null,
  ]);

  // Row 6: Rent (1st)
  sheet.appendRow([
    TextCellValue('Rent (1st)'),
    const DoubleCellValue(1100.0),
    const DoubleCellValue(1100.0),
  ]);

  // Row 7: Internet (6th)
  sheet.appendRow([
    TextCellValue('Internet (6th)'),
    const DoubleCellValue(34.99),
    const DoubleCellValue(34.99),
  ]);

  // Row 8: Household Total (should be skipped!)
  sheet.appendRow([
    TextCellValue('Household Total'),
    const DoubleCellValue(1134.99),
    const DoubleCellValue(1134.99),
  ]);

  // Row 9: Debts (in-column section header)
  sheet.appendRow([
    TextCellValue('Debts'),
    null,
    null,
  ]);

  // Row 10: Debt Left to Pay (should be in Debts category, NOT Income!)
  sheet.appendRow([
    TextCellValue('Debt Left to Pay'),
    const DoubleCellValue(0.0),
    const DoubleCellValue(0.0),
  ]);

  return Uint8List.fromList(excel.encode()!);
}

void main() {
  late SpreadsheetParserService parser;
  late AppDatabase db;
  late SpreadsheetImportCommitService commitService;
  late SmartMatcherService matcher;

  setUp(() async {
    parser = SpreadsheetParserService();
    db = AppDatabase(NativeDatabase.memory());
    commitService = SpreadsheetImportCommitService(db);
    matcher = SmartMatcherService();

    await db.into(db.trackers).insert(
          TrackersCompanion.insert(
            name: 'Personal Tracker',
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

  group('In-Column Sections & Clean Import Tests', () {
    test('parser identifies in-column category section headers and skips totals', () async {
      final bytes = createSpreadsheetWithInColumnSections();
      final parsed = await parser.parseExcelBytes(bytes, fileName: 'tracker_2026.xlsx');

      expect(parsed.sheets.length, equals(1));
      final sheet = parsed.sheets.first;

      // Assert period headers normalized correctly
      expect(sheet.periodHeaders[0].normalizedKey, equals('2026-11')); // Oct 15 - Nov 14
      expect(sheet.periodHeaders[1].normalizedKey, equals('2026-12')); // Nov 15 - Dec 14

      // Labels present: Wage, Rent (1st), Internet (6th), Debt Left to Pay
      final labels = sheet.rows.map((r) => r.rawLabel).toList();
      expect(labels, contains('Wage'));
      expect(labels, contains('Rent (1st)'));
      expect(labels, contains('Internet (6th)'));
      expect(labels, contains('Debt Left to Pay'));

      // Summary rows must be skipped!
      expect(labels, isNot(contains('Total Income')));
      expect(labels, isNot(contains('Household Total')));

      // In-column section header rows must NOT be items themselves!
      expect(labels, isNot(contains('Household')));
      expect(labels, isNot(contains('Debts')));

      // Rows under Household must have rawCategory set to 'Household'
      final rentRow = sheet.rows.firstWhere((r) => r.rawLabel.contains('Rent'));
      expect(rentRow.rawCategory, equals('Household'));

      final internetRow = sheet.rows.firstWhere((r) => r.rawLabel.contains('Internet'));
      expect(internetRow.rawCategory, equals('Household'));

      // Debt Left to Pay must have rawCategory set to 'Debts'
      final debtRow = sheet.rows.firstWhere((r) => r.rawLabel.contains('Debt Left to Pay'));
      expect(debtRow.rawCategory, equals('Debts'));

      // And SmartMatcher should categorize it as debt, NOT income
      final match = matcher.matchLabel(debtRow.rawLabel, rawCategoryHint: debtRow.rawCategory);
      expect(match.suggestedCategoryType, equals('debt'));
      expect(match.suggestedCategoryName, equals('Debts'));
    });

    test('SpreadsheetImportCommitService replaces existing items on clean import', () async {
      final tracker = await db.select(db.trackers).getSingle();
      final catId = await db.into(db.categories).insert(
            CategoriesCompanion.insert(
              trackerId: tracker.id,
              name: 'Household',
              categoryType: 'expense',
            ),
          );

      // Pre-seed an old duplicate item from a previous buggy import
      final oldItemId = await db.into(db.financeItems).insert(
            FinanceItemsCompanion.insert(
              categoryId: catId,
              name: 'Rent',
              dueDay: const Value(29),
            ),
          );
      await db.into(db.itemEntries).insert(
            ItemEntriesCompanion.insert(
              itemId: oldItemId,
              periodKey: '2026-12',
              amount: const Value(550.0),
            ),
          );

      // Verify old item exists
      var items = await db.select(db.financeItems).get();
      expect(items.length, equals(1));
      expect(items.first.dueDay, equals(29));

      // Now run clean commitImport with new 2026 data (Rent on 1st for £1100)
      final mappings = [
        ImportRowMapping(
          rowIndex: 0,
          originalLabel: 'Rent (1st)',
          cleanName: 'Rent',
          dueDay: 1,
          targetCategoryName: 'Household',
          targetCategoryType: 'expense',
          targetCategoryId: catId,
          periodValues: {
            '2026-12': const ParsedCell(amount: 1100.0, rawValue: '1100.0'),
          },
        ),
      ];

      final summary = await commitService.commitImport(
        trackerId: tracker.id,
        mappings: mappings,
        periodHeaders: [
          const ParsedPeriodHeader(rawHeader: 'Nov 15th - Dec 14th', normalizedKey: '2026-12', columnIndex: 2),
        ],
        replaceExisting: true,
      );

      expect(summary.itemsCount, equals(1));

      // Assert only 1 Rent item exists (no duplicate!) with updated dueDay 1
      items = await db.select(db.financeItems).get();
      expect(items.length, equals(1));
      expect(items.first.name, equals('Rent'));
      expect(items.first.dueDay, equals(1));

      // Assert entry has 1100.0 (not 550.0)
      final entries = await db.select(db.itemEntries).get();
      expect(entries.length, equals(1));
      expect(entries.first.amount, equals(1100.0));
      expect(entries.first.periodKey, equals('2026-12'));
    });
  });
}
