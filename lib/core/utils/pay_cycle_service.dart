import 'dart:math';

/// Represents an inclusive date range with start and end [DateTime] timestamps.
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({
    required this.start,
    required this.end,
  });

  /// Returns true if [date] falls within [start] and [end] inclusive.
  bool contains(DateTime date) {
    return (date.isAtSameMomentAs(start) || date.isAfter(start)) &&
        (date.isAtSameMomentAs(end) || date.isBefore(end));
  }
}

/// Service providing pay cycle calculation, date window generation,
/// and user-friendly formatting without financial jargon.
class PayCycleService {
  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> _shortMonthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// Returns the period key (`YYYY-MM`) for a given [date] and [cycleStartDay].
  ///
  /// For example, if [cycleStartDay] is 15, dates from 15 Dec 2025 to 14 Jan 2026
  /// belong to period `2026-01`.
  static String getPeriodKey(DateTime date, int cycleStartDay) {
    if (cycleStartDay <= 1) {
      return _formatKey(date.year, date.month);
    }

    // Days in current month to safely handle clamped start days
    final daysInCurrentMonth = DateTime(date.year, date.month + 1, 0).day;
    final effectiveStartDay = min(cycleStartDay, daysInCurrentMonth);

    if (date.day >= effectiveStartDay) {
      // Belongs to the following calendar month's pay cycle
      final nextMonth = (date.month % 12) + 1;
      final nextYear = date.month == 12 ? date.year + 1 : date.year;
      return _formatKey(nextYear, nextMonth);
    } else {
      // Belongs to the current calendar month's pay cycle
      return _formatKey(date.year, date.month);
    }
  }

  /// Calculates the exact start and end [DateRange] for a given [periodKey] (`YYYY-MM`)
  /// and [cycleStartDay].
  static DateRange getDateRange(String periodKey, int cycleStartDay) {
    final parts = periodKey.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    if (cycleStartDay <= 1) {
      final daysInMonth = DateTime(year, month + 1, 0).day;
      final start = DateTime(year, month, 1, 0, 0, 0, 0);
      final end = DateTime(year, month, daysInMonth, 23, 59, 59, 999);
      return DateRange(start: start, end: end);
    }

    // Cycle starts in previous month
    final prevYear = month == 1 ? year - 1 : year;
    final prevMonth = month == 1 ? 12 : month - 1;
    final daysInPrevMonth = DateTime(prevYear, prevMonth + 1, 0).day;
    final startDay = min(cycleStartDay, daysInPrevMonth);
    final start = DateTime(prevYear, prevMonth, startDay, 0, 0, 0, 0);

    // Cycle ends the day before cycleStartDay in target month
    final daysInTargetMonth = DateTime(year, month + 1, 0).day;
    var endDay = cycleStartDay - 1;
    if (endDay > daysInTargetMonth) {
      endDay = daysInTargetMonth;
    }
    final end = DateTime(year, month, endDay, 23, 59, 59, 999);

    return DateRange(start: start, end: end);
  }

  /// Formats [periodKey] (e.g. `2026-01`) into a human-friendly title (e.g. `January 2026`).
  static String formatPeriodTitle(String periodKey) {
    final parts = periodKey.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    return '${_monthNames[month - 1]} $year';
  }

  /// Formats the date range of a [periodKey] into a human-readable span
  /// (e.g. `15 Dec 2025 – 14 Jan 2026`).
  static String formatPeriodDateSpan(String periodKey, int cycleStartDay) {
    final range = getDateRange(periodKey, cycleStartDay);
    final startStr =
        '${range.start.day} ${_shortMonthNames[range.start.month - 1]} ${range.start.year}';
    final endStr =
        '${range.end.day} ${_shortMonthNames[range.end.month - 1]} ${range.end.year}';
    return '$startStr \u2013 $endStr';
  }

  /// Generates a list of consecutive period keys around [currentKey].
  static List<String> generateAdjacentPeriodKeys(
    String currentKey, {
    int countBefore = 0,
    int countAfter = 0,
  }) {
    final parts = currentKey.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    final result = <String>[];
    for (var i = -countBefore; i <= countAfter; i++) {
      final totalMonths = (year * 12) + (month - 1) + i;
      final targetYear = totalMonths ~/ 12;
      final targetMonth = (totalMonths % 12) + 1;
      result.add(_formatKey(targetYear, targetMonth));
    }
    return result;
  }

  static String _formatKey(int year, int month) {
    return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';
  }
}
