import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/core/database/app_database.dart';
import 'package:moneymate/features/importer/models/import_workflow_models.dart';
import 'package:moneymate/features/importer/models/parsed_spreadsheet.dart';
import 'package:moneymate/features/importer/services/spreadsheet_import_commit_service.dart';
import 'package:moneymate/features/importer/services/spreadsheet_parser_service.dart';

void main() {
  late SpreadsheetParserService parser;
  late AppDatabase db;
  late SpreadsheetImportCommitService commitService;

  setUp(() {
    parser = SpreadsheetParserService();
    db = AppDatabase(NativeDatabase.memory());
    commitService = SpreadsheetImportCommitService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Defect Repro: Period Header Normalization & Drift Schema Constraint', () {
    test('normalizePeriodHeader normalizes date span "Dec 15th - Jan 14th" to YYYY-MM starting month', () {
      final key = parser.normalizePeriodHeader('Dec 15th - Jan 14th');

      // Must strictly be 7 characters formatted as YYYY-MM
      expect(key.length, equals(7));
      expect(RegExp(r'^\d{4}-\d{2}$').hasMatch(key), isTrue);
      expect(key, endsWith('-12')); // Belongs to December cycle
    });

    test('normalizePeriodHeader normalizes date span "15 Oct - 14 Nov" to October', () {
      final key = parser.normalizePeriodHeader('15 Oct - 14 Nov', referenceYear: 2026);
      expect(key, equals('2026-10'));
    });

    test('normalizePeriodHeader normalizes plain month "January" or "Jan" to YYYY-MM', () {
      final key = parser.normalizePeriodHeader('January');
      expect(key.length, equals(7));
      expect(RegExp(r'^\d{4}-\d{2}$').hasMatch(key), isTrue);
      expect(key, endsWith('-01'));
    });

    test('SpreadsheetImportCommitService commits rows with "Dec 15th - Jan 14th" header without Drift InvalidDataException', () async {
      final trackerId = await db.into(db.trackers).insert(
            TrackersCompanion.insert(
              name: 'Personal Budget',
              cycleStartDay: const Value(15),
              currencySymbol: const Value('£'),
              createdAt: Value(DateTime.now()),
              updatedAt: Value(DateTime.now()),
            ),
          );

      // Reproduces exact headers from user's spreadsheet
      final periodHeaders = [
        ParsedPeriodHeader(
          rawHeader: 'Dec 15th - Jan 14th',
          normalizedKey: parser.normalizePeriodHeader('Dec 15th - Jan 14th'),
          columnIndex: 1,
        ),
      ];

      final mappings = [
        const ImportRowMapping(
          rowIndex: 1,
          originalLabel: 'Rent',
          cleanName: 'Rent',
          targetCategoryName: 'Household',
          targetCategoryType: 'expense',
          periodValues: {
            'Dec 15th - Jan 14th': ParsedCell(amount: 750.0, rawValue: '750.0'),
          },
        ),
      ];

      // This will throw Drift InvalidDataException if normalizedKey is not 7 characters
      final summary = await commitService.commitImport(
        trackerId: trackerId,
        mappings: mappings,
        periodHeaders: periodHeaders,
      );

      expect(summary.itemsCount, equals(1));
      expect(summary.entriesCount, equals(1));

      final entries = await db.select(db.itemEntries).get();
      expect(entries.length, equals(1));
      expect(entries.first.periodKey.length, equals(7));
      expect(RegExp(r'^\d{4}-\d{2}$').hasMatch(entries.first.periodKey), isTrue);
      expect(entries.first.periodKey, endsWith('-12'));
    });
  });
}
