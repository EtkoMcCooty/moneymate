import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('provides light theme with proper branding colors and typography', () {
      final theme = AppTheme.lightTheme;
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, equals(AppTheme.primaryColor));
      expect(theme.scaffoldBackgroundColor, equals(AppTheme.backgroundColor));
    });

    test('provides dark theme with proper color scheme', () {
      final theme = AppTheme.darkTheme;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, equals(Brightness.dark));
    });
  });
}
