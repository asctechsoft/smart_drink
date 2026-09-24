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
    required this.bestTimeRange,
    required this.isOz,
  });

  final String weekLabel;
  final List<int> dailyTotals;
  final int dailyGoal;
  final int totalDrinkCount;
  final int streak;
  final String? bestTimeRange;
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
                value: bestTimeRange ?? '--',
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

// ── Per-day mini card ─────────────────────────────────────────────────────────

/// One day of the current week, shown as a small vertical card: weekday +
/// date, a mini progress ring, the total, and a goal-status badge. Seven of
/// these sit in a row — the day tab already shows the full drink-by-drink
/// list, so this section is a compact overview, not another list.
class WeekDayCard extends StatelessWidget {
  const WeekDayCard({
    super.key,
    required this.summary,
    required this.weekdayLabel,
    required this.dateLabel,
    required this.isOz,
    required this.isSelected,
    this.onTap,
  });

  final DailySummary summary;
  final String weekdayLabel;
  final String dateLabel;
  final bool isOz;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final unit = isOz ? 'oz' : 'ml';
    final total = summary.totalMl;
    final goal = summary.goalMl;
    final hasData = total > 0;

    final _DayStatus status;
    if (!hasData) {
      status = _DayStatus.empty;
    } else if (goal > 0 && total > goal) {
      status = _DayStatus.exceeded;
    } else if (goal > 0 && total >= goal) {
      status = _DayStatus.reached;
    } else {
      status = _DayStatus.notReached;
    }

    final volumeLabel = hasData
        ? UnitConverter.formatVolumeValue(total.toDouble(), unit)
        : '--';
    final progress = (hasData && goal > 0)
        ? (total / goal).clamp(0.0, 1.0)
        : 0.0;

    const radius = BorderRadius.all(Radius.circular(18));
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [Color(0xFF1575CE), Color(0xFF0B58D6)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : null,
        color: isSelected ? null : Colors.white.withValues(alpha: 0.05),
        borderRadius: radius,
        border: Border.all(
          color: isSelected
              ? Colors.transparent
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: Colors.white.withValues(alpha: 0.16),
          highlightColor: Colors.white.withValues(alpha: 0.07),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  weekdayLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 34,
                  height: 34,
                  child: hasData
                      ? CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 3,
                          backgroundColor: Colors.white.withValues(
                            alpha: 0.15,
                          ),
                          valueColor: AlwaysStoppedAnimation(
                            _statusColor(status),
                          ),
                        )
                      : DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 2,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 8),
                Text(
                  volumeLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _DayStatus { empty, notReached, reached, exceeded }

/// Ring colours for each goal status — the card shows the colour only (no
/// label anymore); [WeekStatusLegend] is the one place that spells out what
/// each colour means.
Color _statusColor(_DayStatus status) => switch (status) {
  _DayStatus.exceeded => WeekStatusColors.exceeded,
  _DayStatus.reached => WeekStatusColors.reached,
  _DayStatus.notReached => WeekStatusColors.notReached,
  _DayStatus.empty => Colors.white24,
};

class WeekStatusColors {
  WeekStatusColors._();
  static const Color exceeded = Color(0xFF4FC3F7);
  static const Color reached = Color(0xFF57DCC0);
  static const Color notReached = Color(0xFFFF9B6B);
}

/// A small colour-key row: which ring colour means "exceeded", "reached" or
/// "not reached" — shown once above the week's cards instead of repeating the
/// label as text inside every card.
class WeekStatusLegend extends StatelessWidget {
  const WeekStatusLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Wrap(
      spacing: 14,
      runSpacing: 4,
      children: [
        _dot(ob, WeekStatusColors.exceeded, 'exceeded_goal'.tr),
        _dot(ob, WeekStatusColors.reached, 'goal_reached'.tr),
        _dot(ob, WeekStatusColors.notReached, 'not_reached'.tr),
      ],
    );
  }

  Widget _dot(OnboardingTheme ob, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: ob.textPrimary.withValues(alpha: 0.7)),
        ),
      ],
    );
  }
}
