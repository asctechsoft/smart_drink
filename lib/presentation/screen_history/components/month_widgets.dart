import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waternudge/utils/unit_converter.dart';
import 'package:waternudge/values/app_colors.dart';
import 'package:waternudge/values/onboarding_theme.dart';

import 'history_charts.dart';
import 'history_section.dart';

/// Stat icon tint, matching the settings screen icons.
const Color _statIconColor = Color(0xFF96D2A8);

// ── Top card: 4 monthly stats ────────────────────────────────────────────────

class MonthSummaryCard extends StatelessWidget {
  const MonthSummaryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.totalMl,
    required this.monthGoalMl,
    required this.avgPerDayMl,
    required this.dailyGoalMl,
    required this.goalDaysCount,
    required this.daysInMonth,
    required this.isOz,
  });

  /// Left-aligned card title, e.g. "Tổng quan".
  final String title;

  /// Read-only period caption below the title, e.g. "tháng 8, 2026".
  final String subtitle;

  final int totalMl;
  final int monthGoalMl;
  final int avgPerDayMl;
  final int dailyGoalMl;
  final int goalDaysCount;
  final int daysInMonth;
  final bool isOz;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final unit = isOz ? 'oz' : 'ml';

    return HistoryCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: ob.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: ob.textPrimary.withValues(alpha: 0.55),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _MonthStat(
                  icon: SvgPicture.asset(
                    'assets/images/svg/ic_cup_water_bar.svg',
                    width: 22,
                    height: 22,
                    colorFilter: const ColorFilter.mode(
                      _statIconColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: 'Tổng nước',
                  value: UnitConverter.formatVolumeGrouped(
                    totalMl.toDouble(),
                    unit,
                  ),
                ),
              ),
              Expanded(
                child: _MonthStat(
                  icon: const Icon(
                    Icons.water_rounded,
                    size: 22,
                    color: _statIconColor,
                  ),
                  label: 'Trung bình / ngày',
                  value: UnitConverter.formatVolumeGrouped(
                    avgPerDayMl.toDouble(),
                    unit,
                  ),
                ),
              ),
              Expanded(
                child: _MonthStat(
                  icon: SvgPicture.asset(
                    'assets/images/svg/ic_star.svg',
                    width: 22,
                    height: 22,
                    colorFilter: const ColorFilter.mode(
                      _statIconColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: 'Ngày đạt mục tiêu',
                  value: '$goalDaysCount ngày',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthStat extends StatelessWidget {
  const _MonthStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final Widget icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 22, child: icon),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: ob.textPrimary.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF4FC3F7),
          ),
        ),
      ],
    );
  }
}

// ── Chart card: daily bars + 3 bottom stats ──────────────────────────────────

class MonthChartCard extends StatelessWidget {
  const MonthChartCard({
    super.key,
    required this.dailyTotals,
    required this.dailyGoal,
    required this.maxMl,
    required this.minMl,
    required this.avgPerDayMl,
    required this.isOz,
  });

  final List<int> dailyTotals;
  final int dailyGoal;
  final int maxMl;
  final int minMl;
  final int avgPerDayMl;
  final bool isOz;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final unit = isOz ? 'oz' : 'ml';

