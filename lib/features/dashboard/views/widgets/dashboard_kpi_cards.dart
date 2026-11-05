import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../models/analytics_models.dart';

/// Renders key financial metrics (Disposable Income, Money In vs Out, Savings Rate, Debt).
class DashboardKpiCards extends StatelessWidget {
  final DashboardAggregateData data;
  final String currencySymbol;

  const DashboardKpiCards({
    super.key,
    required this.data,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final activeSummary = data.selectedPeriodSummary;
    final disposableIncome =
        activeSummary?.disposableIncome ?? data.averageDisposableIncome;
    final income = activeSummary?.totalIncome ?? data.averageMonthlyIncome;
    final outflows = activeSummary?.totalOutflows ?? data.averageMonthlyOutflows;
    final savingsRate = activeSummary?.savingsRate ?? 0.0;
    final periodLabel = activeSummary?.displayLabel ?? 'Average';

    final isPositive = disposableIncome >= 0;
    final accentColor = isPositive ? AppTheme.incomeColor : AppTheme.expenseColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Featured Disposable Income Card
        Card(
          elevation: 0,
          color: accentColor.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: accentColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Disposable Income',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        periodLabel,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  CurrencyFormatter.format(
                    disposableIncome,
                    symbol: currencySymbol,
                  ),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPositive
                    ? 'Leftover money available for you to spend or save'
                    : 'Spending exceeded income this period',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 2. Metrics Grid (Money In vs Out & Savings Rate / Debt)
        Row(
          children: [
            // Money In vs Out Card
            Expanded(
              child: Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Money In vs Out',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.arrow_downward, size: 14, color: AppTheme.incomeColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              CurrencyFormatter.format(income, symbol: currencySymbol),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.incomeColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.arrow_upward, size: 14, color: AppTheme.expenseColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              CurrencyFormatter.format(outflows, symbol: currencySymbol),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.expenseColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Savings Rate or Debt Payoff Card
            Expanded(
              child: Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.totalDebtRemaining > 0 ? 'Debt Left' : 'Savings Rate',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      if (data.totalDebtRemaining > 0) ...[
                        Text(
                          CurrencyFormatter.format(
                            data.totalDebtRemaining,
                            symbol: currencySymbol,
                          ),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.debtColor,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${CurrencyFormatter.format(data.totalDebtPaidInTimeframe, symbol: currencySymbol)} paid',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ] else ...[
                        Text(
                          '${savingsRate.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.savingsColor,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Saved of total income',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
