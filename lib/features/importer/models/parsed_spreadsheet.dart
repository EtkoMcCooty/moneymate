/// Represents a parsed cell value in a spreadsheet.
class ParsedCell {
  final double? amount;
  final String rawValue;
  final String? note;

  const ParsedCell({
    this.amount,
    required this.rawValue,
    this.note,
  });

  @override
  String toString() => 'ParsedCell(amount: $amount, note: $note, raw: $rawValue)';
}

/// Represents a detected period/month column in a spreadsheet.
class ParsedPeriodHeader {
  final String rawHeader;
  final String normalizedKey;
  final int columnIndex;

  const ParsedPeriodHeader({
    required this.rawHeader,
    required this.normalizedKey,
    required this.columnIndex,
  });

  @override
  String toString() => 'ParsedPeriodHeader($rawHeader -> $normalizedKey at col $columnIndex)';
}

/// Represents an item or expense row parsed from a spreadsheet.
class ParsedRow {
  final int rowIndex;
  final String rawLabel;
  final String? rawCategory;
  final Map<String, ParsedCell> periodValues;

  const ParsedRow({
    required this.rowIndex,
    required this.rawLabel,
    this.rawCategory,
    required this.periodValues,
  });

  @override
  String toString() => 'ParsedRow(row $rowIndex: "$rawLabel", cat: $rawCategory, periods: ${periodValues.length})';
}

/// Represents an individual sheet within a parsed workbook or CSV file.
class ParsedSheet {
  final String name;
  final List<String> allHeaders;
  final List<ParsedPeriodHeader> periodHeaders;
  final List<ParsedRow> rows;
  final int labelColumnIndex;
  final int? categoryColumnIndex;
  final List<String> warnings;

  const ParsedSheet({
    required this.name,
    this.allHeaders = const [],
    this.periodHeaders = const [],
    this.rows = const [],
    this.labelColumnIndex = 0,
    this.categoryColumnIndex,
    this.warnings = const [],
  });
}

/// The root model encapsulating the complete parsed spreadsheet file.
class ParsedSpreadsheet {
  final String fileName;
  final List<ParsedSheet> sheets;
  final List<String> errors;

  const ParsedSpreadsheet({
    required this.fileName,
    this.sheets = const [],
    this.errors = const [],
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get isEmpty => sheets.isEmpty || sheets.every((s) => s.rows.isEmpty);

  /// Total number of unique period header keys across all sheets.
  int get totalPeriodMonths => allPeriodHeaders.length;

  /// Returns all unique period headers across all sheets, sorted chronologically.
  List<ParsedPeriodHeader> get allPeriodHeaders {
    final seen = <String>{};
    final result = <ParsedPeriodHeader>[];
    for (final s in sheets) {
      for (final p in s.periodHeaders) {
        if (!seen.contains(p.normalizedKey)) {
          seen.add(p.normalizedKey);
          result.add(p);
        }
      }
    }
    result.sort((a, b) => a.normalizedKey.compareTo(b.normalizedKey));
    return result;
  }
}
