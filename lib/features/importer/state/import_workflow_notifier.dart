import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../models/import_workflow_models.dart';
import '../models/parsed_spreadsheet.dart';
import '../models/smart_match_result.dart';
import '../services/file_picker_service.dart';
import '../services/smart_matcher_service.dart';
import '../services/spreadsheet_import_commit_service.dart';
import '../services/spreadsheet_parser_service.dart';

/// Provider for [ImportWorkflowNotifier].
final importWorkflowProvider =
    StateNotifierProvider<ImportWorkflowNotifier, ImportWorkflowState>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final parser = ref.watch(spreadsheetParserServiceProvider);
  final matcher = ref.watch(smartMatcherServiceProvider);
  final commitService = ref.watch(spreadsheetImportCommitServiceProvider);
  final filePicker = ref.watch(filePickerServiceProvider);

  return ImportWorkflowNotifier(
    db: db,
    parserService: parser,
    matcherService: matcher,
    commitService: commitService,
    filePickerService: filePicker,
  );
});

/// Notifier coordinating the complete spreadsheet ingestion lifecycle:
/// file selection, parsing, smart category matching, user adjustments, and DB commit.
class ImportWorkflowNotifier extends StateNotifier<ImportWorkflowState> {
  final AppDatabase _db;
  final SpreadsheetParserService _parserService;
  final SmartMatcherService _matcherService;
  final SpreadsheetImportCommitService _commitService;
  final FilePickerService _filePickerService;

  ImportWorkflowNotifier({
    required AppDatabase db,
    required SpreadsheetParserService parserService,
    required SmartMatcherService matcherService,
    required SpreadsheetImportCommitService commitService,
    required FilePickerService filePickerService,
  })  : _db = db,
        _parserService = parserService,
        _matcherService = matcherService,
        _commitService = commitService,
        _filePickerService = filePickerService,
        super(const ImportWorkflowState());

  /// Loads available categories from the active tracker to pass into the matcher.
  Future<void> initCategories() async {
    try {
      final tracker =
          await (_db.select(_db.trackers)..limit(1)).getSingleOrNull();
      if (tracker != null) {
        final dbCats = await (_db.select(_db.categories)
              ..where((c) => c.trackerId.equals(tracker.id)))
            .get();

        final available = dbCats
            .map((c) => AvailableCategory(
                  id: c.id,
                  name: c.name,
                  categoryType: c.categoryType,
                ))
            .toList();

        state = state.copyWith(availableCategories: available);
      }
    } catch (_) {
      // Non-fatal if categories cannot be loaded immediately
    }
  }

  /// Triggers file picker dialog and parses selected spreadsheet into row mappings.
  Future<bool> pickAndParseFile() async {
    state = state.copyWith(step: ImportStep.pickingFile, errorMessage: null);

    try {
      final picked = await _filePickerService.pickSpreadsheetFile();
      if (picked == null) {
        // User canceled file picker
        state = state.copyWith(step: ImportStep.idle);
        return false;
      }

      state = state.copyWith(
        step: ImportStep.parsing,
        fileName: picked.fileName,
        fileBytes: picked.bytes,
      );

      final lowerName = picked.fileName.toLowerCase();
      ParsedSpreadsheet parsed;

      if (lowerName.endsWith('.csv')) {
        final content = utf8.decode(picked.bytes, allowMalformed: true);
        parsed = await _parserService.parseCsv(content, fileName: picked.fileName);
      } else {
        parsed = await _parserService.parseExcelBytes(picked.bytes, fileName: picked.fileName);
      }

      if (parsed.hasErrors || parsed.isEmpty) {
        final err = parsed.errors.isNotEmpty
            ? parsed.errors.first
            : 'No recognizable spending rows or columns found in this file.';
        state = state.copyWith(
          step: ImportStep.error,
          errorMessage: err,
        );
        return false;
      }

      final activeSheet = parsed.sheets.first;
      final mappings = _buildMappingsForSheet(activeSheet);

      state = state.copyWith(
        step: ImportStep.reviewing,
        parsedSpreadsheet: parsed,
        selectedSheetIndex: 0,
        mappings: mappings,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        step: ImportStep.error,
        errorMessage: 'Unable to read spreadsheet: $e',
      );
      return false;
    }
  }

