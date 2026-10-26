import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/pay_cycle_service.dart';
import '../models/tracker_ledger_models.dart';
import '../state/tracker_ledger_notifier.dart';

/// Screen displaying the monthly ledger and finance tracker grid with
/// collapsible category sections and disposable income calculations.
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
        title: const Text('Monthly Tracker'),
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
                  // Period Navigation Bar
                  _buildPeriodHeader(context, ref, ledgerState),
                  const SizedBox(height: 12),

                  // Disposable Income & Overview Card
                  _buildSummaryCard(context, ledgerState),
                  const SizedBox(height: 16),

                  // Collapsible Category Sections
                  Text(
                    'Budget & Spending Sections',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 8),

                  ...ledgerState.sections.map((section) {
                    return _buildCategorySectionCard(
                        context, ref, section, ledgerState.currencySymbol);
                  }),

                  const SizedBox(height: 24),
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

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Previous month',
              onPressed: () => _shiftPeriod(ref, state.selectedPeriodKey, -1),
            ),
            Column(
              children: [
                Text(
                  periodTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  periodSpan,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Next month',
              onPressed: () => _shiftPeriod(ref, state.selectedPeriodKey, 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, TrackerLedgerState state) {
    final summary = state.summary;
    final symbol = state.currencySymbol;
    final isPositive = summary.disposableIncome >= 0;

    final disposableIncomeFormatted = CurrencyFormatter.format(
      summary.disposableIncome,
      symbol: symbol,
    );

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Disposable Income',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  disposableIncomeFormatted,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isPositive
                            ? Colors.green.shade700
                            : Theme.of(context).colorScheme.error,
                      ),
                ),
                const Spacer(),
                Icon(
                  isPositive ? Icons.check_circle_outline : Icons.error_outline,
                  color: isPositive
                      ? Colors.green.shade700
                      : Theme.of(context).colorScheme.error,
                ),
              ],
            ),
            Text(
              'Leftover after bills, debts & savings',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetricCol(
                  context,
                  label: 'Income',
                  amount: CurrencyFormatter.format(summary.totalIncome,
                      symbol: symbol),
                  color: Colors.green.shade700,
                ),
                _buildMetricCol(
                  context,
                  label: 'Bills',
                  amount: CurrencyFormatter.format(summary.totalExpenses,
                      symbol: symbol),
                  color: Theme.of(context).colorScheme.error,
                ),
                _buildMetricCol(
                  context,
                  label: 'Debts',
                  amount: CurrencyFormatter.format(summary.totalDebtPayments,
                      symbol: symbol),
                  color: Colors.deepOrange.shade700,
                ),
                _buildMetricCol(
                  context,
                  label: 'Savings',
                  amount: CurrencyFormatter.format(
                      summary.totalSavingsAndInvestments,
                      symbol: symbol),
                  color: Colors.blue.shade700,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCol(
    BuildContext context, {
    required String label,
    required String amount,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          amount,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
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

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: !section.isCollapsed,
        onExpansionChanged: (_) {
          ref
              .read(trackerLedgerNotifierProvider.notifier)
              .toggleCategoryCollapsed(section.category.id);
        },
        leading: Icon(
          _getCategoryIcon(section.category.categoryType),
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Row(
          children: [
            Text(
              section.category.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _formatCategoryTypeLabel(section.category.categoryType),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ],
        ),
        trailing: Text(
          subtotalFormatted,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        children: [
          if (section.items.isEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              return ListTile(
                dense: true,
                title: Text(itemWithEntry.item.name),
                subtitle: itemWithEntry.item.dueDay != null
                    ? Text('Due ${itemWithEntry.item.dueDay}th of month')
                    : (itemWithEntry.note != null
                        ? Text(itemWithEntry.note!)
                        : null),
                trailing: Text(
                  amountStr,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              );
            }),
        ],
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
}
