import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moneymate/app.dart';
import 'package:moneymate/core/database/app_database.dart';
import 'package:moneymate/core/database/database_provider.dart';
import 'package:moneymate/features/shell/views/app_shell_screen.dart';
import 'package:moneymate/features/updater/services/github_release_service.dart';
import 'package:moneymate/features/updater/state/update_notifier.dart';
import 'package:moneymate/features/updater/state/update_state.dart';
import 'package:moneymate/features/updater/views/update_prompt_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';

http.Response _releaseResponse({
  String tagName = 'v0.2.0',
  String name = 'Release v0.2.0',
  String body = '### 🚀 What\'s New\n- Faster tracker loading',
}) {
  return http.Response(
    _releaseJson(tagName: tagName, name: name, body: body),
    200,
    headers: const {'content-type': 'application/json; charset=utf-8'},
  );
}

String _releaseJson({
  String tagName = 'v0.2.0',
  String name = 'Release v0.2.0',
  String body = '### 🚀 What\'s New\n- Faster tracker loading',
}) {
  return jsonEncode({
    'tag_name': tagName,
    'name': name,
    'body': body,
    'published_at': '2026-11-14T12:00:00Z',
    'html_url': 'https://github.com/EtkoMcCooty/moneymate/releases/tag/$tagName',
    'assets': [
      {
        'name': 'app-release.apk',
        'browser_download_url':
            'https://github.com/EtkoMcCooty/moneymate/releases/download/$tagName/app-release.apk',
        'size': 24000000,
      },
    ],
  });
}

