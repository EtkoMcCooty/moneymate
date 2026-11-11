import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:excel/excel.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/core/database/app_database.dart';
import 'package:moneymate/core/database/database_provider.dart';
import 'package:moneymate/features/importer/models/import_workflow_models.dart';
import 'package:moneymate/features/importer/services/file_picker_service.dart';
import 'package:moneymate/features/importer/services/smart_matcher_service.dart';
import 'package:moneymate/features/importer/services/spreadsheet_import_commit_service.dart';
import 'package:moneymate/features/importer/services/spreadsheet_parser_service.dart';
import 'package:moneymate/features/importer/state/import_workflow_notifier.dart';
import 'package:moneymate/features/importer/views/import_spreadsheet_dialog.dart';

class FakePicker implements FilePickerService {
  PickedSpreadsheetFile? file;
  @override
  Future<PickedSpreadsheetFile?> pickSpreadsheetFile() async => file;
}

Uint8List createMultiYearWorkbookBytes() {
  final excel = Excel.createExcel();
  excel.rename('Sheet1', '2023');

  // Sheet 2023
  final sheet2023 = excel['2023'];
  sheet2023.appendRow([
    TextCellValue('Item'),
    TextCellValue('Jan'),
    TextCellValue('Feb'),
  ]);
  sheet2023.appendRow([
    TextCellValue('Rent (29th)'),
    const DoubleCellValue(850.0),
    const DoubleCellValue(850.0),
  ]);

  // Sheet 2024
  final sheet2024 = excel['2024'];
  sheet2024.appendRow([
    TextCellValue('Item'),
    TextCellValue('Jan'),
    TextCellValue('Feb'),
  ]);
  sheet2024.appendRow([
    TextCellValue('Rent (29th)'),
    const DoubleCellValue(900.0),
    const DoubleCellValue(900.0),
  ]);
  sheet2024.appendRow([
    TextCellValue('Gym (1st)'),
    const DoubleCellValue(45.0),
    const DoubleCellValue(45.0),
  ]);

  return Uint8List.fromList(excel.encode()!);
}

