import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/craft_decorations.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../models/analytics_models.dart';

/// Interactive multi-line trend chart showing Income, Outflows, and Disposable Income
/// with artisanal gradient fills, sleek tooltips, and tactile touches.
class DashboardTrendChart extends StatelessWidget {
  final List<PeriodMetricSummary> summaries;
  final String? selectedPeriodKey;
  final String currencySymbol;
  final ValueChanged<String>? onPeriodSelected;

  const DashboardTrendChart({
    super.key,
    required this.summaries,
    this.selectedPeriodKey,
    this.currencySymbol = '£',
    this.onPeriodSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (summaries.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final incomeSpots = <FlSpot>[];
    final outflowSpots = <FlSpot>[];
    final disposableSpots = <FlSpot>[];

    double minY = 0.0;
    double maxY = 100.0;

    for (int i = 0; i < summaries.length; i++) {
      final s = summaries[i];
      final x = i.toDouble();

      incomeSpots.add(FlSpot(x, s.totalIncome));
      outflowSpots.add(FlSpot(x, s.totalOutflows));
      disposableSpots.add(FlSpot(x, s.disposableIncome));

      minY = min(minY, min(s.disposableIncome, min(s.totalIncome, s.totalOutflows)));
      maxY = max(maxY, max(s.disposableIncome, max(s.totalIncome, s.totalOutflows)));
    }

    // Add 15% vertical headroom
    final verticalRange = (maxY - minY).abs();
    final paddedMinY = (minY - (verticalRange * 0.1)).floorToDouble();
    final paddedMaxY = (maxY + (verticalRange * 0.15)).ceilToDouble();

    return Container(
      key: const Key('dashboard_trend_chart'),
      decoration: CraftDecorations.cardShadowDecoration(context),
      child: Material(
        color: CraftDecorations.surfaceColor(context),
        shape: CraftDecorations.cardShape(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Chart Header & Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cash Flow Trends',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                  ),
                  const Wrap(
                    spacing: 8,
                    children: [
                      _LegendPill(color: AppTheme.incomeColor, label: 'Income'),
                      _LegendPill(color: AppTheme.expenseColor, label: 'Outflows'),
                      _LegendPill(color: AppTheme.primaryColor, label: 'Disposable'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Line Chart
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    minY: paddedMinY,
                    maxY: paddedMaxY,
                    minX: 0,
                    maxX: max(0, summaries.length - 1).toDouble(),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: max(1.0, (paddedMaxY - paddedMinY) / 4),
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : AppTheme.dividerColor.withValues(alpha: 0.8),
                        strokeWidth: 1,
                        dashArray: const [4, 4],
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= summaries.length) {
                              return const SizedBox.shrink();
                            }
                            final summary = summaries[index];
                            final isSelected = summary.periodKey == selectedPeriodKey;

                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                summary.displayLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight:
                                      isSelected ? FontWeight.w800 : FontWeight.w500,
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final index = spot.x.toInt();
                            if (index < 0 || index >= summaries.length) return null;

                            final summary = summaries[index];
                            final label = switch (spot.barIndex) {
                              0 => 'Income',
                              1 => 'Outflows',
                              _ => 'Disposable',
                            };

                            final color = switch (spot.barIndex) {
                              0 => AppTheme.incomeColor,
                              1 => AppTheme.expenseColor,
                              _ => AppTheme.primaryColor,
                            };

                            return LineTooltipItem(
                              '${summary.displayLabel}\n$label: ${CurrencyFormatter.format(spot.y, symbol: currencySymbol)}',
                              TextStyle(
                                color: color,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            );
                          }).toList();
                        },
                      ),
                      touchCallback: (event, response) {
                        if (event is FlTapUpEvent &&
                            response != null &&
                            response.lineBarSpots != null &&
                            response.lineBarSpots!.isNotEmpty) {
                          final spot = response.lineBarSpots!.first;
                          final index = spot.x.toInt();
                          if (index >= 0 && index < summaries.length) {
                            onPeriodSelected?.call(summaries[index].periodKey);
                          }
                        }
                      },
                    ),
                    lineBarsData: [
                      // Line 0: Income (Green)
                      LineChartBarData(
                        spots: incomeSpots,
                        isCurved: true,
                        curveSmoothness: 0.35,
                        color: AppTheme.incomeColor,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                      ),
                      // Line 1: Outflows (Red / Coral)
                      LineChartBarData(
                        spots: outflowSpots,
                        isCurved: true,
                        curveSmoothness: 0.35,
                        color: AppTheme.expenseColor,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                      ),
                      // Line 2: Disposable Income (Teal / Primary)
                      LineChartBarData(
                        spots: disposableSpots,
                        isCurved: true,
                        curveSmoothness: 0.35,
                        color: AppTheme.primaryColor,
                        barWidth: 3.5,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendPill extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendPill({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