    return HistoryCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Biểu đồ tổng lượng nước',
            style: TextStyle(
              color: ob.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          MonthBarChart(
            dailyTotals: dailyTotals,
            dailyGoal: dailyGoal,
            isOz: isOz,
          ),
          const SizedBox(height: 12),
          ChartStatsRow(
            stats: [
              ChartStat(
                icon: Icons.trending_down_rounded,
                iconColor: const Color(0xFFFF6B6B),
                label: 'Ngày thấp nhất',
                value: minMl > 0
                    ? UnitConverter.formatVolumeGrouped(minMl.toDouble(), unit)
                    : '--',
              ),
              ChartStat(
                icon: Icons.water_rounded,
                iconColor: AppColors.accentTeal,
                label: 'Trung bình',
                value: UnitConverter.formatVolumeGrouped(
                  avgPerDayMl.toDouble(),
                  unit,
                ),
              ),
              ChartStat(
                icon: Icons.trending_up_rounded,
                iconColor: AppColors.primary500Dark,
                label: 'Ngày cao nhất',
                value: maxMl > 0
                    ? UnitConverter.formatVolumeGrouped(maxMl.toDouble(), unit)
                    : '--',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Calendar grid: "Tổng quan theo ngày" ─────────────────────────────────────

class MonthCalendarGrid extends StatelessWidget {
  const MonthCalendarGrid({
    super.key,
    required this.year,
    required this.month,
    required this.dailyTotals,
    required this.dailyGoal,
    required this.selectedDay,
    required this.isOz,
  });

  final int year;
  final int month;

  /// One entry per day of the month, index 0 = the 1st, in ml.
  final List<int> dailyTotals;
  final int dailyGoal;
  final int selectedDay;
  final bool isOz;

  static const _weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final daysInMonth = dailyTotals.length;
    final firstWeekday = DateTime(year, month, 1).weekday; // Mon = 1
    final leading = firstWeekday - 1;
    final prevMonthDays = DateTime(year, month, 0).day;

    // Cell descriptors: leading (prev month) + this month + trailing (next).
    final cells = <_CellData>[];
    for (var i = 0; i < leading; i++) {
      cells.add(_CellData.other(prevMonthDays - leading + 1 + i));
    }
    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(_CellData.month(d, dailyTotals[d - 1]));
    }
    final trailing = (7 - cells.length % 7) % 7;
    for (var i = 1; i <= trailing; i++) {
      cells.add(_CellData.other(i));
    }

    final rows = <Widget>[];
    for (var r = 0; r < cells.length; r += 7) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              for (var c = 0; c < 7; c++) ...[
                Expanded(
                  child: _DayCell(
                    data: cells[r + c],
                    dailyGoal: dailyGoal,
                    selected:
                        cells[r + c].inMonth &&
                        cells[r + c].day == selectedDay,
                    isOz: isOz,
                  ),
                ),
                if (c < 6) const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      );
    }

    return HistoryCard(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Expanded(
                child: Text(
                  'Tổng quan theo ngày',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _Legend(),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final w in _weekdays) ...[
                Expanded(
                  child: Text(
                    w,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ob.textPrimary.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          ...rows,
        ],
      ),
    );
  }
}

class _CellData {
  const _CellData({required this.day, required this.ml, required this.inMonth});
  factory _CellData.month(int day, int ml) =>
      _CellData(day: day, ml: ml, inMonth: true);
  factory _CellData.other(int day) =>
      _CellData(day: day, ml: 0, inMonth: false);

  final int day;
  final int ml;
  final bool inMonth;
}

/// Colour buckets from the legend: <1.5 L red, 1.5–3 L blue, >3 L teal.
Color _bucketColor(int ml) {
  if (ml < 1500) return const Color(0xFFE5484D);
  if (ml <= 3000) return const Color(0xFF3B82F6);
  return const Color(0xFF2FB89C);
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.data,
    required this.dailyGoal,
    required this.selected,
    required this.isOz,
  });

  final _CellData data;
  final int dailyGoal;
  final bool selected;
  final bool isOz;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);

    // Out-of-month or empty days: a faint outlined placeholder.
    if (!data.inMonth || data.ml <= 0) {
      return Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Text(
          '${data.day}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ob.textPrimary.withValues(alpha: data.inMonth ? 0.5 : 0.3),
          ),
        ),
      );
    }

    final color = _bucketColor(data.ml);
    final reached = dailyGoal > 0 && data.ml >= dailyGoal;
    final litersLabel = isOz
        ? UnitConverter.formatVolumeValue(data.ml.toDouble(), 'oz')
        : '${(data.ml / 1000).toStringAsFixed(1)}L';

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected
              ? const Color(0xFF4FC3F7)
              : color.withValues(alpha: 0.35),
          width: selected ? 1.4 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${data.day}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ob.textPrimary,
                ),
              ),
              if (reached) ...[
                const SizedBox(width: 2),
                const Icon(Icons.star_rounded,
                    size: 11, color: Color(0xFFFACA1F)),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            litersLabel,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    TextStyle style() => TextStyle(
          fontSize: 10,
          color: ob.textPrimary.withValues(alpha: 0.7),
        );
    Widget dot(Color c) => Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        );

    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          dot(const Color(0xFFE5484D)),
          const SizedBox(width: 4),
          Text('< 1.5L', style: style()),
        ]),
        Row(mainAxisSize: MainAxisSize.min, children: [
          dot(const Color(0xFF3B82F6)),
          const SizedBox(width: 4),
          Text('1.5L - 3L', style: style()),
        ]),
        Row(mainAxisSize: MainAxisSize.min, children: [
          dot(const Color(0xFF2FB89C)),
          const SizedBox(width: 4),
          Text('> 3L', style: style()),
        ]),
        Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.star_rounded, size: 11, color: Color(0xFFFACA1F)),
          const SizedBox(width: 4),
          Text('Đạt mục tiêu', style: style()),
        ]),
      ],
    );
  }
}
