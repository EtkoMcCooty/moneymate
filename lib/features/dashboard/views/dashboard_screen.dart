import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/craft_decorations.dart';
import '../../../core/utils/pay_cycle_service.dart';
import '../../importer/views/import_spreadsheet_dialog.dart';
import '../../shell/state/navigation_provider.dart';
import '../../tracker/views/widgets/month_picker_sheet.dart';
import '../models/analytics_models.dart';
import '../services/analytics_engine_service.dart';
import '../state/dashboard_notifier.dart';
import 'widgets/category_breakdown_section.dart';
import 'widgets/dashboard_kpi_cards.dart';
import 'widgets/dashboard_trend_chart.dart';

/// Screen displaying financial analytics, trend charts, and category breakdown
/// with modern surface layering and responsive visual hierarchy.
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

  void _openMonthPicker(BuildContext context, DashboardState state) {
    final summaries = state.data?.periodSummaries ?? [];
    final fallbackKey = summaries.isNotEmpty
        ? summaries.last.periodKey
        : PayCycleService.getPeriodKey(DateTime.now(), state.cycleStartDay);

    MonthPickerSheet.show(
      context,
      selectedPeriodKey:
          state.filteredMonthKey ?? state.selectedPeriodKey ?? fallbackKey,
      cycleStartDay: state.cycleStartDay,
      recordedPeriodKeys: state.recordedPeriodKeys,
      onPeriodSelected: (periodKey) {
        ref.read(dashboardNotifierProvider.notifier).filterByMonth(periodKey);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardNotifierProvider);

    return Scaffold(
      key: const Key('dashboard_screen_content'),
      appBar: AppBar(
        title: const Text('Insights'),
        actions: [
          if (!state.isLoading && state.hasData)
            IconButton(
              key: const Key('dashboard_calendar_button'),
              icon: const Icon(Icons.calendar_month_rounded),
              tooltip: 'Filter by month',
              onPressed: () => _openMonthPicker(context, state),
            ),
        ],
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
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 40,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
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
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.insights_rounded,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No tracking data yet',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add items in your Tracker or import a spreadsheet to see your financial insights.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        FilledButton.icon(
                          key: const Key('dashboard_empty_go_tracker_button'),
                          onPressed: () {
                            ref.read(navigationIndexProvider.notifier).state =
                                0;
                          },
                          icon: const Icon(Icons.table_chart_rounded, size: 18),
                          label: const Text('Go to Tracker'),
                        ),
                        OutlinedButton.icon(
                          key: const Key('dashboard_empty_import_button'),
                          onPressed: () =>
                              ImportSpreadsheetDialog.show(context),
                          icon: const Icon(Icons.upload_file_outlined, size: 18),
                          label: const Text('Import spreadsheet'),
                        ),
                      ],
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
                // Timeframe & Individual Month Selector Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...AnalyticsTimeframe.values.map((timeframe) {
                        final isSelected = !state.isMonthFiltered &&
                            state.selectedTimeframe == timeframe;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            showCheckmark: false,
                            label: Text(timeframe.label),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  isSelected ? FontWeight.w800 : FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                              side: BorderSide(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : CraftDecorations.borderSide(context)
                                        .color,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (_) {
                              ref
                                  .read(dashboardNotifierProvider.notifier)
                                  .setTimeframe(timeframe);
                            },
                          ),
                        );
                      }),
                      ChoiceChip(
                        key: const Key('dashboard_month_filter_chip'),
                        showCheckmark: false,
                        avatar: Icon(
                          Icons.calendar_month_rounded,
                          size: 16,
                          color: state.isMonthFiltered
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.primary,
                        ),
                        label: Text(
                          state.isMonthFiltered &&
                                  state.filteredMonthKey != null
                              ? AnalyticsEngineService.formatPeriodLabel(
                                  state.filteredMonthKey!,
                                )
                              : 'Pick Month',
                        ),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: state.isMonthFiltered
                              ? FontWeight.w800
                              : FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                          side: BorderSide(
                            color: state.isMonthFiltered
                                ? Theme.of(context).colorScheme.primary
                                : CraftDecorations.borderSide(context).color,
                          ),
                        ),
                        selected: state.isMonthFiltered,
                        onSelected: (_) => _openMonthPicker(context, state),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                if (state.isMonthFiltered && state.filteredMonthKey != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      key: const Key('dashboard_active_filter_pill'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Viewing ${PayCycleService.formatPeriodTitle(state.filteredMonthKey!)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          IconButton(
                            key: const Key('dashboard_clear_filter_button'),
                            icon: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            tooltip: 'Clear month filter',
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              ref
                                  .read(dashboardNotifierProvider.notifier)
                                  .clearMonthFilter();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                // KPI Overview Cards
                DashboardKpiCards(
                  data: data,
                  currencySymbol: state.currencySymbol,
                  isMonthFiltered: state.isMonthFiltered,
                ),

                const SizedBox(height: 14),

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

                const SizedBox(height: 14),

                // Category Spending Allocations ("Where your money goes")
                CategoryBreakdownSection(
                  breakdowns: data.categoryBreakdowns,
                  activePeriodLabel:
                      data.selectedPeriodSummary?.displayLabel ??
                          state.selectedTimeframe.label,
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
