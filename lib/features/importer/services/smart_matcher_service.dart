import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/smart_match_result.dart';

/// Provider for [SmartMatcherService].
final smartMatcherServiceProvider = Provider<SmartMatcherService>((ref) {
  return SmartMatcherService();
});

/// Service that analyzes raw spreadsheet line labels to extract recurring due dates,
/// normalize item names, and intelligently classify them into Income, Household,
/// Personal, Debts, Savings, or Investment categories.
class SmartMatcherService {
  static const List<String> _incomeKeywords = [
    'wage',
    'salary',
    'paycheck',
    'pay',
    'bonus',
    'dividend',
    'freelance',
    'stipend',
    'side hustle',
    'pension',
    'earning',
    'earnings',
  ];

  static const List<String> _householdKeywords = [
    'rent',
    'mortgage',
    'council tax',
    'water',
    'electricity',
    'gas',
    'energy',
    'broadband',
    'internet',
    'wifi',
    'tv licence',
    'home insurance',
    'service charge',
    'ground rent',
    'repairs',
    'maintenance',
    'british gas',
    'eon',
    'octopus',
    'thames water',
    'virgin media',
    'sky broadband',
    'bt broadband',
  ];

  static const List<String> _debtKeywords = [
    'credit card',
    'loan',
    'overdraft',
    'monzo flex',
    'klarna',
    'clearpay',
    'car finance',
    'hire purchase',
    'barclaycard',
    'amex',
    'american express',
    'debt',
    'financing',
    'student loan',
    'repayment',
  ];

  static const List<String> _savingsKeywords = [
    'saving',
    'savings',
    'emergency fund',
    'isa',
    'rainy day',
    'sinking fund',
    'holiday fund',
    'nest egg',
    'house deposit',
    'cash pot',
  ];

  static const List<String> _investmentKeywords = [
    'investment',
    'investments',
    'stock',
    'stocks',
    'shares',
    'crypto',
    'trading212',
    'vanguard',
    'etf',
    'index fund',
    'pension pot',
    'crypto',
    'bitcoin',
  ];

  static const List<String> _personalKeywords = [
    'groceries',
    'grocery',
    'food',
    'dining',
    'eating out',
    'takeaway',
    'coffee',
    'transport',
    'petrol',
    'fuel',
    'diesel',
    'car insurance',
    'gym',
    'fitness',
    'subscription',
    'subscriptions',
    'netflix',
    'spotify',
    'amazon prime',
    'disney',
    'apple',
    'mobile',
    'phone bill',
    'clothing',
    'haircut',
    'tesco',
    'sainsbury',
    'asda',
    'morrisons',
    'aldi',
    'lidl',
    'personal care',
  ];

  /// Evaluates a raw line item label from a spreadsheet, extracting due day and
  /// classifying it into the most likely category.
  SmartMatchResult matchLabel(
    String rawLabel, {
    String? rawCategoryHint,
    List<AvailableCategory>? availableCategories,
  }) {
    final trimmed = rawLabel.trim();

    // 1. Extract due date and clean the item name
    final (cleanName, dueDay) = _extractDueDayAndClean(trimmed);

    // 2. Classify category and determine confidence
    final classification = _classifyCategory(cleanName, rawCategoryHint);

    // 3. Link with available existing user categories
    int? matchedId;
    if (availableCategories != null && availableCategories.isNotEmpty) {
      matchedId = _findMatchingCategoryId(
        classification.suggestedCategoryName,
        classification.suggestedCategoryType,
        availableCategories,
      );
    }

    return SmartMatchResult(
      originalLabel: trimmed,
      cleanName: cleanName,
      dueDay: dueDay,
      suggestedCategoryName: classification.suggestedCategoryName,
      suggestedCategoryType: classification.suggestedCategoryType,
      matchedCategoryId: matchedId,
      confidence: classification.confidence,
      isDebt: classification.suggestedCategoryType == 'debt',
    );
  }

