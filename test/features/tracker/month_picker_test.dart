import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moneymate/core/database/app_database.dart';
import 'package:moneymate/core/database/database_provider.dart';
import 'package:moneymate/core/utils/pay_cycle_service.dart';
import 'package:moneymate/features/tracker/views/tracker_screen.dart';
import 'package:moneymate/features/tracker/views/widgets/month_picker_sheet.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());

    final trackerId = await db.into(db.trackers).insert(
          TrackersCompanion.insert(
            name: 'My Tracker',
            cycleStartDay: const Value(15),
            currencySymbol: const Value('£'),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
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

    final salaryItemId = await db.into(db.financeItems).insert(
          FinanceItemsCompanion.insert(categoryId: incomeCatId, name: 'Salary'),
        );

    // Insert entries for two distinct periods: 2024-05 and 2026-03
    await db.into(db.itemEntries).insert(
          ItemEntriesCompanion.insert(
            itemId: salaryItemId,
            periodKey: '2024-05',
            amount: const Value(3000.0),
          ),
        );

    await db.into(db.itemEntries).insert(
          ItemEntriesCompanion.insert(
            itemId: salaryItemId,
            periodKey: '2026-03',
            amount: const Value(3200.0),
          ),
        );
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
        home: TrackerScreen(),
      ),
    );
  }

  group('MonthPickerSheet Widget & Integration Tests', () {
    testWidgets('opens month picker bottom sheet when tapping AppBar calendar icon',
        (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      final calendarButton = find.byKey(const Key('tracker_calendar_button'));
      expect(calendarButton, findsOneWidget);

      await tester.tap(calendarButton);
      await tester.pumpAndSettle();

      expect(find.byType(MonthPickerSheet), findsOneWidget);
      expect(find.text('Select Pay Period'), findsOneWidget);
      expect(find.text('Jump to today'), findsOneWidget);
    });

    testWidgets('opens month picker bottom sheet when tapping period header',
        (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      final headerTap = find.byKey(const Key('tracker_period_header_tap'));
      expect(headerTap, findsOneWidget);

      await tester.tap(headerTap);
      await tester.pumpAndSettle();

      expect(find.byType(MonthPickerSheet), findsOneWidget);
      expect(find.text('Select Pay Period'), findsOneWidget);
    });

    testWidgets('shows year pills including recorded years and switches viewed year on tap',
        (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('tracker_calendar_button')));
      await tester.pumpAndSettle();

      // 2024 pill should exist because 2024-05 has a recorded entry
      final pill2024 = find.byKey(const Key('year_pill_2024'));
      expect(pill2024, findsOneWidget);

      // Tap 2024 pill to switch view to 2024
      await tester.tap(pill2024);
      await tester.pumpAndSettle();

      // Month 5 (May) in 2024 should have the data indicator badge
      final mayIndicator = find.byKey(const Key('data_indicator_2024-05'));
      expect(mayIndicator, findsOneWidget);
    });

    testWidgets('selecting a month closes bottom sheet and selects period in ledger',
        (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('tracker_calendar_button')));
      await tester.pumpAndSettle();

      // Switch to 2024
      await tester.tap(find.byKey(const Key('year_pill_2024')));
      await tester.pumpAndSettle();

      // Tap May (month 5)
      final mayButton = find.byKey(const Key('month_picker_month_5'));
      expect(mayButton, findsOneWidget);
      await tester.tap(mayButton);
      await tester.pumpAndSettle();

      // Sheet should be dismissed
      expect(find.byType(MonthPickerSheet), findsNothing);

      // Header should now reflect May 2024
      expect(find.text('May 2024'), findsOneWidget);
    });

    testWidgets('tapping "Jump to today" snaps to current active period',
        (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Switch to an older period first
      await tester.tap(find.byKey(const Key('tracker_calendar_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('year_pill_2024')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('month_picker_month_5')));
      await tester.pumpAndSettle();

      expect(find.text('May 2024'), findsOneWidget);

      // Open picker again and tap "Jump to today"
      await tester.tap(find.byKey(const Key('tracker_calendar_button')));
      await tester.pumpAndSettle();

      final jumpButton = find.byKey(const Key('jump_to_current_period_button'));
      expect(jumpButton, findsOneWidget);

      await tester.tap(jumpButton);
      await tester.pumpAndSettle();

      // Sheet dismissed
      expect(find.byType(MonthPickerSheet), findsNothing);

      // Period should be current pay cycle
      final expectedCurrentKey =
          PayCycleService.getPeriodKey(DateTime.now(), 15);
      final expectedTitle =
          PayCycleService.formatPeriodTitle(expectedCurrentKey);
      expect(find.text(expectedTitle), findsOneWidget);
    });
  });
}
