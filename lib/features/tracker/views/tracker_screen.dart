import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/craft_decorations.dart';
import '../../../core/theme/tactile_press.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/pay_cycle_service.dart';
import '../models/tracker_ledger_models.dart';
import '../state/tracker_ledger_notifier.dart';
import '../../importer/views/import_spreadsheet_dialog.dart';
import 'entry_editor_dialog.dart';
import 'item_form_dialog.dart';

/// Screen displaying the monthly ledger and finance tracker grid with
/// collapsible category sections, in-line entry amount/note editing, and disposable income calculations.
class TrackerScreen extends ConsumerWidget {
  const TrackerScreen({super.key});

  void _shiftPeriod(WidgetRef ref, String currentKey, int delta) {
    final adjacent = PayCycleService.generateAdjacentPeriodKeys(
      currentKey,
      countBefore: delta < 0 ? 1 : 0,
      countAfter: delta > 0 ? 1 : 0,
    );
    final targetKey = delta < 0 ? adjacent.first : adjacent.last;
    ref.read(trackerLedgerNotifierProvider.notifier).selectPeriod(targetKey);
  }

  Future<bool?> _confirmDeleteItem(BuildContext context, String itemName) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item?'),
        content: Text(
          'Are you sure you want to remove "$itemName"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('confirm_delete_button'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openItemDialog(
    BuildContext context,
    WidgetRef ref,
    int categoryId, [
    FinanceItemWithEntry? item,
  ]) {
    final state = ref.read(trackerLedgerNotifierProvider);
    final categories = state.sections.map((s) => s.category).toList();
    final notifier = ref.read(trackerLedgerNotifierProvider.notifier);

    showDialog(
      context: context,
      builder: (ctx) => ItemFormDialog(
        categories: categories,
        initialCategoryId: categoryId,
        currencySymbol: state.currencySymbol,
        itemToEdit: item,
        onSave: ({
          required int categoryId,
          required String name,
          double? amount,
          int? dueDay,
          double? totalPrincipal,
          double? interestRate,
        }) async {
          if (item == null) {
            await notifier.addItem(
              categoryId: categoryId,
              name: name,
              amount: amount,
              dueDay: dueDay,
              totalPrincipal: totalPrincipal,
              interestRate: interestRate,
            );
          } else {
            await notifier.updateItem(
              itemId: item.item.id,
              categoryId: categoryId,
              name: name,
              dueDay: dueDay,
              totalPrincipal: totalPrincipal,
              interestRate: interestRate,
            );
            if (amount != null) {
              await notifier.updateEntry(
                itemId: item.item.id,
                amount: amount,
              );
            }
          }
        },
        onDelete: (itemId) async {
          await notifier.deleteItem(itemId);
        },
        onArchive: (itemId) async {
          await notifier.archiveItem(itemId);
        },
      ),
    );
  }

