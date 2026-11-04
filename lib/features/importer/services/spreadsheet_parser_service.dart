import 'dart:convert';
import 'dart:typed_data';
import 'package:csv/csv.dart' hide excel;
import 'package:excel/excel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneymate/features/importer/models/parsed_spreadsheet.dart';

/// Provider for [SpreadsheetParserService].
final spreadsheetParserServiceProvider = Provider<SpreadsheetParserService>((ref) {
  return SpreadsheetParserService();
});

/// Service responsible for parsing .csv and .xlsx spreadsheet files into structured
/// finance rows, period columns, and cell values.
class SpreadsheetParserService {
  static const Map<String, int> _monthNames = {
    'jan': 1,
    'january': 1,
    'feb': 2,
    'february': 2,
    'mar': 3,
    'march': 3,
    'apr': 4,
    'april': 4,
    'may': 5,
    'jun': 6,
    'june': 6,
    'jul': 7,
    'july': 7,
    'aug': 8,
    'august': 8,
    'sep': 9,
    'sept': 9,
    'september': 9,
    'oct': 10,
    'october': 10,
    'nov': 11,
    'november': 11,
    'dec': 12,
    'december': 12,
  };

  static const Set<String> _nonPeriodHeaders = {
    'item',
    'items',
    'description',
    'desc',
    'category',
    'categories',
    'name',
    'due',
    'due day',
    'due date',
    'day',
    'notes',
    'note',
    'total',
    'totals',
    'average',
    'avg',
    'sum',
    'min',
    'max',
    'status',
    'type',
    'account',
    'comments',
    'comment',
    'expense',
    'expenses',
    'income',
    'incomes',
  };

  /// Parses a numeric currency or numerical value from strings or dynamic cell objects.
  /// Handles currency symbols (£, $, €, ¥), thousands commas, negative values,
  /// accounting parentheses (e.g. (150.00)), and placeholder tokens.
  double? parseNumericAmount(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();

    var str = raw.toString().trim();
    if (str.isEmpty || str == '-' || str == '—' || str == '–' || str.toUpperCase() == 'N/A' || str.toUpperCase() == 'TBD') {
      return null;
    }

    // Check for inline bracketed note and extract the amount portion
    final bracketMatch = RegExp(r'^(.*?)\s*\[.*?\]').firstMatch(str);
    if (bracketMatch != null) {
      str = bracketMatch.group(1)!.trim();
    }

    var isNegative = false;
    // Check for negative signs or accounting parentheses
    if (str.startsWith('-')) {
      isNegative = true;
      str = str.substring(1).trim();
    } else if (str.startsWith('(') && str.endsWith(')')) {
      isNegative = true;
      str = str.substring(1, str.length - 1).trim();
    }

    // Strip currency symbols (£, $, €, ¥), spaces, and thousand-separators
    str = str.replaceAll(RegExp(r'[£$€¥\s,]'), '');

    // Check again if parentheses were nested with currency symbol e.g. (50.25)
    if (str.startsWith('(') && str.endsWith(')')) {
      isNegative = true;
      str = str.substring(1, str.length - 1).trim();
    }

    final parsed = double.tryParse(str);
    if (parsed == null) return null;

    return isNegative ? -parsed.abs() : parsed;
  }

  /// Parses an individual cell into a structured [ParsedCell], separating
  /// numeric value from inline annotations or footnotes.
  ParsedCell parseCell(dynamic raw) {
    if (raw == null) return const ParsedCell(rawValue: '');

    final rawStr = raw.toString().trim();
    String? note;

    // Check for footnote notes: e.g. [1] Half nursery fees or [note] text
    final noteMatch = RegExp(r'\[(?:\d+)?\]\s*(.*)$').firstMatch(rawStr);
    if (noteMatch != null && noteMatch.group(1)!.trim().isNotEmpty) {
      note = noteMatch.group(1)!.trim();
    }

    final amount = parseNumericAmount(raw);
    return ParsedCell(
      amount: amount,
      rawValue: rawStr,
      note: note,
    );
  }