void main() {
  late SpreadsheetParserService parser;
  late AppDatabase db;
  late SpreadsheetImportCommitService commitService;
  late SmartMatcherService matcher;
  late FakePicker fakePicker;

  setUp(() async {
    parser = SpreadsheetParserService();
    db = AppDatabase(NativeDatabase.memory());
    commitService = SpreadsheetImportCommitService(db);
    matcher = SmartMatcherService();
    fakePicker = FakePicker();

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

  group('Multi-Year Spreadsheet Tabs Patch Tests', () {
    test('SpreadsheetParserService extracts sheet name reference year for period headers', () async {
      final bytes = createMultiYearWorkbookBytes();
      final parsed = await parser.parseExcelBytes(bytes, fileName: 'multi_year.xlsx');

      expect(parsed.sheets.length, equals(2));

      final sheet2023 = parsed.sheets.firstWhere((s) => s.name == '2023');
      expect(sheet2023.periodHeaders[0].rawHeader, equals('Jan'));
      expect(sheet2023.periodHeaders[0].normalizedKey, equals('2023-01'));
      expect(sheet2023.periodHeaders[1].normalizedKey, equals('2023-02'));

      final sheet2024 = parsed.sheets.firstWhere((s) => s.name == '2024');
      expect(sheet2024.periodHeaders[0].rawHeader, equals('Jan'));
      expect(sheet2024.periodHeaders[0].normalizedKey, equals('2024-01'));
      expect(sheet2024.periodHeaders[1].normalizedKey, equals('2024-02'));

      // Verify periodValues store by normalizedKey so years do not collide
      final rent2023 = sheet2023.rows.firstWhere((r) => r.rawLabel.contains('Rent'));
      expect(rent2023.periodValues['2023-01']?.amount, equals(850.0));

      final rent2024 = sheet2024.rows.firstWhere((r) => r.rawLabel.contains('Rent'));
      expect(rent2024.periodValues['2024-01']?.amount, equals(900.0));
    });

    test('ImportWorkflowNotifier combines rows across multiple year sheets in all-sheets mode', () async {
      final bytes = createMultiYearWorkbookBytes();
      fakePicker.file = PickedSpreadsheetFile(fileName: 'finances.xlsx', bytes: bytes);

      final notifier = ImportWorkflowNotifier(
        db: db,
        parserService: parser,
        matcherService: matcher,
        commitService: commitService,
        filePickerService: fakePicker,
      );

      final success = await notifier.pickAndParseFile();
      expect(success, isTrue);

      final state = notifier.state;
      expect(state.isAllSheetsMode, isTrue);
      expect(state.parsedSpreadsheet!.sheets.length, equals(2));

      // Combined mappings should contain Rent (merged from 2023 and 2024) and Gym (from 2024)
      expect(state.mappings.length, equals(2));

      final rentMapping = state.mappings.firstWhere((m) => m.cleanName == 'Rent');
      expect(rentMapping.periodValues['2023-01']?.amount, equals(850.0));
      expect(rentMapping.periodValues['2024-01']?.amount, equals(900.0));

      final gymMapping = state.mappings.firstWhere((m) => m.cleanName == 'Gym');
      expect(gymMapping.periodValues['2024-01']?.amount, equals(45.0));
      expect(gymMapping.periodValues['2023-01']?.amount, isNull);

      // Switching sheet filters view
      notifier.selectSheet(0); // View 2023 sheet
      expect(notifier.state.isAllSheetsMode, isFalse);
      expect(notifier.state.selectedSheetIndex, equals(0));
      expect(notifier.state.mappings.length, equals(1)); // Only Rent in 2023

      notifier.selectAllSheets(); // Switch back to combined
      expect(notifier.state.isAllSheetsMode, isTrue);
      expect(notifier.state.mappings.length, equals(2));
    });

    test('commitImport in all-sheets mode commits entries across all years atomically', () async {
      final bytes = createMultiYearWorkbookBytes();
      fakePicker.file = PickedSpreadsheetFile(fileName: 'finances.xlsx', bytes: bytes);

      final notifier = ImportWorkflowNotifier(
        db: db,
        parserService: parser,
        matcherService: matcher,
        commitService: commitService,
        filePickerService: fakePicker,
      );

      await notifier.pickAndParseFile();
      final success = await notifier.commitImport();

      expect(success, isTrue);
      expect(notifier.state.step, equals(ImportStep.completed));
      expect(notifier.state.summary!.periodKeys, containsAll(['2023-01', '2023-02', '2024-01', '2024-02']));

      final entries = await db.select(db.itemEntries).get();
      final periodKeys = entries.map((e) => e.periodKey).toSet();
      expect(periodKeys, containsAll(['2023-01', '2023-02', '2024-01', '2024-02']));
    });

    testWidgets('ImportSpreadsheetDialog displays total months across sheets and renders sheet choice chips', (tester) async {
      final bytes = createMultiYearWorkbookBytes();
      fakePicker.file = PickedSpreadsheetFile(fileName: 'finances.xlsx', bytes: bytes);

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          filePickerServiceProvider.overrideWithValue(fakePicker),
        ],
      );
      addTearDown(container.dispose);

      await container.read(importWorkflowProvider.notifier).pickAndParseFile();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: ImportSpreadsheetDialog()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify header subtitle mentions total months across all years/tabs
      expect(find.textContaining('4 months found across 2 years'), findsOneWidget);

      // Verify ChoiceChips for tabs
      expect(find.text('All (4 mos)'), findsOneWidget);
      expect(find.text('2023 (2 mos)'), findsOneWidget);
      expect(find.text('2024 (2 mos)'), findsOneWidget);

      // Tap 2023 chip
      await tester.tap(find.text('2023 (2 mos)'));
      await tester.pumpAndSettle();

      expect(container.read(importWorkflowProvider).isAllSheetsMode, isFalse);
      expect(container.read(importWorkflowProvider).selectedSheetIndex, equals(0));
    });
  });
}
