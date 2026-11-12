import 'dart:math';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/craft_decorations.dart';
import '../../../../core/utils/pay_cycle_service.dart';

/// Modal bottom sheet allowing users to jump across years and months
/// with visual indicators for recorded pay periods and a quick-return shortcut.
class MonthPickerSheet extends StatefulWidget {
  const MonthPickerSheet({
    super.key,
    required this.selectedPeriodKey,
    required this.cycleStartDay,
    required this.recordedPeriodKeys,
    required this.onPeriodSelected,
  });

  final String selectedPeriodKey;
  final int cycleStartDay;
  final Set<String> recordedPeriodKeys;
  final ValueChanged<String> onPeriodSelected;

  /// Displays the [MonthPickerSheet] in a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required String selectedPeriodKey,
    required int cycleStartDay,
    required Set<String> recordedPeriodKeys,
    required ValueChanged<String> onPeriodSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MonthPickerSheet(
        selectedPeriodKey: selectedPeriodKey,
        cycleStartDay: cycleStartDay,
        recordedPeriodKeys: recordedPeriodKeys,
        onPeriodSelected: onPeriodSelected,
      ),
    );
  }

  @override
  State<MonthPickerSheet> createState() => _MonthPickerSheetState();
}

class _MonthPickerSheetState extends State<MonthPickerSheet> {
  late int _viewedYear;

  @override
  void initState() {
    super.initState();
    final parts = widget.selectedPeriodKey.split('-');
    _viewedYear = int.tryParse(parts.first) ?? DateTime.now().year;
  }

  List<int> _calculateAvailableYears() {
    final recordedYears = widget.recordedPeriodKeys
        .map((k) => int.tryParse(k.split('-').first))
        .whereType<int>()
        .toSet();

    final currentYear = DateTime.now().year;
    final allYears = {...recordedYears, currentYear, _viewedYear};

    final minYear = min(allYears.reduce(min), currentYear - 1);
    final maxYear = max(allYears.reduce(max), currentYear + 1);

    return List.generate(maxYear - minYear + 1, (i) => minYear + i);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final years = _calculateAvailableYears();
    final activeCurrentPeriodKey =
        PayCycleService.getPeriodKey(DateTime.now(), widget.cycleStartDay);

    return Container(
      decoration: BoxDecoration(
        color: CraftDecorations.surfaceColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Drag Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header Row: Title & Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Pay Period',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    key: const Key('jump_to_current_period_button'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.today_rounded, size: 16),
                    label: const Text(
                      'Jump to today',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onPeriodSelected(activeCurrentPeriodKey);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    tooltip: 'Close',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Year Selector Pills
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: years.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final year = years[index];
                final isSelectedYear = year == _viewedYear;

                return InkWell(
                  key: Key('year_pill_$year'),
                  borderRadius: BorderRadius.circular(19),
                  onTap: () {
                    setState(() {
                      _viewedYear = year;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelectedYear
                          ? theme.colorScheme.primary
                          : (isDark
                              ? AppTheme.darkSurfaceRaised
                              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(19),
                      border: Border.all(
                        color: isSelectedYear
                            ? theme.colorScheme.primary
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.08)),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$year',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelectedYear ? FontWeight.w800 : FontWeight.w600,
                        color: isSelectedYear
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // 12-Month Grid
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final monthNum = index + 1;
              final periodKey =
                  '$_viewedYear-${monthNum.toString().padLeft(2, '0')}';
              final isSelectedPeriod = periodKey == widget.selectedPeriodKey;
              final hasData = widget.recordedPeriodKeys.contains(periodKey);
              final isCurrentLiveCycle = periodKey == activeCurrentPeriodKey;
              final shortName = PayCycleService.shortMonthNames[index];

              return InkWell(
                key: Key('month_picker_month_$monthNum'),
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onPeriodSelected(periodKey);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelectedPeriod
                        ? theme.colorScheme.primary
                        : (isDark
                            ? AppTheme.darkSurfaceRaised
                            : theme.colorScheme.surfaceContainerLow),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelectedPeriod
                          ? theme.colorScheme.primary
                          : (isCurrentLiveCycle
                              ? theme.colorScheme.primary.withValues(alpha: 0.6)
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.08))),
                      width: isCurrentLiveCycle && !isSelectedPeriod ? 1.5 : 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              shortName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelectedPeriod
                                    ? FontWeight.w800
                                    : FontWeight.w700,
                                color: isSelectedPeriod
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                            if (isCurrentLiveCycle)
                              Padding(
                                padding: const EdgeInsets.only(top: 1),
                                child: Text(
                                  'Current',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: isSelectedPeriod
                                        ? theme.colorScheme.onPrimary.withValues(alpha: 0.9)
                                        : theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Data presence indicator dot
                      if (hasData)
                        Positioned(
                          top: 6,
                          right: 8,
                          child: Container(
                            key: Key('data_indicator_$periodKey'),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isSelectedPeriod
                                  ? theme.colorScheme.onPrimary
                                  : (isDark ? const Color(0xFF4ADE80) : AppTheme.incomeColor),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
  }
}