  (String, int?) _extractDueDayAndClean(String raw) {
    // Check parenthetical due dates: e.g. "Rent (29th)", "Council Tax (5th)", "Netflix (12)"
    final parenMatch = RegExp(r'\((?:due\s+on\s+|due\s+)?(\d{1,2})(?:st|nd|rd|th)?\)',
            caseSensitive: false)
        .firstMatch(raw);

    if (parenMatch != null) {
      final parsedDay = int.tryParse(parenMatch.group(1)!);
      if (parsedDay != null && parsedDay >= 1 && parsedDay <= 31) {
        final cleaned = raw.replaceRange(parenMatch.start, parenMatch.end, '').trim();
        return (cleaned, parsedDay);
      }
    }

    // Check hyphen due dates: e.g. "Water Bill - 18th"
    final hyphenMatch = RegExp(
            r'[-–]\s*(?:due\s+on\s+|due\s+)?(\d{1,2})(?:st|nd|rd|th)?$',
            caseSensitive: false)
        .firstMatch(raw);

    if (hyphenMatch != null) {
      final parsedDay = int.tryParse(hyphenMatch.group(1)!);
      if (parsedDay != null && parsedDay >= 1 && parsedDay <= 31) {
        final cleaned = raw.replaceRange(hyphenMatch.start, hyphenMatch.end, '').trim();
        return (cleaned, parsedDay);
      }
    }

    // Check "due on 22nd" or "due 22nd" in text
    final dueMatch = RegExp(
            r'\b(?:due\s+on|due)\s+(\d{1,2})(?:st|nd|rd|th)?\b',
            caseSensitive: false)
        .firstMatch(raw);

    if (dueMatch != null) {
      final parsedDay = int.tryParse(dueMatch.group(1)!);
      if (parsedDay != null && parsedDay >= 1 && parsedDay <= 31) {
        final cleaned = raw.replaceRange(dueMatch.start, dueMatch.end, '').trim();
        return (cleaned, parsedDay);
      }
    }

    return (raw, null);
  }

  _Classification _classifyCategory(String cleanName, String? rawCategoryHint) {
    final lowerName = cleanName.toLowerCase();

    // If explicit rawCategoryHint provided from spreadsheet column
    if (rawCategoryHint != null && rawCategoryHint.trim().isNotEmpty) {
      final hint = rawCategoryHint.trim().toLowerCase();
      if (hint.contains('income') || hint.contains('wage') || hint.contains('salary')) {
        return const _Classification('Income', 'income', 0.95);
      }
      if (hint.contains('house') || hint.contains('bill') || hint.contains('home') || hint.contains('utility')) {
        return const _Classification('Household', 'expense', 0.95);
      }
      if (hint.contains('debt') || hint.contains('credit') || hint.contains('loan')) {
        return const _Classification('Debts', 'debt', 0.95);
      }
      if (hint.contains('saving')) {
        return const _Classification('Savings', 'savings', 0.95);
      }
      if (hint.contains('invest')) {
        return const _Classification('Investments', 'investment', 0.95);
      }
      if (hint.contains('person') || hint.contains('living') || hint.contains('leisure')) {
        return const _Classification('Personal', 'expense', 0.95);
      }
    }

    // Heuristic keyword matching
    if (_matchesAny(lowerName, _debtKeywords)) {
      return const _Classification('Debts', 'debt', 0.9);
    }

    if (_matchesAny(lowerName, _incomeKeywords)) {
      return const _Classification('Income', 'income', 0.9);
    }

    if (_matchesAny(lowerName, _householdKeywords)) {
      return const _Classification('Household', 'expense', 0.9);
    }

    if (_matchesAny(lowerName, _savingsKeywords)) {
      return const _Classification('Savings', 'savings', 0.9);
    }

    if (_matchesAny(lowerName, _investmentKeywords)) {
      return const _Classification('Investments', 'investment', 0.9);
    }

    if (_matchesAny(lowerName, _personalKeywords)) {
      return const _Classification('Personal', 'expense', 0.9);
    }

    // Fallback: Generic unclassified expense (ambiguous)
    return const _Classification('Personal', 'expense', 0.4);
  }

  bool _matchesAny(String text, List<String> keywords) {
    for (final kw in keywords) {
      final pattern = RegExp(r'\b' + RegExp.escape(kw) + r'\b', caseSensitive: false);
      if (pattern.hasMatch(text)) return true;
    }
    return false;
  }

  int? _findMatchingCategoryId(
    String suggestedName,
    String suggestedType,
    List<AvailableCategory> availableCategories,
  ) {
    // 1. Exact name match (case-insensitive)
    for (final cat in availableCategories) {
      if (cat.name.toLowerCase() == suggestedName.toLowerCase()) {
        return cat.id;
      }
    }

    // 2. Fallback to first category matching the same categoryType
    for (final cat in availableCategories) {
      if (cat.categoryType.toLowerCase() == suggestedType.toLowerCase()) {
        return cat.id;
      }
    }

    return null;
  }
}

class _Classification {
  final String suggestedCategoryName;
  final String suggestedCategoryType;
  final double confidence;

  const _Classification(
    this.suggestedCategoryName,
    this.suggestedCategoryType,
    this.confidence,
  );
}
