import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:moneymate/app.dart';
import 'package:moneymate/core/database/app_database.dart';
import 'package:moneymate/core/database/database_provider.dart';
import 'package:moneymate/features/shell/views/app_shell_screen.dart';
import 'package:moneymate/features/tracker/views/tracker_screen.dart';
import 'package:moneymate/features/updater/services/github_release_service.dart';
import 'package:moneymate/features/updater/state/update_notifier.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  group('MoneyMate Smoke Test', () {
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

    testWidgets('boots MoneyMateApp shell and Tracker view without errors', (tester) async {
      final client = MockClient((_) async {
        return http.Response(
          jsonEncode({
            'tag_name': 'v0.1.0',
            'name': 'Release v0.1.0',
            'body': '',
            'published_at': '2026-11-14T12:00:00Z',
            'html_url': 'https://github.com/EtkoMcCooty/moneymate/releases/tag/v0.1.0',
            'assets': <Map<String, dynamic>>[],
          }),
          200,
          headers: const {'content-type': 'application/json; charset=utf-8'},
        );
      });

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

      expect(find.byType(AppShellScreen), findsOneWidget);
      expect(find.byType(TrackerScreen), findsOneWidget);
      expect(find.text('Monthly Tracker'), findsOneWidget);
    });
  });
}
