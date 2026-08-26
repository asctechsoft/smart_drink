import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternudge/models/data_models/daily_summary.dart';
import 'package:waternudge/values/app_colors.dart';
import 'package:waternudge/utils/unit_converter.dart';
import 'package:waternudge/values/onboarding_theme.dart';

import 'history_charts.dart';
import 'history_section.dart';

// ── Chart card: bar chart + 3 bottom stats ───────────────────────────────────

class WeekChartCard extends StatelessWidget {
  const WeekChartCard({
    super.key,
    required this.weekLabel,
    required this.dailyTotals,
    required this.dailyGoal,
    required this.totalDrinkCount,
    required this.streak,
    required this.isOz,
  });

  final String weekLabel;
  final List<int> dailyTotals;
  final int dailyGoal;
  final int totalDrinkCount;
  final int streak;
  final bool isOz;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);

    return HistoryCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'week_chart'.tr,
            style: TextStyle(
              color: ob.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            weekLabel,
            style: TextStyle(
              color: ob.textPrimary.withValues(alpha: 0.55),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          WeekBarChart(
            dailyTotals: dailyTotals,
            dailyGoal: dailyGoal,
            isOz: isOz,
          ),
          const SizedBox(height: 8),
          ChartStatsRow(
            stats: [
              ChartStat(
                icon: Icons.water_rounded,
                iconColor: AppColors.accentTeal,
                label: 'total_drink_count'.tr,
                value: '$totalDrinkCount',
              ),
              ChartStat(
                icon: Icons.trending_up_rounded,
                iconColor: AppColors.primary500Dark,
                label: 'best_time_range'.tr,
                value: '--',
              ),
              ChartStat(
                icon: Icons.local_fire_department_rounded,
                iconColor: const Color(0xFFFF6B6B),
                label: 'streak_done'.tr,
                value: streak > 0 ? '$streak ${'unit_days'.tr}' : '--',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Per-day detail row ────────────────────────────────────────────────────────

class WeekDayRow extends StatelessWidget {
  const WeekDayRow({
    super.key,
    required this.summary,
    required this.weekdayLabel,
    required this.dateLabel,
    required this.isOz,
  });

  final DailySummary summary;
  final String weekdayLabel;
  final String dateLabel;
  final bool isOz;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final unit = isOz ? 'oz' : 'ml';
    final total = summary.totalMl;
    final goal = summary.goalMl;

    final _DayStatus status;
    if (total <= 0) {
      status = _DayStatus.empty;
    } else if (goal > 0 && total > goal) {
      status = _DayStatus.exceeded;
    } else if (goal > 0 && total >= goal) {
      status = _DayStatus.reached;
    } else {
      status = _DayStatus.notReached;
    }

    final volumeLabel = total > 0
        ? UnitConverter.formatVolumeGrouped(total.toDouble(), unit)
        : '--';

    return HistoryCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Image.asset(
            'assets/images/webp/img_cup_water.webp',
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  weekdayLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: ob.textPrimary,
                  ),
                ),
                Text(
                  dateLabel,
                  style: TextStyle(
                    fontSize: 11,
                    color: ob.textPrimary.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 52,
            child: Text(
              volumeLabel,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ob.textPrimary.withValues(alpha: 0.9),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: status == _DayStatus.empty
                ? const SizedBox.shrink()
                : _GoalBadge(status: status),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.chevron_right_rounded,
            size: 22,
            color: Color(0xFF96D2A8),
          ),
        ],
      ),
    );
  }
}

enum _DayStatus { empty, notReached, reached, exceeded }

class _GoalBadge extends StatelessWidget {
  const _GoalBadge({required this.status});
  final _DayStatus status;

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color color;
    switch (status) {
      case _DayStatus.exceeded:
        label = 'exceeded_goal'.tr;
        color = const Color(0xFF4FC3F7);
      case _DayStatus.reached:
        label = 'goal_reached'.tr;
        color = const Color(0xFF57DCC0);
      case _DayStatus.notReached:
        label = 'not_reached'.tr;
        color = const Color(0xFFFF9B6B);
      case _DayStatus.empty:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
