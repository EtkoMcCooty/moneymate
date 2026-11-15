import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moneymate/app.dart';
import 'package:moneymate/core/database/app_database.dart';
import 'package:moneymate/core/database/database_provider.dart';
import 'package:moneymate/core/utils/currency_formatter.dart';
import 'package:moneymate/core/utils/pay_cycle_service.dart';
import 'package:moneymate/features/dashboard/views/widgets/category_breakdown_section.dart';
import 'package:moneymate/features/dashboard/views/widgets/dashboard_kpi_cards.dart';
import 'package:moneymate/features/dashboard/views/widgets/dashboard_trend_chart.dart';
import 'package:moneymate/features/settings/views/settings_screen.dart';
import 'package:moneymate/features/shell/state/navigation_provider.dart';
import 'package:moneymate/features/shell/views/app_shell_screen.dart';
import 'package:moneymate/features/tracker/views/tracker_screen.dart';
import 'package:moneymate/features/updater/services/github_release_service.dart';
import 'package:moneymate/features/updater/state/update_notifier.dart';
import 'package:moneymate/features/updater/views/update_prompt_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';

http.Response _upToDateReleaseResponse() {
  return http.Response(
    jsonEncode({
      'tag_name': 'v0.1.0',
      'name': 'Release v0.1.0',
      'body': '### 🚀 What\'s New\n- Baseline release',
      'published_at': '2026-11-14T12:00:00Z',
      'html_url': 'https://github.com/EtkoMcCooty/moneymate/releases/tag/v0.1.0',
      'assets': <Map<String, dynamic>>[],
    }),
    200,
    headers: const {'content-type': 'application/json; charset=utf-8'},
  );
}

