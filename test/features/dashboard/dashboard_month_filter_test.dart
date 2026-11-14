import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moneymate/core/database/app_database.dart';
import 'package:moneymate/core/database/database_provider.dart';
import 'package:moneymate/features/dashboard/models/analytics_models.dart';
import 'package:moneymate/features/dashboard/state/dashboard_notifier.dart';
import 'package:moneymate/features/dashboard/views/dashboard_screen.dart';
import 'package:moneymate/features/tracker/views/widgets/month_picker_sheet.dart';

Future<void> _seedSampleFinancialData(AppDatabase db) async {
  final trackerId = await db.into(db.trackers).insert(
        TrackersCompanion.insert(
          name: 'Main Tracker',
          cycleStartDay: const Value(15),
          currencySymbol: const Value('£'),
        ),
      );

  final incomeCatId = await db.into(db.categories).insert(
        CategoriesCompanion.insert(
          trackerId: trackerId,
          name: 'Income',
          categoryType: 'income',
          sortOrder: const Value(0),
        ),
      );
  final householdCatId = await db.into(db.categories).insert(
        CategoriesCompanion.insert(
          trackerId: trackerId,
          name: 'Household',
          categoryType: 'expense',
          sortOrder: const Value(1),
        ),
      );
  final savingsCatId = await db.into(db.categories).insert(
        CategoriesCompanion.insert(
          trackerId: trackerId,
          name: 'Savings',
          categoryType: 'savings',
          sortOrder: const Value(2),
        ),
      );

  final salaryId = await db.into(db.financeItems).insert(
        FinanceItemsCompanion.insert(categoryId: incomeCatId, name: 'Salary'),
      );
  final rentId = await db.into(db.financeItems).insert(
        FinanceItemsCompanion.insert(categoryId: householdCatId, name: 'Rent'),
      );
  final isaId = await db.into(db.financeItems).insert(
        FinanceItemsCompanion.insert(categoryId: savingsCatId, name: 'ISA'),
      );

  // 2026-01: Income 3000, Outflows 1300 (Rent 1000 + ISA 300) => Disposable 1700, Savings Rate 10%
  await db.into(db.itemEntries).insert(
        ItemEntriesCompanion.insert(
          itemId: salaryId,
          periodKey: '2026-01',
          amount: const Value(3000.0),
        ),
      );
  await db.into(db.itemEntries).insert(
        ItemEntriesCompanion.insert(
          itemId: rentId,
          periodKey: '2026-01',
          amount: const Value(1000.0),
        ),
      );
  await db.into(db.itemEntries).insert(
        ItemEntriesCompanion.insert(
          itemId: isaId,
          periodKey: '2026-01',
          amount: const Value(300.0),
        ),
      );

  // 2026-02: Income 4000, Outflows 1800 (Rent 1000 + ISA 800) => Disposable 2200, Savings Rate 20%
  // 2-month averages: Disposable = 1950, Savings Rate = 15%
  await db.into(db.itemEntries).insert(
        ItemEntriesCompanion.insert(
          itemId: salaryId,
          periodKey: '2026-02',
          amount: const Value(4000.0),
        ),
      );
  await db.into(db.itemEntries).insert(
        ItemEntriesCompanion.insert(
          itemId: rentId,
          periodKey: '2026-02',
          amount: const Value(1000.0),
        ),
      );
  await db.into(db.itemEntries).insert(
        ItemEntriesCompanion.insert(
          itemId: isaId,
          periodKey: '2026-02',
          amount: const Value(800.0),
        ),
      );
}