  /// Determines whether a column header represents a budget period / month.
  bool isPeriodHeader(String header) {
    final trimmed = header.trim();
    if (trimmed.isEmpty) return false;

    final lower = trimmed.toLowerCase();
    if (_nonPeriodHeaders.contains(lower)) return false;

    // Check YYYY-MM (e.g. 2026-01) or MM/YYYY (e.g. 01/2026)
    if (RegExp(r'^\d{4}[-/]\d{1,2}$').hasMatch(lower) || RegExp(r'^\d{1,2}[-/]\d{4}$').hasMatch(lower)) {
      return true;
    }

    // Check month cycle spans: e.g. "Dec 15 - Jan 14" or "15/12 - 14/01"
    if (lower.contains('-') && _containsAnyMonth(lower)) {
      return true;
    }

    // Check month name or month + year (e.g. "Jan", "January", "Feb 2026", "March 26")
    for (final monthKey in _monthNames.keys) {
      final pattern = RegExp(r'\b' + monthKey + r'\b');
      if (pattern.hasMatch(lower)) {
        return true;
      }
    }

    return false;
  }

  /// Normalizes a human-readable or formatted period header into a standard format (e.g. 2026-01).
  String normalizePeriodHeader(String header, {int? referenceYear}) {
    final trimmed = header.trim();
    final lower = trimmed.toLowerCase();

    // Check YYYY-MM
    final yyyyMm = RegExp(r'^(\d{4})[-/](\d{1,2})$').firstMatch(lower);
    if (yyyyMm != null) {
      final y = yyyyMm.group(1)!;
      final m = int.parse(yyyyMm.group(2)!).toString().padLeft(2, '0');
      return '$y-$m';
    }

    // Check MM/YYYY
    final mmYyyy = RegExp(r'^(\d{1,2})[-/](\d{4})$').firstMatch(lower);
    if (mmYyyy != null) {
      final m = int.parse(mmYyyy.group(1)!).toString().padLeft(2, '0');
      final y = mmYyyy.group(2)!;
      return '$y-$m';
    }

    // Check Month Name + 4-digit Year (e.g. "January 2026", "Mar 2026")
    for (final entry in _monthNames.entries) {
      final match = RegExp(r'\b' + entry.key + r'[a-z]*\s+(\d{4})\b').firstMatch(lower);
      if (match != null) {
        final year = match.group(1)!;
        final month = entry.value.toString().padLeft(2, '0');
        return '$year-$month';
      }
    }

    // Check Month Name + 2-digit Year (e.g. "March 26")
    for (final entry in _monthNames.entries) {
      final match = RegExp(r'\b' + entry.key + r'[a-z]*\s+(\d{2})\b').firstMatch(lower);
      if (match != null) {
        final year = '20${match.group(1)!}';
        final month = entry.value.toString().padLeft(2, '0');
        return '$year-$month';
      }
    }

    // Check date spans / pay cycle ranges (e.g. "Dec 15th - Jan 14th", "Dec 15 - Jan 14", "15/12 - 14/01")
    if (lower.contains('-') || lower.contains('–')) {
      final delimiter = lower.contains('–') ? '–' : '-';
      final parts = lower.split(delimiter);
      if (parts.length >= 2) {
        final startPart = parts[0].trim();
        final endPart = parts[1].trim();

        int? spanYear;
        final yearMatch = RegExp(r'\b(20\d{2})\b').firstMatch(endPart) ??
            RegExp(r'\b(20\d{2})\b').firstMatch(startPart);
        if (yearMatch != null) {
          spanYear = int.parse(yearMatch.group(1)!);
        } else {
          final yearSlashMatch = RegExp(r'/(\d{2})$').firstMatch(endPart);
          if (yearSlashMatch != null) {
            spanYear = 2000 + int.parse(yearSlashMatch.group(1)!);
          }
        }
        spanYear ??= referenceYear ?? DateTime.now().year;

        final endMonth = _extractMonthNumber(endPart);
        if (endMonth != null) {
          final m = endMonth.toString().padLeft(2, '0');
          return '$spanYear-$m';
        }

        final numDateMatch = RegExp(r'\b\d{1,2}/(\d{1,2})\b').firstMatch(endPart);
        if (numDateMatch != null) {
          final m = int.parse(numDateMatch.group(1)!).toString().padLeft(2, '0');
          return '$spanYear-$m';
        }
      }
    }

    // Check Plain Month Name without Year (e.g. "January", "Jan")
    final plainMonth = _extractMonthNumber(lower);
    if (plainMonth != null) {
      final defaultYear = referenceYear ?? DateTime.now().year;
      final m = plainMonth.toString().padLeft(2, '0');
      return '$defaultYear-$m';
    }

    // Defensive fallback: If string already has YYYY-MM inside it, extract it
    final embeddedYyyyMm = RegExp(r'\b(20\d{2})[-/](\d{1,2})\b').firstMatch(lower);
    if (embeddedYyyyMm != null) {
      final y = embeddedYyyyMm.group(1)!;
      final m = int.parse(embeddedYyyyMm.group(2)!).toString().padLeft(2, '0');
      return '$y-$m';
    }

    // Final safety guarantee: Return valid 7-character period key
    final defaultYear = referenceYear ?? DateTime.now().year;
    final currentMonth = DateTime.now().month.toString().padLeft(2, '0');
    return '$defaultYear-$currentMonth';
  }

