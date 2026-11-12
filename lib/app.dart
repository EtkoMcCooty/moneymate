import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/state/theme_mode_notifier.dart';
import 'features/shell/views/app_shell_screen.dart';

/// Root application widget configuring theme, localization, and shell navigation.
class MoneyMateApp extends ConsumerWidget {
  const MoneyMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const AppShellScreen(),
    );
  }
}
