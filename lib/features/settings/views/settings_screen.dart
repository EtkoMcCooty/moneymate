import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/craft_decorations.dart';
import '../../../core/utils/pay_cycle_service.dart';
import '../../updater/state/update_notifier.dart';
import '../../updater/state/update_state.dart';
import '../../updater/views/update_prompt_dialog.dart';
import '../../importer/views/import_spreadsheet_dialog.dart';
import '../state/settings_notifier.dart';
import '../state/theme_mode_notifier.dart';

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
                      borderRadius: BorderRadius.circular(12),
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
              leading: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  symbol,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check_circle_rounded,
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
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Category group',
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
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              children: [
                // Payday & Pay Period Section
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                  child: Text(
                    'Payday & Pay Period',
                    style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: theme.colorScheme.primary,
                        ),
                  ),
                ),
                Container(
                  decoration: CraftDecorations.cardShadowDecoration(context),
                  child: Material(
                    color: CraftDecorations.surfaceColor(context),
                    shape: CraftDecorations.cardShape(context),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.calendar_month_rounded,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        'Monthly Payday',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${_formatDayOrdinal(startDay)}\nActive period: $periodSpan',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _showPaydayDialog(context, ref, startDay),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Currency Section
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                  child: Text(
                    'Currency',
                    style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: theme.colorScheme.primary,
                        ),
                  ),
                ),
                Container(
                  decoration: CraftDecorations.cardShadowDecoration(context),
                  child: Material(
                    color: CraftDecorations.surfaceColor(context),
                    shape: CraftDecorations.cardShape(context),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.payments_rounded,
                          color: theme.colorScheme.secondary,
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        'Default Currency',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        'Current symbol: $currencySymbol',
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () =>
                          _showCurrencyDialog(context, ref, currencySymbol),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Appearance Section
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                  child: Text(
                    'Appearance',
                    style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: theme.colorScheme.primary,
                        ),
                  ),
                ),
                Container(
                  decoration: CraftDecorations.cardShadowDecoration(context),
                  child: Material(
                    color: CraftDecorations.surfaceColor(context),
                    shape: CraftDecorations.cardShape(context),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.tertiary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  themeMode == ThemeMode.dark
                                      ? Icons.dark_mode_rounded
                                      : themeMode == ThemeMode.light
                                          ? Icons.light_mode_rounded
                                          : Icons.brightness_auto_rounded,
                                  color: theme.colorScheme.tertiary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Theme',
                                      style: TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      themeMode == ThemeMode.system
                                          ? 'Follow system theme'
                                          : themeMode == ThemeMode.light
                                              ? 'Light theme active'
                                              : 'Dark theme active',
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurfaceVariant,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: SegmentedButton<ThemeMode>(
                              key: const Key('theme_mode_segmented_button'),
                              segments: const [
                                ButtonSegment<ThemeMode>(
                                  value: ThemeMode.system,
                                  icon: Icon(Icons.brightness_auto_rounded, size: 16),
                                  label: Text('System'),
                                ),
                                ButtonSegment<ThemeMode>(
                                  value: ThemeMode.light,
                                  icon: Icon(Icons.light_mode_rounded, size: 16),
                                  label: Text('Light'),
                                ),
                                ButtonSegment<ThemeMode>(
                                  value: ThemeMode.dark,
                                  icon: Icon(Icons.dark_mode_rounded, size: 16),
                                  label: Text('Dark'),
                                ),
                              ],
                              selected: {themeMode},
                              onSelectionChanged: (newSelection) {
                                ref
                                    .read(themeModeProvider.notifier)
                                    .setThemeMode(newSelection.first);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Spending Categories Section
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Spending Categories',
                        style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              color: theme.colorScheme.primary,
                            ),
                      ),
                      TextButton.icon(
                        onPressed: () => _showAddCategoryDialog(context, ref),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text(
                          'Add',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: CraftDecorations.cardShadowDecoration(context),
                  child: Material(
                    color: CraftDecorations.surfaceColor(context),
                    shape: CraftDecorations.cardShape(context),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (var i = 0; i < settingsState.categories.length; i++) ...[
                          if (i > 0)
                            Divider(
                              height: 1,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : Colors.black.withValues(alpha: 0.05),
                            ),
                          ListTile(
                            title: Text(
                              settingsState.categories[i].name,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(
                              _formatCategoryTypeLabel(
                                  settingsState.categories[i].categoryType),
                              style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                size: 20,
                                color: theme.colorScheme.error,
                              ),
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
                ),
                const SizedBox(height: 16),

                // Data & Spreadsheets Section
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                  child: Text(
                    'Data & Spreadsheets',
                    style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: theme.colorScheme.primary,
                        ),
                  ),
                ),
                Container(
                  decoration: CraftDecorations.cardShadowDecoration(context),
                  child: Material(
                    color: CraftDecorations.surfaceColor(context),
                    shape: CraftDecorations.cardShape(context),
                    child: ListTile(
                      key: const Key('settings_import_spreadsheet_tile'),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.upload_file_rounded,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        'Import spreadsheet',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        'Import from Excel (.xlsx) or CSV budget file',
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => ImportSpreadsheetDialog.show(context),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // App Updates & Version Section
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                  child: Text(
                    'App Updates',
                    style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: theme.colorScheme.primary,
                        ),
                  ),
                ),
                Container(
                  decoration: CraftDecorations.cardShadowDecoration(context),
                  child: Material(
                    color: CraftDecorations.surfaceColor(context),
                    shape: CraftDecorations.cardShape(context),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.system_update_rounded,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        'Check for updates',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        updateState.currentVersion != null
                            ? 'Version ${updateState.currentVersion}'
                            : 'Download the latest version',
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      trailing: updateState.status == UpdateStatus.checking
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.chevron_right_rounded),
                      onTap: updateState.status == UpdateStatus.checking
                          ? null
                          : () => _checkUpdates(context, ref),
                    ),
                  ),
                ),
                const SizedBox(height: 36),
              ],
            ),
    );
  }
}
