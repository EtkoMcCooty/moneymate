import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/features/importer/services/spreadsheet_parser_service.dart';

void main() {
  late SpreadsheetParserService parser;

  setUp(() {
    parser = SpreadsheetParserService();
  });

  group('SpreadsheetParserService - Numeric Parsing', () {
    test('parses clean integers and decimals', () {
      expect(parser.parseNumericAmount('1250'), 1250.0);
      expect(parser.parseNumericAmount('1250.50'), 1250.50);
      expect(parser.parseNumericAmount(450), 450.0);
      expect(parser.parseNumericAmount(450.75), 450.75);
    });

    test('parses amounts with GBP, USD, EUR symbols and comma separators', () {
      expect(parser.parseNumericAmount('£1,250.00'), 1250.0);
      expect(parser.parseNumericAmount('£45.50'), 45.50);
      expect(parser.parseNumericAmount(r'$2,300.99'), 2300.99);
      expect(parser.parseNumericAmount('€ 890.00'), 890.0);
    });

    test('handles negative values and accounting parentheses', () {
      expect(parser.parseNumericAmount('-150.00'), -150.0);
      expect(parser.parseNumericAmount('(150.00)'), -150.0);
      expect(parser.parseNumericAmount('£(50.25)'), -50.25);
    });

    test('returns null for empty, blank, or placeholder strings', () {
      expect(parser.parseNumericAmount(null), isNull);
      expect(parser.parseNumericAmount(''), isNull);
      expect(parser.parseNumericAmount('   '), isNull);
      expect(parser.parseNumericAmount('-'), isNull);
      expect(parser.parseNumericAmount('N/A'), isNull);
      expect(parser.parseNumericAmount('TBD'), isNull);
    });

    test('extracts inline notes when amount has bracketed footnote', () {
      final cell = parser.parseCell('£250.00 [1] Half nursery fees');
      expect(cell.amount, 250.0);
      expect(cell.note, 'Half nursery fees');
    });
  });

  group('SpreadsheetParserService - Period Header Identification', () {
    test('identifies month names and abbreviations as period headers', () {
      expect(parser.isPeriodHeader('Jan'), isTrue);
      expect(parser.isPeriodHeader('January'), isTrue);
      expect(parser.isPeriodHeader('Feb 2026'), isTrue);
      expect(parser.isPeriodHeader('March 26'), isTrue);
      expect(parser.isPeriodHeader('2026-01'), isTrue);
      expect(parser.isPeriodHeader('01/2026'), isTrue);
      expect(parser.isPeriodHeader('Dec 15 - Jan 14'), isTrue);
    });

    test('rejects non-period headers like Item, Category, Notes, Total', () {
      expect(parser.isPeriodHeader('Item'), isFalse);
      expect(parser.isPeriodHeader('Description'), isFalse);
      expect(parser.isPeriodHeader('Category'), isFalse);
      expect(parser.isPeriodHeader('Due Day'), isFalse);
      expect(parser.isPeriodHeader('Notes'), isFalse);
      expect(parser.isPeriodHeader('Total'), isFalse);
      expect(parser.isPeriodHeader('Average'), isFalse);
    });

    test('normalizes period headers into standard period format', () {
      expect(parser.normalizePeriodHeader('January 2026'), '2026-01');
      expect(parser.normalizePeriodHeader('2026-02'), '2026-02');
      expect(parser.normalizePeriodHeader('Mar 2026'), '2026-03');
    });
  });

  group('SpreadsheetParserService - CSV Parsing', () {
    test('parses a multi-month CSV budget ledger correctly', () async {
      const csvData = '''
Item,Category,Jan 2026,Feb 2026,Mar 2026
Wage,Income,£2500.00,£2500.00,£2550.00
Rent (29th),Household,£850.00,£850.00,£850.00
Council Tax (5th),Household,£145.00,£145.00,£145.00
Monzo Flex,Debts,£150.00,£150.00,£100.00
Emergency Fund,Savings,£200.00,£200.00,£200.00
''';

      final result = await parser.parseCsv(csvData, fileName: 'test_budget.csv');

      expect(result.sheets.length, 1);
      final sheet = result.sheets.first;
      expect(sheet.name, 'test_budget.csv');
      expect(sheet.periodHeaders.length, 3);
      expect(sheet.periodHeaders.map((p) => p.rawHeader), containsAll(['Jan 2026', 'Feb 2026', 'Mar 2026']));
      expect(sheet.rows.length, 5);

      final rentRow = sheet.rows.firstWhere((r) => r.rawLabel.contains('Rent'));
      expect(rentRow.rawLabel, 'Rent (29th)');
      expect(rentRow.rawCategory, 'Household');
      expect(rentRow.periodValues['Jan 2026']?.amount, 850.0);
      expect(rentRow.periodValues['Feb 2026']?.amount, 850.0);
      expect(rentRow.periodValues['Mar 2026']?.amount, 850.0);
    });

    test('parses CSV with missing values, blank lines, and trailing commas', () async {
      const csvData = '''
Expense,Jan 2026,Feb 2026,Mar 2026
Nursery Fees,£250.00 [1] Half fees,-,£500.00

Groceries,£400.00,£420.50,
''';

      final result = await parser.parseCsv(csvData);
      final sheet = result.sheets.first;
      expect(sheet.rows.length, 2);

      final nurseryRow = sheet.rows.firstWhere((r) => r.rawLabel == 'Nursery Fees');
      expect(nurseryRow.periodValues['Jan 2026']?.amount, 250.0);
      expect(nurseryRow.periodValues['Jan 2026']?.note, 'Half fees');
      expect(nurseryRow.periodValues['Feb 2026']?.amount, isNull);
      expect(nurseryRow.periodValues['Mar 2026']?.amount, 500.0);

      final groceriesRow = sheet.rows.firstWhere((r) => r.rawLabel == 'Groceries');
      expect(groceriesRow.periodValues['Feb 2026']?.amount, 420.50);
      expect(groceriesRow.periodValues['Mar 2026']?.amount, isNull);
    });

    test('handles empty CSV cleanly with warning', () async {
      final result = await parser.parseCsv('');
      expect(result.sheets.isEmpty, isTrue);
      expect(result.hasErrors, isTrue);
      expect(result.errors.first, contains('empty'));
    });
  });

  group('SpreadsheetParserService - Excel (.xlsx) Parsing', () {
    test('parses multi-month Excel sheets and values', () async {
      final excel = Excel.createExcel();
      const sheetName = 'Budget 2026';
      excel.rename('Sheet1', sheetName);

      final sheet = excel[sheetName];
      // Header row
      sheet.appendRow([
        TextCellValue('Item'),
        TextCellValue('Jan 2026'),
        TextCellValue('Feb 2026'),
      ]);
      // Row 1
      sheet.appendRow([
        TextCellValue('Salary'),
        const DoubleCellValue(3000.0),
        const DoubleCellValue(3000.0),
      ]);
      // Row 2
      sheet.appendRow([
        TextCellValue('Gym (1st)'),
        const DoubleCellValue(45.0),
        const DoubleCellValue(45.0),
      ]);

      final bytes = excel.encode()!;
      final result = await parser.parseExcelBytes(Uint8List.fromList(bytes), fileName: 'annual_budget.xlsx');

      expect(result.hasErrors, isFalse);
      expect(result.sheets.length, 1);
      final parsedSheet = result.sheets.first;
      expect(parsedSheet.name, sheetName);
      expect(parsedSheet.periodHeaders.length, 2);
      expect(parsedSheet.rows.length, 2);

      final salary = parsedSheet.rows.firstWhere((r) => r.rawLabel == 'Salary');
      expect(salary.periodValues['Jan 2026']?.amount, 3000.0);

      final gym = parsedSheet.rows.firstWhere((r) => r.rawLabel == 'Gym (1st)');
      expect(gym.periodValues['Feb 2026']?.amount, 45.0);
    });

    test('handles corrupted Excel bytes with error result', () async {
      final corruptedBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final result = await parser.parseExcelBytes(corruptedBytes, fileName: 'corrupt.xlsx');

      expect(result.hasErrors, isTrue);
      expect(result.errors.first, contains('Failed to parse Excel'));
    });
  });
}