void main() {
  group('Edge Case Validation — CurrencyFormatter & PayCycleService', () {
    test('CurrencyFormatter.format handles NaN and Infinity without crashing or leaking tokens', () {
      expect(CurrencyFormatter.format(double.nan), equals('£0.00'));
      expect(CurrencyFormatter.format(double.infinity), equals('£0.00'));
      expect(CurrencyFormatter.format(double.negativeInfinity), equals('£0.00'));
      expect(
        CurrencyFormatter.format(double.nan, symbol: r'$', decimalDigits: 0),
        equals(r'$0'),
      );
    });

    test('PayCycleService.formatPeriodTitle falls back gracefully on malformed or out-of-range keys', () {
      expect(PayCycleService.formatPeriodTitle(''), equals('Current Period'));
      expect(PayCycleService.formatPeriodTitle('invalid'), equals('invalid'));
      expect(PayCycleService.formatPeriodTitle('2026-00'), equals('2026-00'));
      expect(PayCycleService.formatPeriodTitle('2026-13'), equals('2026-13'));
      expect(PayCycleService.formatPeriodTitle('2026-02'), equals('February 2026'));
    });

    test('PayCycleService.getDateRange handles leap-year February boundaries for high start days', () {
      final leapRange = PayCycleService.getDateRange('2024-01', 31);
      expect(leapRange.start, equals(DateTime(2024, 1, 31, 0, 0, 0)));
      expect(leapRange.end, equals(DateTime(2024, 2, 29, 23, 59, 59, 999)));

      final febLeapRange = PayCycleService.getDateRange('2024-02', 31);
      expect(febLeapRange.start, equals(DateTime(2024, 2, 29, 0, 0, 0)));
      expect(febLeapRange.end, equals(DateTime(2024, 3, 30, 23, 59, 59, 999)));
    });
  });

  group('Empty State Polish — TrackerScreen & DashboardScreen', () {
    late AppDatabase db;

    setUp(() {
      PackageInfo.setMockInitialValues(
        appName: 'MoneyMate',
        packageName: 'com.moneymate.app',
        version: '0.1.0',
        buildNumber: '1',
        buildSignature: '',
      );
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('TrackerScreen shows actionable empty state when all categories are removed', (tester) async {
      // Seed tracker with zero categories
      await db.into(db.trackers).insert(
            TrackersCompanion.insert(name: 'My Tracker'),
          );

      late ProviderContainer container;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            githubReleaseServiceProvider.overrideWithValue(
              GitHubReleaseService(
                client: MockClient((_) async => _upToDateReleaseResponse()),
              ),
            ),
          ],
          child: Consumer(
            builder: (context, ref, child) {
              container = ProviderScope.containerOf(context);
              return const MaterialApp(home: TrackerScreen());
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('tracker_empty_sections_card')), findsOneWidget);
      expect(find.text('No budget sections yet'), findsOneWidget);
      expect(
        find.byKey(const Key('tracker_empty_settings_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tracker_empty_import_button')),
        findsOneWidget,
      );

      // Tapping Open Settings routes navigation index to Settings (tab 2)
      await tester.ensureVisible(
        find.byKey(const Key('tracker_empty_settings_button')),
      );
      await tester.tap(find.byKey(const Key('tracker_empty_settings_button')));
      await tester.pumpAndSettle();

      expect(container.read(navigationIndexProvider), equals(2));
    });

    testWidgets('DashboardScreen empty state provides quick CTA back to Tracker', (tester) async {
      final client = MockClient((_) async => _upToDateReleaseResponse());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            githubReleaseServiceProvider.overrideWithValue(
              GitHubReleaseService(client: client),
            ),
          ],
          child: const MoneyMateApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Dashboard tab while no financial items exist
      await tester.tap(find.text('Dashboard').first);
      await tester.pumpAndSettle();

      expect(find.text('No tracking data yet'), findsOneWidget);
      expect(
        find.byKey(const Key('dashboard_empty_go_tracker_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dashboard_empty_import_button')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('dashboard_empty_go_tracker_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('tracker_screen_content')), findsOneWidget);
    });
  });

  group('Cross-Slice E2E Smoke Flow', () {
    late AppDatabase db;

    setUp(() {
      PackageInfo.setMockInitialValues(
        appName: 'MoneyMate',
        packageName: 'com.moneymate.app',
        version: '0.1.0',
        buildNumber: '1',
        buildSignature: '',
      );
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('completes full Tracker -> Insights -> Settings user journey cleanly', (tester) async {
      final client = MockClient((_) async => _upToDateReleaseResponse());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            githubReleaseServiceProvider.overrideWithValue(
              GitHubReleaseService(client: client),
            ),
          ],
          child: const MoneyMateApp(),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Boots into AppShellScreen -> Tracker with silent startup update check
      expect(find.byType(AppShellScreen), findsOneWidget);
      expect(find.byKey(const Key('tracker_screen_content')), findsOneWidget);
      expect(find.byType(UpdatePromptDialog), findsNothing);

      // 2. Add Income item ("Salary", £3000)
      final addIncomeBtn = find.byKey(const Key('add_item_button_Income'));
      await tester.ensureVisible(addIncomeBtn);
      await tester.pumpAndSettle();
      await tester.tap(addIncomeBtn);
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('item_name_field')), 'Salary');
      await tester.enterText(
        find.byKey(const Key('item_amount_field')),
        '3000',
      );
      await tester.tap(find.byKey(const Key('save_item_button')));
      await tester.pumpAndSettle();

      // 3. Add Household expense ("Rent", £1200, due 1st)
      final addHouseholdBtn = find.byKey(const Key('add_item_button_Household'));
      await tester.ensureVisible(addHouseholdBtn);
      await tester.pumpAndSettle();
      await tester.tap(addHouseholdBtn);
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('item_name_field')), 'Rent');
      await tester.enterText(
        find.byKey(const Key('item_amount_field')),
        '1200',
      );
      await tester.enterText(find.byKey(const Key('item_due_day_field')), '1');
      await tester.tap(find.byKey(const Key('save_item_button')));
      await tester.pumpAndSettle();

      expect(find.text('Due 1st of month'), findsOneWidget);

      // Scroll back up to verify the Disposable Income hero card
      await tester.drag(
        find
            .descendant(
              of: find.byKey(const Key('tracker_screen_content')),
              matching: find.byType(ListView),
            )
            .first,
        const Offset(0, 600),
      );
      await tester.pumpAndSettle();
      expect(find.text('£1,800.00'), findsWidgets);

      // 4. Switch to Dashboard and verify cross-slice aggregation renders live charts & breakdown
      await tester.tap(find.text('Dashboard').first);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('dashboard_screen_content')), findsOneWidget);
      expect(find.byType(DashboardKpiCards), findsOneWidget);
      expect(find.byType(DashboardTrendChart), findsOneWidget);
      expect(find.textContaining('£1,800'), findsWidgets);

      await tester.scrollUntilVisible(
        find.byType(CategoryBreakdownSection),
        200,
        scrollable: find
            .descendant(
              of: find.byKey(const Key('dashboard_screen_content')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(find.byType(CategoryBreakdownSection), findsOneWidget);

      // 5. Switch to Settings, verify version display, and toggle Dark theme
      await tester.tap(find.text('Settings').first);
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Dark'),
        200,
        scrollable: find
            .descendant(
              of: find.byType(SettingsScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, equals(ThemeMode.dark));
    });
  });
}
