import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/core/database/app_database.dart';
import 'package:moneymate/core/database/database_provider.dart';
import 'package:moneymate/features/importer/models/import_workflow_models.dart';
import 'package:moneymate/features/importer/models/parsed_spreadsheet.dart';
import 'package:moneymate/features/importer/services/file_picker_service.dart';
import 'package:moneymate/features/importer/services/smart_matcher_service.dart';
import 'package:moneymate/features/importer/services/spreadsheet_import_commit_service.dart';
import 'package:moneymate/features/importer/services/spreadsheet_parser_service.dart';
import 'package:moneymate/features/importer/state/import_workflow_notifier.dart';
import 'package:moneymate/features/importer/views/import_spreadsheet_dialog.dart';

class MockFilePickerService implements FilePickerService {
  PickedSpreadsheetFile? file;

  @override
  Future<PickedSpreadsheetFile?> pickSpreadsheetFile() async {
    return file;
  }
}

void main() {
  late AppDatabase db;
  late MockFilePickerService mockPicker;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    mockPicker = MockFilePickerService();
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestDialog({ImportWorkflowState? initialState}) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        filePickerServiceProvider.overrideWithValue(mockPicker),
        if (initialState != null)
          importWorkflowProvider.overrideWith(
            (ref) {
              final notifier = ImportWorkflowNotifier(
                db: db,
                parserService: ref.watch(spreadsheetParserServiceProvider),
                matcherService: ref.watch(smartMatcherServiceProvider),
                commitService: ref.watch(spreadsheetImportCommitServiceProvider),
                filePickerService: mockPicker,
              );
              // ignore: invalid_use_of_protected_member
              notifier.state = initialState;
              return notifier;
            },
          ),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: ImportSpreadsheetDialog(),
        ),
      ),
    );
  }

  group('ImportSpreadsheetDialog Widget Tests', () {
    testWidgets('renders idle state with choose file button and benefits list', (tester) async {
      await tester.pumpWidget(buildTestDialog());
      await tester.pumpAndSettle();

      expect(find.text('Import spreadsheet'), findsOneWidget);
      expect(find.text('Excel (.xlsx) or CSV format'), findsOneWidget);
      expect(find.text('Choose file'), findsOneWidget);
      expect(find.text('Got it'), findsOneWidget);
      expect(find.byKey(const Key('choose_spreadsheet_button')), findsOneWidget);
    });

    testWidgets('renders review state with item list, due date badge, and import button', (tester) async {
      const reviewState = ImportWorkflowState(
        step: ImportStep.reviewing,
        fileName: 'household_budget.csv',
        selectedSheetIndex: 0,
        parsedSpreadsheet: ParsedSpreadsheet(
          fileName: 'household_budget.csv',
          sheets: [
            ParsedSheet(
              name: 'Sheet1',
              periodHeaders: [
                ParsedPeriodHeader(rawHeader: 'Jan 26', normalizedKey: '2026-01', columnIndex: 1),
              ],
            ),
          ],
        ),
        mappings: [
          ImportRowMapping(
            rowIndex: 0,
            originalLabel: 'Rent (29th)',
            cleanName: 'Rent',
            dueDay: 29,
            targetCategoryName: 'Household',
            targetCategoryType: 'expense',
            periodValues: {},
          ),
          ImportRowMapping(
            rowIndex: 1,
            originalLabel: 'Wage',
            cleanName: 'Wage',
            targetCategoryName: 'Income',
            targetCategoryType: 'income',
            periodValues: {},
          ),
        ],
      );

      await tester.pumpWidget(buildTestDialog(initialState: reviewState));
      await tester.pumpAndSettle();

      expect(find.text('Review your items'), findsOneWidget);
      expect(find.text('Rent'), findsOneWidget);
      expect(find.text('Due 29th'), findsOneWidget);
      expect(find.text('Wage'), findsOneWidget);
      expect(find.byKey(const Key('commit_import_button')), findsOneWidget);
      expect(find.text('Import 2 items'), findsOneWidget);
    });

    testWidgets('renders completed state with summary and Open Tracker button', (tester) async {
      const completedState = ImportWorkflowState(
        step: ImportStep.completed,
        summary: ImportSummaryResult(
          itemsCount: 15,
          entriesCount: 45,
          categoriesCount: 4,
          periodKeys: ['2026-01', '2026-02', '2026-03'],
        ),
      );

      await tester.pumpWidget(buildTestDialog(initialState: completedState));
      await tester.pumpAndSettle();

      expect(find.text('Import complete!'), findsOneWidget);
      expect(
        find.text('Successfully added 15 items and 45 monthly values across 3 months.'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('open_tracker_button')), findsOneWidget);
    });
  });
}
