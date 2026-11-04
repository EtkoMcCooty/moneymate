import 'dart:typed_data';
import 'parsed_spreadsheet.dart';
import 'smart_match_result.dart';

/// Represents an editable line item row during the pre-import review stage.
class ImportRowMapping {
  final int rowIndex;
  final String originalLabel;
  final String cleanName;
  final int? dueDay;
  final String targetCategoryName;
  final String targetCategoryType; // income, expense, debt, savings, investment
  final int? targetCategoryId;
  final bool isDebt;
  final bool isExcluded;
  final bool isAmbiguous;
  final Map<String, ParsedCell> periodValues;

  const ImportRowMapping({
    required this.rowIndex,
    required this.originalLabel,
    required this.cleanName,
    this.dueDay,
    required this.targetCategoryName,
    required this.targetCategoryType,
    this.targetCategoryId,
    this.isDebt = false,
    this.isExcluded = false,
    this.isAmbiguous = false,
    required this.periodValues,
  });

  ImportRowMapping copyWith({
    String? originalLabel,
    String? cleanName,
    int? dueDay,
    String? targetCategoryName,
    String? targetCategoryType,
    int? targetCategoryId,
    bool? isDebt,
    bool? isExcluded,
    bool? isAmbiguous,
    Map<String, ParsedCell>? periodValues,
  }) {
    return ImportRowMapping(
      rowIndex: rowIndex,
      originalLabel: originalLabel ?? this.originalLabel,
      cleanName: cleanName ?? this.cleanName,
      dueDay: dueDay ?? this.dueDay,
      targetCategoryName: targetCategoryName ?? this.targetCategoryName,
      targetCategoryType: targetCategoryType ?? this.targetCategoryType,
      targetCategoryId: targetCategoryId ?? this.targetCategoryId,
      isDebt: isDebt ?? this.isDebt,
      isExcluded: isExcluded ?? this.isExcluded,
      isAmbiguous: isAmbiguous ?? this.isAmbiguous,
      periodValues: periodValues ?? this.periodValues,
    );
  }

  @override
  String toString() =>
      'ImportRowMapping("$cleanName", due: $dueDay, cat: "$targetCategoryName", excluded: $isExcluded)';
}

/// Status of the active import workflow.
enum ImportStep {
  idle,
  pickingFile,
  parsing,
  reviewing,
  committing,
  completed,
  error,
}

/// Summary metrics of persisted items and values following an atomic commit.
class ImportSummaryResult {
  final int itemsCount;
  final int entriesCount;
  final int categoriesCount;
  final List<String> periodKeys;

  const ImportSummaryResult({
    required this.itemsCount,
    required this.entriesCount,
    required this.categoriesCount,
    required this.periodKeys,
  });

  @override
  String toString() =>
      'ImportSummaryResult(items: $itemsCount, entries: $entriesCount, cats: $categoriesCount, periods: $periodKeys)';
}

/// State for the [ImportWorkflowNotifier].
class ImportWorkflowState {
  final ImportStep step;
  final String? fileName;
  final Uint8List? fileBytes;
  final ParsedSpreadsheet? parsedSpreadsheet;
  final int selectedSheetIndex;
  final List<ImportRowMapping> mappings;
  final List<AvailableCategory> availableCategories;
  final String? errorMessage;
  final ImportSummaryResult? summary;

  const ImportWorkflowState({
    this.step = ImportStep.idle,
    this.fileName,
    this.fileBytes,
    this.parsedSpreadsheet,
    this.selectedSheetIndex = 0,
    this.mappings = const [],
    this.availableCategories = const [],
    this.errorMessage,
    this.summary,
  });

  ImportWorkflowState copyWith({
    ImportStep? step,
    String? fileName,
    Uint8List? fileBytes,
    ParsedSpreadsheet? parsedSpreadsheet,
    int? selectedSheetIndex,
    List<ImportRowMapping>? mappings,
    List<AvailableCategory>? availableCategories,
    String? errorMessage,
    ImportSummaryResult? summary,
  }) {
    return ImportWorkflowState(
      step: step ?? this.step,
      fileName: fileName ?? this.fileName,
      fileBytes: fileBytes ?? this.fileBytes,
      parsedSpreadsheet: parsedSpreadsheet ?? this.parsedSpreadsheet,
      selectedSheetIndex: selectedSheetIndex ?? this.selectedSheetIndex,
      mappings: mappings ?? this.mappings,
      availableCategories: availableCategories ?? this.availableCategories,
      errorMessage: errorMessage,
      summary: summary ?? this.summary,
    );
  }
}