  int? _extractMonthNumber(String text) {
    for (final entry in _monthNames.entries) {
      final pattern = RegExp(r'\b' + entry.key + r'[a-z]*\b');
      if (pattern.hasMatch(text)) {
        return entry.value;
      }
    }
    return null;
  }

  bool _containsAnyMonth(String text) {
    for (final monthKey in _monthNames.keys) {
      if (text.contains(monthKey)) return true;
    }
    return false;
  }

  /// Parses a raw CSV string into a [ParsedSpreadsheet].
  Future<ParsedSpreadsheet> parseCsv(String csvContent, {String fileName = 'import.csv'}) async {
    if (csvContent.trim().isEmpty) {
      return ParsedSpreadsheet(
        fileName: fileName,
        sheets: const [],
        errors: const ['CSV file is empty or could not be read.'],
      );
    }

    final rawRows = const CsvDecoder(dynamicTyping: false).convert(csvContent);

    if (rawRows.isEmpty) {
      return ParsedSpreadsheet(
        fileName: fileName,
        sheets: const [],
        errors: const ['CSV file contains no valid rows.'],
      );
    }

    final sheet = _processSheetRows(fileName, rawRows);
    return ParsedSpreadsheet(
      fileName: fileName,
      sheets: [sheet],
    );
  }

  /// Parses CSV binary bytes into a [ParsedSpreadsheet].
  Future<ParsedSpreadsheet> parseCsvBytes(List<int> bytes, {String fileName = 'import.csv'}) async {
    try {
      final content = utf8.decode(bytes, allowMalformed: true);
      return await parseCsv(content, fileName: fileName);
    } catch (e) {
      return ParsedSpreadsheet(
        fileName: fileName,
        errors: ['Failed to decode CSV bytes: $e'],
      );
    }
  }

  /// Parses Excel (.xlsx) binary bytes into a [ParsedSpreadsheet].
  Future<ParsedSpreadsheet> parseExcelBytes(Uint8List bytes, {String fileName = 'import.xlsx'}) async {
    try {
      final excel = Excel.decodeBytes(bytes);
      final sheets = <ParsedSheet>[];

      for (final tableKey in excel.tables.keys) {
        final sheetData = excel.tables[tableKey];
        if (sheetData == null || sheetData.rows.isEmpty) continue;

        // Convert List<List<Data?>> to List<List<dynamic>>
        final rawRows = <List<dynamic>>[];
        for (final row in sheetData.rows) {
          final rowValues = row.map((cell) => _extractExcelCellValue(cell?.value)).toList();
          // Skip completely empty rows
          if (rowValues.any((v) => v.toString().trim().isNotEmpty)) {
            rawRows.add(rowValues);
          }
        }

        if (rawRows.isNotEmpty) {
          final parsedSheet = _processSheetRows(tableKey, rawRows);
          sheets.add(parsedSheet);
        }
      }

      if (sheets.isEmpty) {
        return ParsedSpreadsheet(
          fileName: fileName,
          sheets: const [],
          errors: const ['Excel workbook contains no readable sheets or rows.'],
        );
      }

      return ParsedSpreadsheet(
        fileName: fileName,
        sheets: sheets,
      );
    } catch (e) {
      return ParsedSpreadsheet(
        fileName: fileName,
        sheets: const [],
        errors: ['Failed to parse Excel workbook: $e'],
      );
    }
  }

