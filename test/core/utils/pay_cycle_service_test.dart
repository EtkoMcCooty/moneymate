import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/core/utils/pay_cycle_service.dart';

void main() {
  group('PayCycleService Math Engine', () {
    group('getPeriodKey', () {
      test('calculates correct period key for standard 1st of month cycle', () {
        expect(PayCycleService.getPeriodKey(DateTime(2026, 1, 1), 1), equals('2026-01'));
        expect(PayCycleService.getPeriodKey(DateTime(2026, 1, 15), 1), equals('2026-01'));
        expect(PayCycleService.getPeriodKey(DateTime(2026, 1, 31), 1), equals('2026-01'));
        expect(PayCycleService.getPeriodKey(DateTime(2026, 2, 1), 1), equals('2026-02'));
      });

      test('calculates correct period key for mid-month 15th cycle', () {
        // Period 2025-12 spans Dec 15, 2025 to Jan 14, 2026
        expect(PayCycleService.getPeriodKey(DateTime(2025, 12, 15), 15), equals('2025-12'));
        expect(PayCycleService.getPeriodKey(DateTime(2025, 12, 31), 15), equals('2025-12'));
        expect(PayCycleService.getPeriodKey(DateTime(2026, 1, 1), 15), equals('2025-12'));
        expect(PayCycleService.getPeriodKey(DateTime(2026, 1, 14), 15), equals('2025-12'));

        // Period 2026-01 starts on Jan 15, 2026 to Feb 14, 2026
        expect(PayCycleService.getPeriodKey(DateTime(2026, 1, 15), 15), equals('2026-01'));
        expect(PayCycleService.getPeriodKey(DateTime(2026, 2, 14), 15), equals('2026-01'));

        // Period 2026-10 spans Oct 15, 2026 to Nov 14, 2026
        expect(PayCycleService.getPeriodKey(DateTime(2026, 10, 15), 15), equals('2026-10'));
        expect(PayCycleService.getPeriodKey(DateTime(2026, 11, 14), 15), equals('2026-10'));
      });

      test('calculates correct period key for end of month (e.g. 28th)', () {
        // Period 2026-01 spans Jan 28, 2026 to Feb 27, 2026
        expect(PayCycleService.getPeriodKey(DateTime(2026, 1, 28), 28), equals('2026-01'));
        expect(PayCycleService.getPeriodKey(DateTime(2026, 2, 27), 28), equals('2026-01'));
        expect(PayCycleService.getPeriodKey(DateTime(2026, 2, 28), 28), equals('2026-02'));
      });
    });

    group('getDateRange', () {
      test('returns exact date span for 1st of month cycle', () {
        final range = PayCycleService.getDateRange('2026-01', 1);
        expect(range.start, equals(DateTime(2026, 1, 1, 0, 0, 0)));
        expect(range.end, equals(DateTime(2026, 1, 31, 23, 59, 59, 999)));
      });

      test('returns exact date span for 15th cycle across year boundary', () {
        // Period 2025-12 starts Dec 15, 2025 and ends Jan 14, 2026
        final range = PayCycleService.getDateRange('2025-12', 15);
        expect(range.start, equals(DateTime(2025, 12, 15, 0, 0, 0)));
        expect(range.end, equals(DateTime(2026, 1, 14, 23, 59, 59, 999)));
      });

      test('returns exact date span for 15th cycle in standard month', () {
        // Period 2026-10 starts Oct 15, 2026 and ends Nov 14, 2026
        final range = PayCycleService.getDateRange('2026-10', 15);
        expect(range.start, equals(DateTime(2026, 10, 15, 0, 0, 0)));
        expect(range.end, equals(DateTime(2026, 11, 14, 23, 59, 59, 999)));
      });

      test('safely clamps end of month for short months like February', () {
        // Period 2026-01 with cycle start day 31: starts Jan 31, ends Feb 28
        final range = PayCycleService.getDateRange('2026-01', 31);
        expect(range.start.month, equals(1));
        expect(range.start.day, equals(31));
        expect(range.end.month, equals(2));
        expect(range.end.day, equals(28)); // Non-leap year 2026
      });
    });

    group('Formatting & Navigation', () {
      test('formats integer day into proper English ordinal', () {
        expect(PayCycleService.formatOrdinal(1), equals('1st'));
        expect(PayCycleService.formatOrdinal(2), equals('2nd'));
        expect(PayCycleService.formatOrdinal(3), equals('3rd'));
        expect(PayCycleService.formatOrdinal(4), equals('4th'));
        expect(PayCycleService.formatOrdinal(11), equals('11th'));
        expect(PayCycleService.formatOrdinal(12), equals('12th'));
        expect(PayCycleService.formatOrdinal(13), equals('13th'));
        expect(PayCycleService.formatOrdinal(18), equals('18th'));
        expect(PayCycleService.formatOrdinal(21), equals('21st'));
        expect(PayCycleService.formatOrdinal(22), equals('22nd'));
        expect(PayCycleService.formatOrdinal(23), equals('23rd'));
        expect(PayCycleService.formatOrdinal(31), equals('31st'));
      });

      test('formats user friendly period title', () {
        expect(PayCycleService.formatPeriodTitle('2026-01'), equals('January 2026'));
        expect(PayCycleService.formatPeriodTitle('2026-11'), equals('November 2026'));
      });

      test('formats user friendly date span string', () {
        final span1 = PayCycleService.formatPeriodDateSpan('2026-01', 1);
        expect(span1, equals('1 Jan 2026 – 31 Jan 2026'));

        final span15 = PayCycleService.formatPeriodDateSpan('2026-10', 15);
        expect(span15, equals('15 Oct 2026 – 14 Nov 2026'));

        final spanCrossYear = PayCycleService.formatPeriodDateSpan('2025-12', 15);
        expect(spanCrossYear, equals('15 Dec 2025 – 14 Jan 2026'));
      });

      test('generates adjacent period keys cleanly', () {
        final keys = PayCycleService.generateAdjacentPeriodKeys('2026-02', countBefore: 2, countAfter: 2);
        expect(keys, equals([
          '2025-12',
          '2026-01',
          '2026-02',
          '2026-03',
          '2026-04',
        ]));
      });
    });
  });
}
