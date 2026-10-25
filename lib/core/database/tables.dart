import 'package:drift/drift.dart';

/// Table representing user finance trackers.
class Trackers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get cycleStartDay => integer().withDefault(const Constant(15))();
  TextColumn get currencySymbol => text().withDefault(const Constant('£'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Table representing groups/categories within a tracker (e.g. Income, Household, Debts).
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get trackerId => integer().references(Trackers, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get categoryType => text()(); // income, expense, debt, savings, investment
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// Table representing individual line items (e.g. Rent, Groceries, Council Tax).
class FinanceItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(Categories, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get dueDay => integer().nullable()(); // e.g. 29 for 29th of the month
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
}

/// Table representing principal balance and interest metadata for debts.
class DebtMetadata extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get itemId => integer().references(FinanceItems, #id, onDelete: KeyAction.cascade)();
  RealColumn get totalPrincipal => real().withDefault(const Constant(0.0))();
  RealColumn get interestRate => real().withDefault(const Constant(0.0))();
}

/// Table recording monthly or pay-cycle amounts and notes for line items.
class ItemEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get itemId => integer().references(FinanceItems, #id, onDelete: KeyAction.cascade)();
  TextColumn get periodKey => text().withLength(min: 7, max: 7)(); // Format: YYYY-MM (e.g. 2026-01)
  RealColumn get amount => real().withDefault(const Constant(0.0))();
  RealColumn get extraPayment => real().withDefault(const Constant(0.0))();
  TextColumn get note => text().nullable()(); // Contextual note, e.g. [1] Half Nursery fees
}

/// Key-value table storing global app preferences.
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
