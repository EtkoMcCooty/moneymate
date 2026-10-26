import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../updater/state/update_notifier.dart';
import '../../updater/state/update_state.dart';
import '../../updater/views/update_prompt_dialog.dart';

/// Screen managing pay cycle settings, currency preferences, and categories.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _checkUpdates(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(updateNotifierProvider.notifier);
    await notifier.checkForUpdate();

    if (!context.mounted) return;
    final state = ref.read(updateNotifierProvider);

    if (state.status == UpdateStatus.available && state.release != null) {
      UpdatePromptDialog.show(
        context,
        release: state.release!,
        currentVersion: state.currentVersion ?? '0.1.0',
      );
    } else if (state.status == UpdateStatus.upToDate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You're on the latest version!")),
      );
    } else if (state.status == UpdateStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage ?? 'Could not check for updates.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateState = ref.watch(updateNotifierProvider);

    return Scaffold(
      key: const Key('settings_screen_content'),
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.settings_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'App Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set your payday, currency, and spending categories',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: updateState.status == UpdateStatus.checking
                  ? null
                  : () => _checkUpdates(context, ref),
              icon: updateState.status == UpdateStatus.checking
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.system_update_rounded),
              label: Text(
                updateState.status == UpdateStatus.checking
                    ? 'Checking for updates...'
                    : 'Check for updates',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