  List<ImportRowMapping> _buildMappingsForSheet(ParsedSheet sheet) {
    final mappings = <ImportRowMapping>[];
    for (var i = 0; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      final match = _matcherService.matchLabel(
        row.rawLabel,
        rawCategoryHint: row.rawCategory,
        availableCategories: state.availableCategories,
      );

      mappings.add(ImportRowMapping(
        rowIndex: i,
        originalLabel: row.rawLabel,
        cleanName: match.cleanName,
        dueDay: match.dueDay,
        targetCategoryName: match.suggestedCategoryName,
        targetCategoryType: match.suggestedCategoryType,
        targetCategoryId: match.matchedCategoryId,
        isDebt: match.isDebt,
        isAmbiguous: match.isAmbiguous,
        periodValues: row.periodValues,
      ));
    }
    return mappings;
  }

  /// Updates the target category for a specific row mapping.
  void updateRowCategory(int rowIndex, AvailableCategory category) {
    if (rowIndex < 0 || rowIndex >= state.mappings.length) return;

    final updated = List<ImportRowMapping>.from(state.mappings);
    final current = updated[rowIndex];

    updated[rowIndex] = current.copyWith(
      targetCategoryName: category.name,
      targetCategoryType: category.categoryType,
      targetCategoryId: category.id,
      isDebt: category.categoryType == 'debt',
      isAmbiguous: false, // User explicitly selected category
    );

    state = state.copyWith(mappings: updated);
  }

  /// Adjusts or clears the recurring due day for a specific row mapping.
  void updateRowDueDay(int rowIndex, int? dueDay) {
    if (rowIndex < 0 || rowIndex >= state.mappings.length) return;

    final updated = List<ImportRowMapping>.from(state.mappings);
    updated[rowIndex] = updated[rowIndex].copyWith(dueDay: dueDay);
    state = state.copyWith(mappings: updated);
  }

  /// Toggles whether a specific row is excluded from the import.
  void toggleRowExcluded(int rowIndex) {
    if (rowIndex < 0 || rowIndex >= state.mappings.length) return;

    final updated = List<ImportRowMapping>.from(state.mappings);
    final current = updated[rowIndex];
    updated[rowIndex] = current.copyWith(isExcluded: !current.isExcluded);
    state = state.copyWith(mappings: updated);
  }

  /// Switches active sheet for multi-sheet Excel workbooks.
  void selectSheet(int sheetIndex) {
    if (state.parsedSpreadsheet == null ||
        sheetIndex < 0 ||
        sheetIndex >= state.parsedSpreadsheet!.sheets.length) {
      return;
    }

    final targetSheet = state.parsedSpreadsheet!.sheets[sheetIndex];
    final mappings = _buildMappingsForSheet(targetSheet);

    state = state.copyWith(
      selectedSheetIndex: sheetIndex,
      mappings: mappings,
    );
  }

  /// Commits all non-excluded row mappings atomically into Drift.
  Future<bool> commitImport({int? targetTrackerId}) async {
    if (state.mappings.isEmpty || state.parsedSpreadsheet == null) {
      state = state.copyWith(
        step: ImportStep.error,
        errorMessage: 'No items available to import.',
      );
      return false;
    }

    state = state.copyWith(step: ImportStep.committing, errorMessage: null);

    try {
      int trackerId;
      if (targetTrackerId != null) {
        trackerId = targetTrackerId;
      } else {
        var tracker =
            await (_db.select(_db.trackers)..limit(1)).getSingleOrNull();
        if (tracker == null) {
          trackerId = await _db.into(_db.trackers).insert(
                TrackersCompanion.insert(
                  name: 'My Tracker',
                  cycleStartDay: const Value(15),
                  currencySymbol: const Value('£'),
                  createdAt: Value(DateTime.now()),
                  updatedAt: Value(DateTime.now()),
                ),
              );
        } else {
          trackerId = tracker.id;
        }
      }

      final activeSheet =
          state.parsedSpreadsheet!.sheets[state.selectedSheetIndex];

      final summary = await _commitService.commitImport(
        trackerId: trackerId,
        mappings: state.mappings,
        periodHeaders: activeSheet.periodHeaders,
      );

      state = state.copyWith(
        step: ImportStep.completed,
        summary: summary,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        step: ImportStep.error,
        errorMessage: 'Import failed: $e',
      );
      return false;
    }
  }

  /// Resets import workflow back to initial idle state.
  void reset() {
    state = ImportWorkflowState(availableCategories: state.availableCategories);
  }
}
