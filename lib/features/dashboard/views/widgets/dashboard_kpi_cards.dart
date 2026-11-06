import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/craft_decorations.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../models/analytics_models.dart';

/// Renders key financial metrics (Disposable Income, Money In vs Out, Savings Rate, Debt)
/// with bespoke surface lighting, visual ratio gauges, and tabular typography.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isPositive ? AppTheme.incomeColor : AppTheme.expenseColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Featured Disposable Income Hero Card
        Container(
          decoration: CraftDecorations.heroCardDecoration(
            context,
            accentColor: accentColor,
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Disposable Income',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: isDark ? 0.2 : 0.12),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          periodLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyFormatter.format(
                      disposableIncome,
                      symbol: currencySymbol,
                    ),
                    style: CraftDecorations.tabularStyle(
                      baseStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                            color: accentColor,
                          ) ??
                          TextStyle(color: accentColor),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPositive
                        ? 'Leftover money available for you to spend or save'
                        : 'Spending exceeded income this period',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 2. Metrics Grid (Money In vs Out & Savings Rate / Debt)
        Row(
          children: [
            // Money In vs Out Card
            Expanded(
              child: Container(
                decoration: CraftDecorations.cardShadowDecoration(context),
                child: Material(
                  color: CraftDecorations.surfaceColor(context),
                  shape: CraftDecorations.cardShape(context),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Money In vs Out',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: AppTheme.incomeColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.arrow_downward_rounded,
                                  size: 12, color: AppTheme.incomeColor),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                CurrencyFormatter.format(income, symbol: currencySymbol),
                                style: CraftDecorations.tabularStyle(
                                  baseStyle: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: AppTheme.incomeColor,
                                  ),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: AppTheme.expenseColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.arrow_upward_rounded,
                                  size: 12, color: AppTheme.expenseColor),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                CurrencyFormatter.format(outflows, symbol: currencySymbol),
                                style: CraftDecorations.tabularStyle(
                                  baseStyle: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: AppTheme.expenseColor,
                                  ),
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
            ),

            const SizedBox(width: 12),

            // Savings Rate or Debt Payoff Card
            Expanded(
              child: Container(
                decoration: CraftDecorations.cardShadowDecoration(context),
                child: Material(
                  color: CraftDecorations.surfaceColor(context),
                  shape: CraftDecorations.cardShape(context),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.totalDebtRemaining > 0 ? 'Debt Left' : 'Savings Rate',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                        ),
                        const SizedBox(height: 8),
                        if (data.totalDebtRemaining > 0) ...[
                          Text(
                            CurrencyFormatter.format(
                              data.totalDebtRemaining,
                              symbol: currencySymbol,
                            ),
                            style: CraftDecorations.tabularStyle(
                              baseStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.debtColor,
                                  ) ??
                                  const TextStyle(color: AppTheme.debtColor),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${CurrencyFormatter.format(data.totalDebtPaidInTimeframe, symbol: currencySymbol)} paid',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ] else ...[
                          Text(
                            '${savingsRate.toStringAsFixed(1)}%',
                            style: CraftDecorations.tabularStyle(
                              baseStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                    color: AppTheme.savingsColor,
                                  ) ??
                                  const TextStyle(color: AppTheme.savingsColor),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Saved of total income',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ],
                    ),
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
