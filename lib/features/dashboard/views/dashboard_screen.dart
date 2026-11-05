import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/analytics_models.dart';
import '../state/dashboard_notifier.dart';
import 'widgets/category_breakdown_section.dart';
import 'widgets/dashboard_kpi_cards.dart';
import 'widgets/dashboard_trend_chart.dart';

/// Screen displaying financial analytics, trend charts, and category breakdown.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(dashboardNotifierProvider.notifier).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardNotifierProvider);

    return Scaffold(
      key: const Key('dashboard_screen_content'),
      appBar: AppBar(
        title: const Text('Insights'),
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.tonal(
                      onPressed: () {
                        ref.read(dashboardNotifierProvider.notifier).loadDashboard();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!state.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.insights_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tracking data yet',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add items in your Tracker or import a spreadsheet to see your financial insights.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = state.data!;

          return RefreshIndicator(
            onRefresh: () => ref.read(dashboardNotifierProvider.notifier).loadDashboard(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                // Timeframe Selector Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: AnalyticsTimeframe.values.map((timeframe) {
                      final isSelected = state.selectedTimeframe == timeframe;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(timeframe.label),
                          selected: isSelected,
                          onSelected: (_) {
                            ref
                                .read(dashboardNotifierProvider.notifier)
                                .setTimeframe(timeframe);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // KPI Overview Cards
                DashboardKpiCards(
                  data: data,
                  currencySymbol: state.currencySymbol,
                ),

                const SizedBox(height: 16),

                // Trend Lines Chart
                DashboardTrendChart(
                  summaries: data.periodSummaries,
                  selectedPeriodKey: state.selectedPeriodKey,
                  currencySymbol: state.currencySymbol,
                  onPeriodSelected: (periodKey) {
                    ref
                        .read(dashboardNotifierProvider.notifier)
                        .selectPeriod(periodKey);
                  },
                ),

                const SizedBox(height: 16),

                // Category Spending Allocations ("Where your money goes")
                CategoryBreakdownSection(
                  breakdowns: data.categoryBreakdowns,
                  activePeriodLabel: data.selectedPeriodSummary?.displayLabel,
                  currencySymbol: state.currencySymbol,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