  dynamic _extractExcelCellValue(CellValue? cellValue) {
    if (cellValue == null) return '';
    return switch (cellValue) {
      TextCellValue(:final value) => value,
      IntCellValue(:final value) => value,
      DoubleCellValue(:final value) => value,
      BoolCellValue(:final value) => value,
      DateCellValue(:final year, :final month, :final day) =>
        '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
      DateTimeCellValue(:final year, :final month, :final day) =>
        '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
      TimeCellValue(:final hour, :final minute, :final second) =>
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}',
      FormulaCellValue(:final formula) => formula,
    };
  }

  ParsedSheet _processSheetRows(String sheetName, List<List<dynamic>> rows) {
    if (rows.isEmpty) {
      return ParsedSheet(name: sheetName);
    }

    // Extract reference year from sheetName if present (e.g. "2023", "Budget 2024", "23")
    int? sheetYear;
    final yearMatch4 = RegExp(r'\b(20\d{2})\b').firstMatch(sheetName);
    if (yearMatch4 != null) {
      sheetYear = int.parse(yearMatch4.group(1)!);
    } else {
      final yearMatch2 = RegExp(r'\b(?:FY|Year|Budget|\b)?\s*([2-9]\d)\b', caseSensitive: false).firstMatch(sheetName);
      if (yearMatch2 != null) {
        final yy = int.tryParse(yearMatch2.group(1)!);
        if (yy != null && yy >= 20 && yy <= 40) {
          sheetYear = 2000 + yy;
        }
      }
    }

    // Find the header row (first row that contains at least one period header)
    int headerRowIndex = 0;
    List<ParsedPeriodHeader> periodHeaders = [];

    for (var i = 0; i < rows.length; i++) {
      final candidateRow = rows[i];
      final detected = <ParsedPeriodHeader>[];

      for (var col = 0; col < candidateRow.length; col++) {
        final val = candidateRow[col]?.toString().trim() ?? '';
        if (isPeriodHeader(val)) {
          detected.add(ParsedPeriodHeader(
            rawHeader: val,
            normalizedKey: normalizePeriodHeader(val, referenceYear: sheetYear),
            columnIndex: col,
          ));
        }
      }

      if (detected.isNotEmpty) {
        headerRowIndex = i;
        periodHeaders = detected;
        break;
      }
    }

    final allHeaders = rows[headerRowIndex].map((e) => e?.toString().trim() ?? '').toList();

    // Determine label and category column indices
    int labelColIndex = 0;
    int? categoryColIndex;

    for (var col = 0; col < allHeaders.length; col++) {
      final lower = allHeaders[col].toLowerCase();
      if (lower.contains('category') || lower.contains('type')) {
        categoryColIndex = col;
      } else if (lower.contains('item') || lower.contains('desc') || lower.contains('name') || lower.contains('expense')) {
        labelColIndex = col;
      }
    }

    // If labelColIndex overlaps with a period header, pick first non-period column
    if (periodHeaders.any((p) => p.columnIndex == labelColIndex)) {
      for (var col = 0; col < allHeaders.length; col++) {
        if (!periodHeaders.any((p) => p.columnIndex == col) && col != categoryColIndex) {
          labelColIndex = col;
          break;
        }
      }
    }

    final parsedRows = <ParsedRow>[];
    final warnings = <String>[];

    for (var r = headerRowIndex + 1; r < rows.length; r++) {
      final row = rows[r];
      // Skip empty or all-blank rows
      if (row.isEmpty || row.every((c) => c == null || c.toString().trim().isEmpty)) {
        continue;
      }

      final label = (labelColIndex < row.length ? row[labelColIndex]?.toString().trim() : '') ?? '';
      if (label.isEmpty) continue;

      // Skip summary / total rows
      final lowerLabel = label.toLowerCase();
      if (lowerLabel == 'total' || lowerLabel == 'totals' || lowerLabel == 'summary' || lowerLabel == 'average') {
        continue;
      }

      final category = categoryColIndex != null && categoryColIndex < row.length
          ? row[categoryColIndex]?.toString().trim()
          : null;

      final periodMap = <String, ParsedCell>{};
      for (final period in periodHeaders) {
        if (period.columnIndex < row.length) {
          final cellRaw = row[period.columnIndex];
          final parsed = parseCell(cellRaw);
          periodMap[period.normalizedKey] = parsed;
          periodMap[period.rawHeader] = parsed;
        } else {
          const emptyCell = ParsedCell(rawValue: '');
          periodMap[period.normalizedKey] = emptyCell;
          periodMap[period.rawHeader] = emptyCell;
        }
      }

      parsedRows.add(ParsedRow(
        rowIndex: r,
        rawLabel: label,
        rawCategory: category?.isNotEmpty == true ? category : null,
        periodValues: periodMap,
      ));
    }

    return ParsedSheet(
      name: sheetName,
      allHeaders: allHeaders,
      periodHeaders: periodHeaders,
      rows: parsedRows,
      labelColumnIndex: labelColIndex,
      categoryColumnIndex: categoryColIndex,
      warnings: warnings,
    );
  }
}
