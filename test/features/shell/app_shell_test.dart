import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/app.dart';

void main() {
  group('App Shell & Navigation', () {
    testWidgets('renders navigation destinations and switches tabs', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MoneyMateApp(),
        ),
      );

      // Verify navigation labels exist
      expect(find.text('Tracker'), findsWidgets);
      expect(find.text('Dashboard'), findsWidgets);
      expect(find.text('Settings'), findsWidgets);
      expect(find.byType(NavigationBar), findsOneWidget);

      // Verify tracker screen is initially visible
      expect(find.byKey(const Key('tracker_screen_content')), findsOneWidget);

      // Tap on Dashboard tab
      await tester.tap(find.text('Dashboard').first);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('dashboard_screen_content')), findsOneWidget);

      // Tap on Settings tab
      await tester.tap(find.text('Settings').first);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('settings_screen_content')), findsOneWidget);
    });
  });
}
