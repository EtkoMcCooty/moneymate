import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/core/theme/app_theme.dart';
import 'package:moneymate/features/updater/models/app_release.dart';
import 'package:moneymate/features/updater/views/update_prompt_dialog.dart';

void main() {
  group('UpdatePromptDialog Widget', () {
    final testRelease = AppRelease(
      tagName: 'release-v0.2.0',
      version: '0.2.0',
      title: 'MoneyMate v0.2.0 Update',
      notes: 'New in this version:\n- Offline-first SQLite database\n- Fixed calculation bug',
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
  });
}
