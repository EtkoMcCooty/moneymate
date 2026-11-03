import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/pay_cycle_service.dart';
import '../../updater/state/update_notifier.dart';
import '../../updater/state/update_state.dart';
import '../../updater/views/update_prompt_dialog.dart';
import '../../importer/views/import_spreadsheet_dialog.dart';
import '../state/settings_notifier.dart';

/// Screen managing payday settings, currency preferences, spending categories,
/// and in-app updates using plain, friendly everyday language.
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

  void _showPaydayDialog(BuildContext context, WidgetRef ref, int currentDay) {
    var selectedDay = currentDay;
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final now = DateTime.now();
            final sampleKey = PayCycleService.getPeriodKey(now, selectedDay);
            final sampleSpan =
                PayCycleService.formatPeriodDateSpan(sampleKey, selectedDay);

            return AlertDialog(
              title: const Text('Choose your payday'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select the day of the month your monthly pay cycle begins:',
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: selectedDay,
                    decoration: const InputDecoration(
                      labelText: 'Payday',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(31, (index) {
                      final day = index + 1;
                      return DropdownMenuItem<int>(
                        value: day,
                        child: Text(_formatDayOrdinal(day)),
                      );
                    }),
                    onChanged: (newDay) {
                      if (newDay != null) {
                        setState(() => selectedDay = newDay);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current cycle window:',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sampleSpan,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    ref
                        .read(settingsNotifierProvider.notifier)
                        .updateCycleStartDay(selectedDay);
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCurrencyDialog(
      BuildContext context, WidgetRef ref, String currentSymbol) {
    const commonCurrencies = [
      ('£', 'British Pound (£)'),
      ('\$', 'US / CA / AU Dollar (\$)'),
      ('€', 'Euro (€)'),
      ('¥', 'Japanese Yen (¥)'),
      ('₹', 'Indian Rupee (₹)'),
    ];

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: const Text('Choose currency symbol'),
          children: commonCurrencies.map((item) {
            final (symbol, label) = item;
            final isSelected = symbol == currentSymbol;
            return ListTile(
              title: Text(label),
              leading: Text(
                symbol,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              trailing: isSelected
                  ? Icon(Icons.check,
                      color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                ref
                    .read(settingsNotifierProvider.notifier)
                    .updateCurrencySymbol(symbol);
                Navigator.of(dialogContext).pop();
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    var selectedType = 'expense';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Category name',
                      hintText: 'e.g. Subscriptions or Pets',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Category group',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'income', child: Text('Income')),
                      DropdownMenuItem(
                          value: 'expense',
                          child: Text('Bills & Expenses')),
                      DropdownMenuItem(
                          value: 'debt', child: Text('Debts')),
                      DropdownMenuItem(
                          value: 'savings', child: Text('Savings')),
                      DropdownMenuItem(
                          value: 'investment',
                          child: Text('Investments')),
                    ],
                    onChanged: (newType) {
                      if (newType != null) {
                        setState(() => selectedType = newType);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      ref
                          .read(settingsNotifierProvider.notifier)
                          .addCategory(name: name, categoryType: selectedType);
                    }
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static String _formatDayOrdinal(int day) {
    if (day >= 11 && day <= 13) return '${day}th of the month';
    switch (day % 10) {
      case 1:
        return '${day}st of the month';
      case 2:
        return '${day}nd of the month';
      case 3:
        return '${day}rd of the month';
      default:
        return '${day}th of the month';
    }
  }

  static String _formatCategoryTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'income':
        return 'Income';
      case 'expense':
        return 'Bills & Expenses';
      case 'debt':
        return 'Debts';
      case 'savings':
        return 'Savings';
      case 'investment':
        return 'Investments';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsNotifierProvider);
    final updateState = ref.watch(updateNotifierProvider);

    final startDay = settingsState.cycleStartDay;
    final currencySymbol = settingsState.currencySymbol;

    final now = DateTime.now();
    final currentPeriodKey = PayCycleService.getPeriodKey(now, startDay);
    final periodSpan =
        PayCycleService.formatPeriodDateSpan(currentPeriodKey, startDay);

    return Scaffold(
      key: const Key('settings_screen_content'),
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: settingsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              children: [
                // Payday & Pay Period Section
                Text(
                  'Payday & Pay Period',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  child: ListTile(
                    leading: const Icon(Icons.calendar_month_outlined),
                    title: const Text('Monthly Payday'),
                    subtitle: Text(
                      '${_formatDayOrdinal(startDay)}\nActive period: $periodSpan',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showPaydayDialog(context, ref, startDay),
                  ),
                ),
                const SizedBox(height: 24),

                // Currency Section
                Text(
                  'Currency',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  child: ListTile(
                    leading: const Icon(Icons.payments_outlined),
                    title: const Text('Default Currency'),
                    subtitle: Text('Current symbol: $currencySymbol'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        _showCurrencyDialog(context, ref, currencySymbol),
                  ),
                ),
                const SizedBox(height: 24),

                // Spending Categories Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Spending Categories',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddCategoryDialog(context, ref),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  child: Column(
                    children: [
                      for (var i = 0; i < settingsState.categories.length; i++) ...[
                        if (i > 0) const Divider(height: 1),
                        ListTile(
                          title: Text(settingsState.categories[i].name),
                          subtitle: Text(
                            _formatCategoryTypeLabel(
                                settingsState.categories[i].categoryType),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            tooltip: 'Delete category',
                            onPressed: () {
                              ref
                                  .read(settingsNotifierProvider.notifier)
                                  .deleteCategory(
                                      settingsState.categories[i].id);
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Data & Spreadsheets Section
                Text(
                  'Data & Spreadsheets',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  child: ListTile(
                    key: const Key('settings_import_spreadsheet_tile'),
                    leading: const Icon(Icons.upload_file_outlined),
                    title: const Text('Import spreadsheet'),
                    subtitle: const Text(
                      'Import from Excel (.xlsx) or CSV budget file',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => ImportSpreadsheetDialog.show(context),
                  ),
                ),
                const SizedBox(height: 24),

                // App Updates & Version Section
                Text(
                  'App Updates',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  child: ListTile(
                    leading: const Icon(Icons.system_update_rounded),
                    title: const Text('Check for updates'),
                    subtitle: Text(
                      updateState.currentVersion != null
                          ? 'Version ${updateState.currentVersion}'
                          : 'Download the latest version',
                    ),
                    trailing: updateState.status == UpdateStatus.checking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: updateState.status == UpdateStatus.checking
                        ? null
                        : () => _checkUpdates(context, ref),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }
}
