import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_filex/open_filex.dart';
import 'package:moneymate/core/theme/app_theme.dart';
import 'package:moneymate/features/updater/models/app_release.dart';
import 'package:moneymate/features/updater/services/apk_download_service.dart';
import 'package:moneymate/features/updater/views/update_prompt_dialog.dart';

class FakeApkDownloadService extends ApkDownloadService {
  final Completer<OpenResult> completer = Completer<OpenResult>();
  void Function(DownloadProgress)? capturedOnProgress;
  bool cancelled = false;

  @override
  Future<OpenResult> downloadAndInstall({
    required String url,
    required void Function(DownloadProgress progress) onProgress,
  }) {
    capturedOnProgress = onProgress;
    return completer.future;
  }

  @override
  void cancel() {
    cancelled = true;
    if (!completer.isCompleted) {
      completer.completeError(Exception('Download was cancelled'));
    }
  }
}

void main() {
  group('UpdatePromptDialog Widget', () {
    final testRelease = AppRelease(
      tagName: 'release-v0.2.0',
      version: '0.2.0',
      title: 'MoneyMate v0.2.0 Update',
      notes: 'New in this version:\n• Offline-first SQLite database\n• Fixed calculation bug',
      apkUrl: 'https://github.com/EtkoMcCooty/moneymate/releases/download/v0.2.0/app-release.apk',
      publishedAt: DateTime(2026, 10, 25),
    );

    testWidgets('displays update dialog with version, notes, and action buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => UpdatePromptDialog.show(
                  context,
                  release: testRelease,
                  currentVersion: '0.1.0',
                ),
                child: const Text('Check for update'),
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Check for update'));
      await tester.pumpAndSettle();

      // Verify header and versions
      expect(find.text('Update Available!'), findsOneWidget);
      expect(find.textContaining('Version 0.2.0 is now ready'), findsOneWidget);
      expect(find.textContaining('Current: 0.1.0'), findsOneWidget);
      expect(find.textContaining('Offline-first SQLite database'), findsOneWidget);

      // Verify buttons
      expect(find.text('Update Now'), findsOneWidget);
      expect(find.text('Later'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('Later'));
      await tester.pumpAndSettle();

      expect(find.text('Update Available!'), findsNothing);
    });

    testWidgets('transitions to downloading state and shows progress when Update Now is tapped on Android', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final fakeService = FakeApkDownloadService();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => UpdatePromptDialog.show(
                  context,
                  release: testRelease,
                  currentVersion: '0.1.0',
                  downloadService: fakeService,
                ),
                child: const Text('Check for update'),
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Check for update'));
      await tester.pumpAndSettle();

      // Tap Update Now
      await tester.tap(find.text('Update Now'));
      await tester.pump();

      // Verify downloading state UI
      expect(find.text('Downloading Update...'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Simulate progress update
      fakeService.capturedOnProgress?.call(
        const DownloadProgress(
          receivedBytes: 15 * 1024 * 1024,
          totalBytes: 30 * 1024 * 1024,
          progress: 0.5,
        ),
      );
      await tester.pump();

      expect(find.text('50% downloaded'), findsOneWidget);
      expect(find.text('15.0 MB / 30.0 MB'), findsOneWidget);

      // Cancel download
      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(fakeService.cancelled, isTrue);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('displays error message and provides retry and browser fallback options on failure', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final fakeService = FakeApkDownloadService();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => UpdatePromptDialog.show(
                  context,
                  release: testRelease,
                  currentVersion: '0.1.0',
                  downloadService: fakeService,
                ),
                child: const Text('Check for update'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Check for update'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Update Now'));
      await tester.pump();

      // Complete with error
      fakeService.completer.completeError(Exception('Network timeout while downloading'));
      await tester.pumpAndSettle();

      // Verify error state UI
      expect(find.textContaining('Network timeout while downloading'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Open in Browser'), findsOneWidget);
      expect(find.text('Dismiss'), findsOneWidget);

      debugDefaultTargetPlatformOverride = null;
    });
  });
}
