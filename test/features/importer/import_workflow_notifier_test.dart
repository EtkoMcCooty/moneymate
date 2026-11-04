import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/core/database/app_database.dart';
import 'package:moneymate/features/importer/models/import_workflow_models.dart';
import 'package:moneymate/features/importer/models/smart_match_result.dart';
import 'package:moneymate/features/importer/services/file_picker_service.dart';
import 'package:moneymate/features/importer/services/smart_matcher_service.dart';
import 'package:moneymate/features/importer/services/spreadsheet_import_commit_service.dart';
import 'package:moneymate/features/importer/services/spreadsheet_parser_service.dart';
import 'package:moneymate/features/importer/state/import_workflow_notifier.dart';

class FakeFilePickerService implements FilePickerService {
  PickedSpreadsheetFile? fileToReturn;

  @override
  Future<PickedSpreadsheetFile?> pickSpreadsheetFile() async {
    return fileToReturn;
  }
}

void main() {
  late AppDatabase db;
  late SpreadsheetParserService parserService;
  late SmartMatcherService matcherService;
  late SpreadsheetImportCommitService commitService;
  late FakeFilePickerService fakePicker;
  late ImportWorkflowNotifier notifier;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    parserService = SpreadsheetParserService();
    matcherService = SmartMatcherService();
    commitService = SpreadsheetImportCommitService(db);
    fakePicker = FakeFilePickerService();

    // Seed default tracker
    await db.into(db.trackers).insert(
          TrackersCompanion.insert(
            name: 'My Tracker',
            cycleStartDay: const Value(15),
            currencySymbol: const Value('£'),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );

    notifier = ImportWorkflowNotifier(
      db: db,
      parserService: parserService,
      matcherService: matcherService,
      commitService: commitService,
      filePickerService: fakePicker,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('ImportWorkflowNotifier', () {
    test('initializes with idle state', () {
      expect(notifier.state.step, equals(ImportStep.idle));
      expect(notifier.state.mappings, isEmpty);
    });

    test('pickAndParseFile parses CSV and sets state to reviewing', () async {
      const csvData = 'Item,Jan 26,Feb 26\nWage,2500,2500\nRent (29th),850,850';
      fakePicker.fileToReturn = PickedSpreadsheetFile(
        fileName: 'budget.csv',
        bytes: Uint8List.fromList(csvData.codeUnits),
      );

      final success = await notifier.pickAndParseFile();

      expect(success, isTrue);
      expect(notifier.state.step, equals(ImportStep.reviewing));
      expect(notifier.state.mappings.length, equals(2));

      final rentMapping = notifier.state.mappings.firstWhere((m) => m.cleanName == 'Rent');
      expect(rentMapping.dueDay, equals(29));
      expect(rentMapping.targetCategoryName, equals('Household'));
    });

    test('updateRowCategory and updateRowDueDay update mapping properties', () async {
      const csvData = 'Item,Jan 26\nCustom Thing,100';
      fakePicker.fileToReturn = PickedSpreadsheetFile(
        fileName: 'budget.csv',
        bytes: Uint8List.fromList(csvData.codeUnits),
      );

      await notifier.pickAndParseFile();
      expect(notifier.state.mappings.length, equals(1));

      notifier.updateRowCategory(
        0,
        const AvailableCategory(id: 99, name: 'Personal', categoryType: 'expense'),
      );
      notifier.updateRowDueDay(0, 15);

      expect(notifier.state.mappings[0].targetCategoryName, equals('Personal'));
      expect(notifier.state.mappings[0].targetCategoryId, equals(99));
      expect(notifier.state.mappings[0].dueDay, equals(15));
    });

    test('toggleRowExcluded toggles row exclusion', () async {
      const csvData = 'Item,Jan 26\nItem A,50';
      fakePicker.fileToReturn = PickedSpreadsheetFile(
        fileName: 'budget.csv',
        bytes: Uint8List.fromList(csvData.codeUnits),
      );

      await notifier.pickAndParseFile();
      expect(notifier.state.mappings[0].isExcluded, isFalse);

      notifier.toggleRowExcluded(0);
      expect(notifier.state.mappings[0].isExcluded, isTrue);

      notifier.toggleRowExcluded(0);
      expect(notifier.state.mappings[0].isExcluded, isFalse);
    });

    test('commitImport persists data and transitions state to completed', () async {
      const csvData = 'Item,Jan 26\nGroceries,120';
      fakePicker.fileToReturn = PickedSpreadsheetFile(
        fileName: 'budget.csv',
        bytes: Uint8List.fromList(csvData.codeUnits),
      );

      await notifier.pickAndParseFile();
      final success = await notifier.commitImport();

      expect(success, isTrue);
      expect(notifier.state.step, equals(ImportStep.completed));
      expect(notifier.state.summary, isNotNull);
      expect(notifier.state.summary!.itemsCount, equals(1));

      final items = await db.select(db.financeItems).get();
      expect(items.length, equals(1));
      expect(items.first.name, equals('Groceries'));
    });
  });
}
