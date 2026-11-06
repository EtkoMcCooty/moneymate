import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/craft_decorations.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../models/analytics_models.dart';

/// Renders category spending and allocation distributions ("Where your money goes")
/// with sleek segmented bars and tabular figures.
class CategoryBreakdownSection extends StatelessWidget {
  final List<CategoryMetricBreakdown> breakdowns;
  final String? activePeriodLabel;
  final String currencySymbol;

  const CategoryBreakdownSection({
    super.key,
    required this.breakdowns,
    this.activePeriodLabel,
    this.currencySymbol = '£',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: CraftDecorations.cardShadowDecoration(context),
      child: Material(
        color: CraftDecorations.surfaceColor(context),
        shape: CraftDecorations.cardShape(context),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Where your money goes',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                  ),
                  if (activePeriodLabel != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: CraftDecorations.pillDecoration(
                        context,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1),
                        borderColor: Colors.transparent,
                      ),
                      child: Text(
                        activePeriodLabel!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              if (breakdowns.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: Text(
                      'No category spending recorded for this period',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                )
              else ...[
                // Stacked Distribution Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 10,
                    child: Row(
                      children: breakdowns.map((b) {
                        return Flexible(
                          flex: (b.percentage * 10).round().clamp(1, 1000),
                          child: Container(
                            color: b.color,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Category Line Items
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: breakdowns.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 18,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : AppTheme.dividerColor.withValues(alpha: 0.8),
                  ),
                  itemBuilder: (context, index) {
                    final item = breakdowns[index];
                    return Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: item.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.categoryName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${item.percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 11,
                              color: item.color,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          CurrencyFormatter.format(
                            item.totalAmount,
                            symbol: currencySymbol,
                          ),
                          style: CraftDecorations.tabularStyle(
                            baseStyle: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
