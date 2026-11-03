import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/features/importer/models/smart_match_result.dart';
import 'package:moneymate/features/importer/services/smart_matcher_service.dart';

void main() {
  late SmartMatcherService matcher;

  setUp(() {
    matcher = SmartMatcherService();
  });

  group('SmartMatcherService - Due Day Extraction & Clean Name', () {
    test('extracts due day from parenthetical ordinals and numbers', () {
      final rent = matcher.matchLabel('Rent (29th)');
      expect(rent.dueDay, 29);
      expect(rent.cleanName, 'Rent');

      final councilTax = matcher.matchLabel('Council Tax (5th)');
      expect(councilTax.dueDay, 5);
      expect(councilTax.cleanName, 'Council Tax');

      final netflix = matcher.matchLabel('Netflix (12)');
      expect(netflix.dueDay, 12);
      expect(netflix.cleanName, 'Netflix');

      final gym = matcher.matchLabel('Gym (1st)');
      expect(gym.dueDay, 1);
      expect(gym.cleanName, 'Gym');
    });

    test('extracts due day from "due on" or hyphen syntax', () {
      final water = matcher.matchLabel('Water Bill - 18th');
      expect(water.dueDay, 18);
      expect(water.cleanName, 'Water Bill');

      final gas = matcher.matchLabel('British Gas due 22nd');
      expect(gas.dueDay, 22);
      expect(gas.cleanName, 'British Gas');
    });

    test('leaves cleanName intact and returns null dueDay when no due day is present', () {
      final groceries = matcher.matchLabel('Groceries');
      expect(groceries.dueDay, isNull);
      expect(groceries.cleanName, 'Groceries');

      final salary = matcher.matchLabel('Monthly Salary');
      expect(salary.dueDay, isNull);
      expect(salary.cleanName, 'Monthly Salary');
    });

    test('ignores numbers that are not valid calendar days (e.g. > 31)', () {
      final ps5 = matcher.matchLabel('PlayStation 5');
      expect(ps5.dueDay, isNull);
      expect(ps5.cleanName, 'PlayStation 5');

      final code = matcher.matchLabel('Item (99th)');
      expect(code.dueDay, isNull);
      expect(code.cleanName, 'Item (99th)');
    });
  });

  group('SmartMatcherService - Category & Type Categorization', () {
    test('categorizes Income items', () {
      final wage = matcher.matchLabel('Wage');
      expect(wage.suggestedCategoryType, 'income');
      expect(wage.suggestedCategoryName, 'Income');

      final salary = matcher.matchLabel('Salary (Monthly)');
      expect(salary.suggestedCategoryType, 'income');

      final bonus = matcher.matchLabel('Annual Bonus');
      expect(bonus.suggestedCategoryType, 'income');
    });

    test('categorizes Household expense items', () {
      final rent = matcher.matchLabel('Rent (29th)');
      expect(rent.suggestedCategoryType, 'expense');
      expect(rent.suggestedCategoryName, 'Household');

      final councilTax = matcher.matchLabel('Council Tax (5th)');
      expect(councilTax.suggestedCategoryType, 'expense');
      expect(councilTax.suggestedCategoryName, 'Household');

      final broadband = matcher.matchLabel('Virgin Media Broadband');
      expect(broadband.suggestedCategoryType, 'expense');
      expect(broadband.suggestedCategoryName, 'Household');
    });

    test('categorizes Debt items', () {
      final monzoFlex = matcher.matchLabel('Monzo Flex');
      expect(monzoFlex.suggestedCategoryType, 'debt');
      expect(monzoFlex.suggestedCategoryName, 'Debts');
      expect(monzoFlex.isDebt, isTrue);

      final barclaycard = matcher.matchLabel('Barclaycard Credit Card');
      expect(barclaycard.suggestedCategoryType, 'debt');
      expect(barclaycard.isDebt, isTrue);

      final carFinance = matcher.matchLabel('Car Finance (Hire Purchase)');
      expect(carFinance.suggestedCategoryType, 'debt');
      expect(carFinance.isDebt, isTrue);
    });

    test('categorizes Savings and Investment items', () {
      final emergency = matcher.matchLabel('Emergency Fund');
      expect(emergency.suggestedCategoryType, 'savings');
      expect(emergency.suggestedCategoryName, 'Savings');

      final vanguard = matcher.matchLabel('Vanguard S&P 500 ETF');
      expect(vanguard.suggestedCategoryType, 'investment');
      expect(vanguard.suggestedCategoryName, 'Investments');
    });

    test('categorizes Personal / Living expenses', () {
      final groceries = matcher.matchLabel('Tesco Groceries');
      expect(groceries.suggestedCategoryType, 'expense');
      expect(groceries.suggestedCategoryName, 'Personal');

      final netflix = matcher.matchLabel('Netflix (12th)');
      expect(netflix.suggestedCategoryType, 'expense');
      expect(netflix.suggestedCategoryName, 'Personal');
    });
  });

  group('SmartMatcherService - Category Linking with Existing Tracker Categories', () {
    final availableCategories = [
      const AvailableCategory(id: 1, name: 'Income', categoryType: 'income'),
      const AvailableCategory(id: 2, name: 'Household', categoryType: 'expense'),
      const AvailableCategory(id: 3, name: 'Personal', categoryType: 'expense'),
      const AvailableCategory(id: 4, name: 'Debts', categoryType: 'debt'),
      const AvailableCategory(id: 5, name: 'Savings', categoryType: 'savings'),
      const AvailableCategory(id: 6, name: 'Investments', categoryType: 'investment'),
    ];

    test('links matched item to correct existing category id', () {
      final rent = matcher.matchLabel(
        'Rent (29th)',
        availableCategories: availableCategories,
      );
      expect(rent.matchedCategoryId, 2);
      expect(rent.suggestedCategoryName, 'Household');

      final wage = matcher.matchLabel(
        'Main Wage',
        availableCategories: availableCategories,
      );
      expect(wage.matchedCategoryId, 1);
      expect(wage.suggestedCategoryName, 'Income');

      final card = matcher.matchLabel(
        'Amex Credit Card',
        availableCategories: availableCategories,
      );
      expect(card.matchedCategoryId, 4);
      expect(card.suggestedCategoryName, 'Debts');
    });

    test('respects explicit spreadsheet rawCategory hint when provided', () {
      final customItem = matcher.matchLabel(
        'Unknown Mystery Expense',
        rawCategoryHint: 'Household',
        availableCategories: availableCategories,
      );
      expect(customItem.matchedCategoryId, 2);
      expect(customItem.suggestedCategoryName, 'Household');
      expect(customItem.suggestedCategoryType, 'expense');
    });

    test('flags unknown items as ambiguous with low confidence for user review', () {
      final unknown = matcher.matchLabel('XYZ-99901 QW');
      expect(unknown.isAmbiguous, isTrue);
      expect(unknown.confidence, lessThan(0.7));
    });
  });
}
