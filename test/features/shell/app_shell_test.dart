import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/app.dart';
import 'package:moneymate/core/database/app_database.dart';
import 'package:moneymate/core/database/database_provider.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('App Shell & Navigation', () {
    testWidgets('renders navigation destinations and switches tabs', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
          ],
          child: const MoneyMateApp(),
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
