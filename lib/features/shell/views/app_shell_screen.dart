import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/views/dashboard_screen.dart';
import '../../settings/views/settings_screen.dart';
import '../../tracker/views/tracker_screen.dart';
import '../../updater/state/update_notifier.dart';
import '../../updater/state/update_state.dart';
import '../../updater/views/update_prompt_dialog.dart';
import '../state/navigation_provider.dart';

/// App shell providing polished bottom navigation between Tracker, Dashboard, and Settings.
class AppShellScreen extends ConsumerStatefulWidget {
  const AppShellScreen({super.key});

  @override
  ConsumerState<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends ConsumerState<AppShellScreen> {
  static const List<Widget> _screens = [
    TrackerScreen(),
    DashboardScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runStartupUpdateCheck();
    });
  }

  Future<void> _runStartupUpdateCheck() async {
    if (!mounted) return;
    final notifier = ref.read(updateNotifierProvider.notifier);
    final shouldPrompt = await notifier.checkForStartupUpdate();
    if (!mounted || !shouldPrompt) return;

    final updateState = ref.read(updateNotifierProvider);
    final release = updateState.release;
    if (updateState.status == UpdateStatus.available && release != null) {
      notifier.markStartupPromptShown();
      await UpdatePromptDialog.show(
        context,
        release: release,
        currentVersion: updateState.currentVersion ?? '0.1.0',
        onDismissed: () => notifier.dismissUpdate(release.version),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(navigationIndexProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.black.withValues(alpha: 0.06),
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            if (selectedIndex != index) {
              HapticFeedback.selectionClick();
              ref.read(navigationIndexProvider.notifier).state = index;
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.table_chart_outlined),
              selectedIcon: Icon(Icons.table_chart_rounded),
              label: 'Tracker',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights_rounded),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.tune_outlined),
              selectedIcon: Icon(Icons.tune_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
