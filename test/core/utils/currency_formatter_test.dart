import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('formats positive amounts with default GBP (£)', () {
      expect(CurrencyFormatter.format(1250.50), equals('£1,250.50'));
      expect(CurrencyFormatter.format(0), equals('£0.00'));
      expect(CurrencyFormatter.format(9.99), equals('£9.99'));
    });

    test('formats negative amounts properly with default GBP (£)', () {
      expect(CurrencyFormatter.format(-45.20), equals('-£45.20'));
    });

    test('supports custom currency symbols', () {
      expect(CurrencyFormatter.format(100.0, symbol: '\$'), equals('\$100.00'));
      expect(CurrencyFormatter.format(100.0, symbol: '€'), equals('€100.00'));
    });

    test('parses formatted strings back to double', () {
      expect(CurrencyFormatter.tryParse('£1,250.50'), equals(1250.50));
      expect(CurrencyFormatter.tryParse('-£45.20'), equals(-45.20));
      expect(CurrencyFormatter.tryParse('invalid'), isNull);
    });
  });
}
