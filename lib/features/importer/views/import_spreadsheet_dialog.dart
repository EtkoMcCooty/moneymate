import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tracker/state/tracker_ledger_notifier.dart';
import '../models/import_workflow_models.dart';
import '../models/smart_match_result.dart';
import '../state/import_workflow_notifier.dart';

/// Full interactive spreadsheet importer dialog.
/// Supports choosing .xlsx or .csv files, previewing and adjusting category mappings,
/// and atomically saving items and monthly amounts into MoneyMate.
class ImportSpreadsheetDialog extends ConsumerStatefulWidget {
  const ImportSpreadsheetDialog({super.key});

  /// Displays the [ImportSpreadsheetDialog].
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const ImportSpreadsheetDialog(),
    );
  }

  @override
  ConsumerState<ImportSpreadsheetDialog> createState() =>
      _ImportSpreadsheetDialogState();
}

class _ImportSpreadsheetDialogState
    extends ConsumerState<ImportSpreadsheetDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(importWorkflowProvider.notifier).initCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(importWorkflowProvider);
    final notifier = ref.read(importWorkflowProvider.notifier);
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: switch (state.step) {
            ImportStep.idle => _buildIdleView(context, notifier, theme),
            ImportStep.pickingFile ||
            ImportStep.parsing =>
              _buildLoadingView(theme, 'Reading spreadsheet...'),
            ImportStep.reviewing =>
              _buildReviewView(context, state, notifier, theme),
            ImportStep.committing =>
              _buildLoadingView(theme, 'Adding items to your tracker...'),
            ImportStep.completed =>
              _buildCompletedView(context, state, theme),
            ImportStep.error => _buildErrorView(context, state, notifier, theme),
          },
        ),
      ),
    );
  }

  Widget _buildIdleView(
    BuildContext context,
    ImportWorkflowNotifier notifier,
    ThemeData theme,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.upload_file_rounded,
                color: theme.colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Import spreadsheet',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Excel (.xlsx) or CSV format',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Bring your past months of spending and bills straight into MoneyMate without manual re-entry.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildFeatureItem(
                theme,
                Icons.calendar_month_outlined,
                'Multi-month columns',
                'Reads month-by-month amounts, notes, and past history.',
              ),
              const Divider(height: 16),
              _buildFeatureItem(
                theme,
                Icons.auto_awesome_outlined,
                'Smart categorization',
                'Automatically tags income, household bills, and due dates.',
              ),
              const Divider(height: 16),
              _buildFeatureItem(
                theme,
                Icons.preview_outlined,
                'Pre-import review',
                'Check and adjust every category before saving.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              key: const Key('import_dialog_close_button'),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              key: const Key('choose_spreadsheet_button'),
              icon: const Icon(Icons.file_open_outlined, size: 20),
              label: const Text('Choose file'),
              onPressed: () => notifier.pickAndParseFile(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
    ThemeData theme,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingView(ThemeData theme, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewView(
    BuildContext context,
    ImportWorkflowState state,
    ImportWorkflowNotifier notifier,
    ThemeData theme,
  ) {
    final sheet = state.parsedSpreadsheet!.sheets[state.selectedSheetIndex];
    final activeCount = state.mappings.where((m) => !m.isExcluded).length;
    final ambiguousCount = state.mappings.where((m) => m.isAmbiguous && !m.isExcluded).length;

    // Available categories list including defaults
    final categoryOptions = _getCategoryOptions(state.availableCategories);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Review your items',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${state.fileName ?? 'Spreadsheet'} • ${sheet.periodHeaders.length} months found',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                notifier.reset();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        if (ambiguousCount > 0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: theme.colorScheme.tertiary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$ambiguousCount item${ambiguousCount > 1 ? 's need' : ' needs'} category confirmation below.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListView.separated(
              key: const Key('import_review_list'),
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: state.mappings.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, index) {
                final mapping = state.mappings[index];
                final isExcluded = mapping.isExcluded;

                return Opacity(
                  opacity: isExcluded ? 0.45 : 1.0,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Row(
                      children: [
                        Checkbox(
                          value: !isExcluded,
                          onChanged: (_) => notifier.toggleRowExcluded(index),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      mapping.cleanName,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        decoration: isExcluded
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (mapping.dueDay != null) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.secondaryContainer,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Due ${mapping.dueDay}${_getOrdinal(mapping.dueDay!)}',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: theme.colorScheme.onSecondaryContainer,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (mapping.isAmbiguous && !isExcluded)
                                Text(
                                  'Original: "${mapping.originalLabel}"',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.error,
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<AvailableCategory>(
                          key: Key('row_category_dropdown_$index'),
                          value: _findSelectedCategory(
                              mapping, categoryOptions),
                          underline: const SizedBox.shrink(),
                          borderRadius: BorderRadius.circular(8),
                          items: categoryOptions.map((cat) {
                            return DropdownMenuItem<AvailableCategory>(
                              value: cat,
                              child: Text(
                                cat.name,
                                style: theme.textTheme.bodySmall,
                              ),
                            );
                          }).toList(),
                          onChanged: isExcluded
                              ? null
                              : (newCat) {
                                  if (newCat != null) {
                                    notifier.updateRowCategory(index, newCat);
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                '$activeCount of ${state.mappings.length} items selected',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: () => notifier.reset(),
              child: const Text('Back'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              key: const Key('commit_import_button'),
              onPressed: activeCount == 0
                  ? null
                  : () => notifier.commitImport(),
              child: Text('Import $activeCount items'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompletedView(
    BuildContext context,
    ImportWorkflowState state,
    ThemeData theme,
  ) {
    final summary = state.summary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Import complete!',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Successfully added ${summary?.itemsCount ?? 0} items and ${summary?.entriesCount ?? 0} monthly values across ${summary?.periodKeys.length ?? 0} months.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              key: const Key('open_tracker_button'),
              onPressed: () {
                ref.read(trackerLedgerNotifierProvider.notifier).loadLedger();
                ref.read(importWorkflowProvider.notifier).reset();
                Navigator.of(context).pop();
              },
              child: const Text('Open Tracker'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    ImportWorkflowState state,
    ImportWorkflowNotifier notifier,
    ThemeData theme,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.error_outline_rounded,
                size: 32, color: theme.colorScheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Couldn\'t read spreadsheet',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          state.errorMessage ??
              'An unexpected error occurred while reading the file. Please check that it is a valid Excel or CSV budget spreadsheet.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                notifier.reset();
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try another file'),
              onPressed: () => notifier.pickAndParseFile(),
            ),
          ],
        ),
      ],
    );
  }

  List<AvailableCategory> _getCategoryOptions(
      List<AvailableCategory> existing) {
    const defaultOptions = [
      AvailableCategory(id: -1, name: 'Income', categoryType: 'income'),
      AvailableCategory(id: -2, name: 'Household', categoryType: 'expense'),
      AvailableCategory(id: -3, name: 'Personal', categoryType: 'expense'),
      AvailableCategory(id: -4, name: 'Other', categoryType: 'expense'),
      AvailableCategory(id: -5, name: 'Debts', categoryType: 'debt'),
      AvailableCategory(id: -6, name: 'Savings', categoryType: 'savings'),
      AvailableCategory(id: -7, name: 'Investments', categoryType: 'investment'),
    ];

    if (existing.isEmpty) return defaultOptions;

    final existingNames = existing.map((c) => c.name.toLowerCase()).toSet();
    final combined = List<AvailableCategory>.from(existing);
    for (final opt in defaultOptions) {
      if (!existingNames.contains(opt.name.toLowerCase())) {
        combined.add(opt);
      }
    }
    return combined;
  }

  AvailableCategory? _findSelectedCategory(
    ImportRowMapping mapping,
    List<AvailableCategory> options,
  ) {
    for (final cat in options) {
      if (cat.name.toLowerCase() == mapping.targetCategoryName.toLowerCase()) {
        return cat;
      }
    }
    return options.isNotEmpty ? options.first : null;
  }

  String _getOrdinal(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}
