import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Utility class for currency formatting and parsing across MoneyMate.
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Formats a given number [amount] into a currency string with [symbol].
  /// Defaults to British Pound Sterling (£ / GBP).
  static String format(
    num amount, {
    String symbol = AppConstants.defaultCurrencySymbol,
    int decimalDigits = 2,
  }) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return formatter.format(amount);
  }

  /// Attempts to parse a formatted currency string back into a [double].
  /// Returns `null` if parsing fails.
  static double? tryParse(String value) {
    final sanitized = value
        .replaceAll(RegExp(r'[^\d.-]'), '')
        .trim();
    if (sanitized.isEmpty) return null;
    return double.tryParse(sanitized);
  }
}