  void _openEntryDialog(
    BuildContext context,
    WidgetRef ref,
    FinanceItemWithEntry itemWithEntry,
    String categoryType,
  ) {
    final state = ref.read(trackerLedgerNotifierProvider);
    final notifier = ref.read(trackerLedgerNotifierProvider.notifier);

    showDialog(
      context: context,
      builder: (ctx) => EntryEditorDialog(
        itemName: itemWithEntry.item.name,
        currencySymbol: state.currencySymbol,
        initialAmount: itemWithEntry.amount,
        initialExtraPayment: itemWithEntry.extraPayment,
        initialNote: itemWithEntry.note,
        isDebt: categoryType.toLowerCase() == 'debt',
        onSave: ({
          required double amount,
          double? extraPayment,
          String? note,
        }) async {
          await notifier.updateEntry(
            itemId: itemWithEntry.item.id,
            amount: amount,
            extraPayment: extraPayment,
            note: note,
          );
        },
      ),
    );
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
    final ledgerState = ref.watch(trackerLedgerNotifierProvider);

    return Scaffold(
      key: const Key('tracker_screen_content'),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Monthly Tracker'),
            if (ledgerState.selectedPeriodKey.isNotEmpty)
              Text(
                '${PayCycleService.formatPeriodTitle(ledgerState.selectedPeriodKey)} • ${PayCycleService.formatPeriodDateSpan(ledgerState.selectedPeriodKey, ledgerState.cycleStartDay)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.normal,
                    ),
              ),
          ],
        ),
        actions: [
          IconButton(
            key: const Key('tracker_import_spreadsheet_button'),
            icon: const Icon(Icons.upload_file_outlined),
            tooltip: 'Import spreadsheet',
            onPressed: () => ImportSpreadsheetDialog.show(context),
          ),
        ],
      ),
      body: ledgerState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(trackerLedgerNotifierProvider.notifier)
                    .loadLedger(periodKey: ledgerState.selectedPeriodKey);
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                children: [
                  if (ledgerState.errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: Theme.of(context).colorScheme.onErrorContainer),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ledgerState.errorMessage!,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.onErrorContainer),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Period Navigation Bar
                  _buildPeriodHeader(context, ref, ledgerState),
                  const SizedBox(height: 8),

                  // Disposable Income & Overview Hero Card
                  _buildSummaryCard(context, ledgerState),
                  const SizedBox(height: 10),

                  // Collapsible Category Sections Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Budget & Spending Sections',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: CraftDecorations.pillDecoration(
                            context,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.1),
                            borderColor: Colors.transparent,
                          ),
                          child: Text(
                            '${ledgerState.sections.length} GROUPS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  ...ledgerState.sections.map((section) {
                    return _buildCategorySectionCard(
                        context, ref, section, ledgerState.currencySymbol);
                  }),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildPeriodHeader(
      BuildContext context, WidgetRef ref, TrackerLedgerState state) {
    final periodTitle =
        PayCycleService.formatPeriodTitle(state.selectedPeriodKey);
    final periodSpan = PayCycleService.formatPeriodDateSpan(
        state.selectedPeriodKey, state.cycleStartDay);

    return Container(
      decoration: CraftDecorations.cardShadowDecoration(context, elevated: false),
      child: Material(
        color: CraftDecorations.surfaceColor(context),
        shape: CraftDecorations.cardShape(
          context,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TactilePress(
                tooltip: 'Previous month',
                onTap: () => _shiftPeriod(ref, state.selectedPeriodKey, -1),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: CraftDecorations.pillDecoration(context),
                  child: const Icon(Icons.chevron_left_rounded, size: 20),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    periodTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    periodSpan,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
              TactilePress(
                tooltip: 'Next month',
                onTap: () => _shiftPeriod(ref, state.selectedPeriodKey, 1),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: CraftDecorations.pillDecoration(context),
                  child: const Icon(Icons.chevron_right_rounded, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, TrackerLedgerState state) {
    final summary = state.summary;
    final symbol = state.currencySymbol;
    final isPositive = summary.disposableIncome >= 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor =
        isPositive ? AppTheme.incomeColor : Theme.of(context).colorScheme.error;

    final disposableIncomeFormatted = CurrencyFormatter.format(
      summary.disposableIncome,
      symbol: symbol,
    );

    return Container(
      decoration: CraftDecorations.heroCardDecoration(
        context,
        accentColor: accentColor,
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Micro-label and Status Beacon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Disposable Income',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: isDark ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isPositive ? 'ON TRACK' : 'OVER BUDGET',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Main Hero Disposable Amount & Verification Icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      disposableIncomeFormatted,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: isPositive
                                ? Colors.green.shade700
                                : Theme.of(context).colorScheme.error,
                          ),
                    ),
                  ),
                  Icon(
                    isPositive ? Icons.check_circle_outline : Icons.error_outline,
                    color: isPositive
                        ? Colors.green.shade700
                        : Theme.of(context).colorScheme.error,
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Leftover after bills, debts & savings',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 16),

              // Split Distribution / Allocation Progress Bar
              if (summary.totalIncome > 0) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 8,
                    child: Row(
                      children: [
                        if (summary.totalExpenses > 0)
                          Flexible(
                            flex: (summary.totalExpenses * 100 / summary.totalIncome)
                                .round()
                                .clamp(1, 1000),
                            child: Container(color: AppTheme.expenseColor),
                          ),
                        if (summary.totalDebtPayments > 0)
                          Flexible(
                            flex: (summary.totalDebtPayments * 100 / summary.totalIncome)
                                .round()
                                .clamp(1, 1000),
                            child: Container(color: AppTheme.debtColor),
                          ),
                        if (summary.totalSavingsAndInvestments > 0)
                          Flexible(
                            flex: (summary.totalSavingsAndInvestments * 100 / summary.totalIncome)
                                .round()
                                .clamp(1, 1000),
                            child: Container(color: AppTheme.savingsColor),
                          ),
                        if (summary.disposableIncome > 0)
                          Flexible(
                            flex: (summary.disposableIncome * 100 / summary.totalIncome)
                                .round()
                                .clamp(1, 1000),
                            child: Container(color: AppTheme.incomeColor),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const Divider(height: 1),
              const SizedBox(height: 16),

              // 4 Financial Pillars (Income, Bills, Debts, Savings)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMetricCol(
                    context,
                    label: 'Income',
                    amount: CurrencyFormatter.format(summary.totalIncome,
                        symbol: symbol),
                    color: Colors.green.shade700,
                    icon: Icons.arrow_downward_rounded,
                  ),
                  _buildMetricCol(
                    context,
                    label: 'Bills',
                    amount: CurrencyFormatter.format(summary.totalExpenses,
                        symbol: symbol),
                    color: Theme.of(context).colorScheme.error,
                    icon: Icons.arrow_upward_rounded,
                  ),
                  _buildMetricCol(
                    context,
                    label: 'Debts',
                    amount: CurrencyFormatter.format(summary.totalDebtPayments,
                        symbol: symbol),
                    color: Colors.deepOrange.shade700,
                    icon: Icons.credit_card_outlined,
                  ),
                  _buildMetricCol(
                    context,
                    label: 'Savings',
                    amount: CurrencyFormatter.format(
                        summary.totalSavingsAndInvestments,
                        symbol: symbol),
                    color: Colors.blue.shade700,
                    icon: Icons.savings_outlined,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCol(
    BuildContext context, {
    required String label,
    required String amount,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 10, color: color),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: CraftDecorations.tabularStyle(
            baseStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ) ??
                TextStyle(color: color),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySectionCard(
    BuildContext context,
    WidgetRef ref,
    CategorySection section,
    String currencySymbol,
  ) {
    final subtotalFormatted = CurrencyFormatter.format(
      section.totalAmount,
      symbol: currencySymbol,
    );
    final actionColor =
        _getCategoryActionColor(context, section.category.categoryType);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      decoration: CraftDecorations.cardShadowDecoration(context),
      child: Material(
        color: CraftDecorations.surfaceColor(context),
        shape: CraftDecorations.cardShape(context),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: !section.isCollapsed,
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            childrenPadding: EdgeInsets.zero,
            onExpansionChanged: (_) {
              ref
                  .read(trackerLedgerNotifierProvider.notifier)
                  .toggleCategoryCollapsed(section.category.id);
            },
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: actionColor.withValues(alpha: isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(section.category.categoryType),
                color: actionColor,
                size: 20,
              ),
            ),
            title: Row(
              children: [
                Flexible(
                  child: Text(
                    section.category.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _formatCategoryTypeLabel(section.category.categoryType),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            trailing: Text(
              subtotalFormatted,
              style: CraftDecorations.tabularStyle(
                baseStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ) ??
                    const TextStyle(),
              ),
            ),
            children: [
              if (section.items.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'No items added yet',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                )
              else
                ...section.items.map((itemWithEntry) {
                  final amountStr = CurrencyFormatter.format(
                    itemWithEntry.amount,
                    symbol: currencySymbol,
                  );
                  return Dismissible(
                    key: Key('dismissible_item_${itemWithEntry.item.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      color: Theme.of(context).colorScheme.error,
                      child: const Icon(Icons.delete_outline, color: Colors.white),
                    ),
                    confirmDismiss: (_) =>
                        _confirmDeleteItem(context, itemWithEntry.item.name),
                    onDismissed: (_) {
                      ref
                          .read(trackerLedgerNotifierProvider.notifier)
                          .deleteItem(itemWithEntry.item.id);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.04),
                            width: 1,
                          ),
                        ),
                      ),
                      child: ListTile(
                        dense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
                        onTap: () => _openItemDialog(
                            context, ref, section.category.id, itemWithEntry),
                        onLongPress: () async {
                          final confirmed = await _confirmDeleteItem(
                              context, itemWithEntry.item.name);
                          if (confirmed == true) {
                            await ref
                                .read(trackerLedgerNotifierProvider.notifier)
                                .deleteItem(itemWithEntry.item.id);
                          }
                        },
                        title: Text(
                          itemWithEntry.item.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: _buildItemSubtitle(
                            context, itemWithEntry, currencySymbol),
                        trailing: Tooltip(
                          message: 'Edit amount and note',
                          child: TactilePress(
                            key: Key('edit_entry_${itemWithEntry.item.id}'),
                            onTap: () => _openEntryDialog(
                              context,
                              ref,
                              itemWithEntry,
                              section.category.categoryType,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 6.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHigh
                                    .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.black.withValues(alpha: 0.06),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    amountStr,
                                    style: CraftDecorations.tabularStyle(
                                      baseStyle: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Icon(
                                    Icons.edit_note,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    key: Key('add_item_button_${section.category.name}'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: actionColor,
                      side: BorderSide(color: actionColor.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text('Add ${section.category.name} Item'),
                    onPressed: () =>
                      _openItemDialog(context, ref, section.category.id),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildItemSubtitle(
    BuildContext context,
    FinanceItemWithEntry itemWithEntry,
    String currencySymbol,
  ) {
    final parts = <String>[];
    if (itemWithEntry.item.dueDay != null) {
      parts.add(
          'Due ${PayCycleService.formatOrdinal(itemWithEntry.item.dueDay!)} of month');
    }
    if (itemWithEntry.debtMetadata != null) {
      final remainingFormatted = CurrencyFormatter.format(
        itemWithEntry.debtMetadata!.totalPrincipal,
        symbol: currencySymbol,
      );
      parts.add('Remaining balance: $remainingFormatted');
    }
    if (itemWithEntry.extraPayment > 0) {
      final extraFormatted = CurrencyFormatter.format(
        itemWithEntry.extraPayment,
        symbol: currencySymbol,
      );
      parts.add('Extra paid: $extraFormatted');
    }
    if (itemWithEntry.note != null && itemWithEntry.note!.isNotEmpty) {
      parts.add(itemWithEntry.note!);
    }

    if (parts.isEmpty) return null;
    return Text(
      parts.join(' • '),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }

  IconData _getCategoryIcon(String type) {
    switch (type.toLowerCase()) {
      case 'income':
        return Icons.arrow_downward_rounded;
      case 'expense':
        return Icons.receipt_long_outlined;
      case 'debt':
        return Icons.credit_card_outlined;
      case 'savings':
        return Icons.savings_outlined;
      case 'investment':
        return Icons.trending_up_outlined;
      default:
        return Icons.folder_outlined;
    }
  }

  Color _getCategoryActionColor(BuildContext context, String type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (type.toLowerCase()) {
      case 'income':
        return isDark ? const Color(0xFF4ADE80) : AppTheme.incomeColor;
      case 'expense':
      case 'debt':
        return isDark ? const Color(0xFFF87171) : AppTheme.expenseColor;
      case 'savings':
      case 'investment':
        return isDark ? const Color(0xFF60A5FA) : AppTheme.savingsColor;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}