void main() {
  group('UpdateNotifier startup check', () {
    test('detects newer release once per session and populates state', () async {
      var requestCount = 0;
      final client = MockClient((request) async {
        requestCount++;
        return _releaseResponse(tagName: 'v0.2.0');
      });

      final notifier = UpdateNotifier(
        service: GitHubReleaseService(client: client),
        versionProvider: () async => '0.1.0+1',
      );

      final shouldPromptFirst = await notifier.checkForStartupUpdate();

      expect(shouldPromptFirst, isTrue);
      expect(requestCount, equals(1));
      expect(notifier.state.status, equals(UpdateStatus.available));
      expect(notifier.state.release?.version, equals('0.2.0'));
      expect(notifier.state.currentVersion, equals('0.1.0+1'));
      expect(notifier.state.hasCheckedOnStartup, isTrue);
      expect(notifier.state.shouldShowStartupPrompt, isTrue);

      // Subsequent startup checks in the same session short-circuit without HTTP calls
      final shouldPromptSecond = await notifier.checkForStartupUpdate();
      expect(shouldPromptSecond, isFalse);
      expect(requestCount, equals(1));
    });

    test('transitions to upToDate when already on latest version or when 404 is returned', () async {
      final upToDateClient = MockClient((request) async {
        return _releaseResponse(tagName: 'v0.1.0');
      });

      final upToDateNotifier = UpdateNotifier(
        service: GitHubReleaseService(client: upToDateClient),
        versionProvider: () async => '0.1.0+1',
      );

      expect(await upToDateNotifier.checkForStartupUpdate(), isFalse);
      expect(upToDateNotifier.state.status, equals(UpdateStatus.upToDate));
      expect(upToDateNotifier.state.hasCheckedOnStartup, isTrue);
      expect(upToDateNotifier.state.shouldShowStartupPrompt, isFalse);

      final notFoundClient = MockClient((request) async {
        return http.Response('{"message": "Not Found"}', 404);
      });

      final notFoundNotifier = UpdateNotifier(
        service: GitHubReleaseService(client: notFoundClient),
        versionProvider: () async => '0.1.0+1',
      );

      expect(await notFoundNotifier.checkForStartupUpdate(), isFalse);
      expect(notFoundNotifier.state.status, equals(UpdateStatus.upToDate));
      expect(notFoundNotifier.state.hasCheckedOnStartup, isTrue);
    });

    test('fails silently on network or server errors during startup while manual check reports error', () async {
      final throwingClient = MockClient((request) async {
        throw const SocketException('No internet connection');
      });

      final offlineNotifier = UpdateNotifier(
        service: GitHubReleaseService(client: throwingClient),
        versionProvider: () async => '0.1.0+1',
      );

      final result = await offlineNotifier.checkForStartupUpdate();
      expect(result, isFalse);
      expect(offlineNotifier.state.status, equals(UpdateStatus.idle));
      expect(offlineNotifier.state.errorMessage, isNull);
      expect(offlineNotifier.state.hasCheckedOnStartup, isTrue);

      // Manual checkForUpdate still surfaces descriptive error state
      await offlineNotifier.checkForUpdate();
      expect(offlineNotifier.state.status, equals(UpdateStatus.error));
      expect(offlineNotifier.state.errorMessage, isNotNull);

      final serverErrorClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final serverErrorNotifier = UpdateNotifier(
        service: GitHubReleaseService(client: serverErrorClient),
        versionProvider: () async => '0.1.0+1',
      );

      expect(await serverErrorNotifier.checkForStartupUpdate(), isFalse);
      expect(serverErrorNotifier.state.status, equals(UpdateStatus.idle));
      expect(serverErrorNotifier.state.errorMessage, isNull);
      expect(serverErrorNotifier.state.hasCheckedOnStartup, isTrue);

      await serverErrorNotifier.checkForUpdate();
      expect(serverErrorNotifier.state.status, equals(UpdateStatus.error));
      expect(
        serverErrorNotifier.state.errorMessage,
        contains('GitHub API returned status 500'),
      );
    });

    test('dismissUpdate records dismissedVersion and disables shouldShowStartupPrompt', () async {
      final client = MockClient((request) async {
        return _releaseResponse(tagName: 'v0.2.0');
      });

      final notifier = UpdateNotifier(
        service: GitHubReleaseService(client: client),
        versionProvider: () async => '0.1.0+1',
      );

      await notifier.checkForStartupUpdate();
      expect(notifier.state.shouldShowStartupPrompt, isTrue);

      notifier.dismissUpdate('0.2.0');

      expect(notifier.state.hasPromptedOnStartup, isTrue);
      expect(notifier.state.dismissedVersion, equals('0.2.0'));
      expect(notifier.state.shouldShowStartupPrompt, isFalse);
    });
  });

  group('MoneyMateApp & AppShellScreen startup update prompt', () {
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

    testWidgets('automatically shows UpdatePromptDialog on launch when newer release is available and records dismissal on Later', (tester) async {
      final client = MockClient((request) async {
        return _releaseResponse(tagName: 'v0.2.0');
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

      // Shell renders without blocking
      expect(find.byType(AppShellScreen), findsOneWidget);
      expect(find.byKey(const Key('tracker_screen_content')), findsOneWidget);

      await tester.pumpAndSettle();

      // Update prompt appears automatically after startup check
      expect(find.byType(UpdatePromptDialog), findsOneWidget);
      expect(find.text('Update Available!'), findsOneWidget);
      expect(find.textContaining('Version 0.2.0 is now ready'), findsOneWidget);

      // Tap Later to dismiss
      await tester.tap(find.text('Later'));
      await tester.pumpAndSettle();

      expect(find.byType(UpdatePromptDialog), findsNothing);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(AppShellScreen)),
      );
      expect(
        container.read(updateNotifierProvider).dismissedVersion,
        equals('0.2.0'),
      );
      expect(
        container.read(updateNotifierProvider).hasPromptedOnStartup,
        isTrue,
      );

      // Navigating to Settings shows available update subtitle
      await tester.tap(find.text('Settings').first);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Check for updates'), 200);
      expect(
        find.textContaining('Update 0.2.0 available'),
        findsOneWidget,
      );
    });

    testWidgets('does not show UpdatePromptDialog or error SnackBar when up to date', (tester) async {
      final client = MockClient((request) async {
        return _releaseResponse(tagName: 'v0.1.0');
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
      expect(find.byType(UpdatePromptDialog), findsNothing);
      expect(find.byType(SnackBar), findsNothing);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(AppShellScreen)),
      );
      final updateState = container.read(updateNotifierProvider);
      expect(updateState.hasCheckedOnStartup, isTrue);
      expect(updateState.status, equals(UpdateStatus.upToDate));
    });

    testWidgets('does not show UpdatePromptDialog or error SnackBar when offline on startup', (tester) async {
      final client = MockClient((request) async {
        throw const SocketException('Offline');
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
      expect(find.byType(UpdatePromptDialog), findsNothing);
      expect(find.byType(SnackBar), findsNothing);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(AppShellScreen)),
      );
      final updateState = container.read(updateNotifierProvider);
      expect(updateState.hasCheckedOnStartup, isTrue);
      expect(updateState.status, equals(UpdateStatus.idle));
    });
  });
}