void main() {
  late AppDatabase db;
  late DashboardNotifier notifier;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await _seedSampleFinancialData(db);
    notifier = DashboardNotifier(db);
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestApp() {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
      child: const MaterialApp(
        home: DashboardScreen(),
      ),
    );
  }

  group('DashboardNotifier Month Filter Unit Tests', () {
    test('loadDashboard populates recordedPeriodKeys and cycleStartDay', () async {
      await notifier.loadDashboard();

      final state = notifier.state;
      expect(state.isLoading, isFalse);
      expect(state.cycleStartDay, equals(15));
      expect(state.recordedPeriodKeys, equals({'2026-01', '2026-02'}));
      expect(state.isMonthFiltered, isFalse);
      expect(state.filteredMonthKey, isNull);
    });

    test('filterByMonth focuses period and computes comparative deltas vs average',
        () async {
      await notifier.loadDashboard();

      notifier.filterByMonth('2026-01');
      final state = notifier.state;

      expect(state.filteredMonthKey, equals('2026-01'));
      expect(state.selectedPeriodKey, equals('2026-01'));
      expect(state.isMonthFiltered, isTrue);
      expect(state.data?.selectedPeriodSummary?.periodKey, equals('2026-01'));
      expect(state.data?.averageDisposableIncome, closeTo(1950.0, 0.01));
      expect(state.data?.disposableIncomeDelta, closeTo(-250.0, 0.01));
      expect(state.data?.averageSavingsRate, closeTo(15.0, 0.01));
      expect(state.data?.savingsRateDelta, closeTo(-5.0, 0.01));
    });

    test('clearMonthFilter resets filteredMonthKey and selectedPeriodSummary',
        () async {
      await notifier.loadDashboard();
      notifier.filterByMonth('2026-01');
      expect(notifier.state.isMonthFiltered, isTrue);

      notifier.clearMonthFilter();
      final state = notifier.state;

      expect(state.filteredMonthKey, isNull);
      expect(state.selectedPeriodKey, isNull);
      expect(state.isMonthFiltered, isFalse);
      expect(state.data?.selectedPeriodSummary, isNull);
    });

    test('setTimeframe clears active single-month filter', () async {
      await notifier.loadDashboard();
      notifier.filterByMonth('2026-01');
      expect(notifier.state.isMonthFiltered, isTrue);

      notifier.setTimeframe(AnalyticsTimeframe.threeMonths);
      final state = notifier.state;

      expect(state.selectedTimeframe, equals(AnalyticsTimeframe.threeMonths));
      expect(state.filteredMonthKey, isNull);
      expect(state.selectedPeriodKey, isNull);
      expect(state.isMonthFiltered, isFalse);
    });
  });

  group('DashboardScreen Month Filter Widget Tests', () {
    testWidgets('tapping AppBar calendar button opens MonthPickerSheet',
        (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      final calendarButton = find.byKey(const Key('dashboard_calendar_button'));
      expect(calendarButton, findsOneWidget);

      await tester.tap(calendarButton);
      await tester.pumpAndSettle();

      expect(find.byType(MonthPickerSheet), findsOneWidget);
      expect(find.text('Select Pay Period'), findsOneWidget);
    });

    testWidgets(
        'selecting month activates filter pill and displays comparative KPI delta badges',
        (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Default overview before filtering shows Average
      expect(find.text('Average'), findsOneWidget);
      expect(find.byKey(const Key('dashboard_active_filter_pill')), findsNothing);

      // Open month picker and select Jan 2026
      await tester.tap(find.byKey(const Key('dashboard_calendar_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('year_pill_2026')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('month_picker_month_1')));
      await tester.pumpAndSettle();

      // Sheet closes and active filter banner + delta badges render
      expect(find.byType(MonthPickerSheet), findsNothing);
      expect(find.byKey(const Key('dashboard_active_filter_pill')), findsOneWidget);
      expect(find.text('Viewing January 2026'), findsOneWidget);

      final disposableBadge = find.byKey(const Key('kpi_disposable_delta_badge'));
      expect(disposableBadge, findsOneWidget);
      expect(
        find.descendant(
          of: disposableBadge,
          matching: find.textContaining('vs 6mo avg'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: disposableBadge,
          matching: find.textContaining('-£250.00'),
        ),
        findsOneWidget,
      );

      final savingsBadge = find.byKey(const Key('kpi_savings_delta_badge'));
      expect(savingsBadge, findsOneWidget);
      expect(
        find.descendant(
          of: savingsBadge,
          matching: find.textContaining('-5.0% vs 6mo avg'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('tapping clear button on filter pill resets to timeframe average',
        (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('dashboard_calendar_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('year_pill_2026')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('month_picker_month_1')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('dashboard_active_filter_pill')), findsOneWidget);
      expect(find.byKey(const Key('kpi_disposable_delta_badge')), findsOneWidget);

      await tester.tap(find.byKey(const Key('dashboard_clear_filter_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('dashboard_active_filter_pill')), findsNothing);
      expect(find.byKey(const Key('kpi_disposable_delta_badge')), findsNothing);
      expect(find.text('Average'), findsOneWidget);
    });

    testWidgets('switching timeframe chip clears active single-month filter',
        (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('dashboard_calendar_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('year_pill_2026')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('month_picker_month_1')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('dashboard_active_filter_pill')), findsOneWidget);

      await tester.tap(find.text('3 Months'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('dashboard_active_filter_pill')), findsNothing);
      expect(find.text('Average'), findsOneWidget);
    });
  });
}
