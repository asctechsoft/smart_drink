import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartdrinkai/models/data_models/daily_summary.dart';
import 'package:smartdrinkai/utils/unit_converter.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';

import 'history_charts.dart';
import 'history_section.dart';

// ── Top card: progress ring + 3 weekly stats ─────────────────────────────────

class WeekOverviewCard extends StatelessWidget {
  const WeekOverviewCard({
    super.key,
    required this.weekLabel,
    required this.totalMl,
    required this.weekGoalMl,
    required this.avgPerDayMl,
    required this.goalDaysCount,
    required this.bestDayLabel,
    required this.isOz,
  });

  final String weekLabel;
  final int totalMl;
  final int weekGoalMl;
  final int avgPerDayMl;
  final int goalDaysCount;
  final String bestDayLabel;
  final bool isOz;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final unit = isOz ? 'oz' : 'ml';
    final progress = weekGoalMl > 0 ? totalMl / weekGoalMl : 0.0;
    final progressPct = (progress * 100).round();
    final totalLabel = UnitConverter.formatVolumeGrouped(totalMl.toDouble(), unit);
    final goalLabel = UnitConverter.formatVolumeGrouped(weekGoalMl.toDouble(), unit);
    final avgLabel = UnitConverter.formatVolumeGrouped(avgPerDayMl.toDouble(), unit);

    return HistoryCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'this_week'.tr,
            style: TextStyle(
              color: ob.textPrimary,
              fontSize: 15,
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
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: CustomPaint(
                      painter: _RingPainter(progress: progress.clamp(0.0, 1.5)),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/webp/img_cup_water.webp',
                              width: 30,
                              height: 30,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              totalLabel,
                              style: TextStyle(
                                color: ob.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '/ $goalLabel',
                              style: TextStyle(
                                color: ob.textPrimary.withValues(alpha: 0.55),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$progressPct% ${'percent_goal'.tr}',
                    style: TextStyle(
                      color: ob.textPrimary.withValues(alpha: 0.65),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WeekStat(
                      icon: Icons.water_drop_rounded,
                      iconColor: const Color(0xFF4FC3F7),
                      label: 'avg_per_day'.tr,
                      value: avgLabel,
                    ),
                    const SizedBox(height: 14),
                    _WeekStat(
                      icon: Icons.local_drink_outlined,
                      iconColor: const Color(0xFF4FC3F7),
                      label: 'goal_days'.tr,
                      value: '$goalDaysCount/7',
                    ),
                    const SizedBox(height: 14),
                    _WeekStat(
                      icon: Icons.star_rounded,
                      iconColor: const Color(0xFF57DCC0),
                      label: 'best_day'.tr,
                      value: bestDayLabel,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekStat extends StatelessWidget {
  const _WeekStat({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: ob.textPrimary.withValues(alpha: 0.55),
                  fontSize: 11,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF4FC3F7),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 14) / 2;
    const strokeWidth = 10.0;
    const startAngle = -math.pi * 0.75;
    const sweepMax = math.pi * 1.5;

    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepMax,
      false,
      bgPaint,
    );

    if (progress <= 0) return;
    final sweep = sweepMax * progress.clamp(0.0, 1.0);
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradPaint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepMax,
        colors: const [Color(0xFF1E6FE0), Color(0xFF4FC3F7), Color(0xFF1E6FE0)],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, sweep, false, gradPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ── Chart card: bar chart + 3 bottom stats ───────────────────────────────────

class WeekChartCard extends StatelessWidget {
  const WeekChartCard({
    super.key,
    required this.dailyTotals,
    required this.dailyGoal,
    required this.totalDrinkCount,
    required this.streak,
    required this.isOz,
  });

  final List<int> dailyTotals;
  final int dailyGoal;
  final int totalDrinkCount;
  final int streak;
  final bool isOz;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);

    return HistoryCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'week_chart'.tr,
                  style: TextStyle(
                    color: ob.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'by_day'.tr,
                      style: TextStyle(
                        color: ob.textPrimary.withValues(alpha: 0.8),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 15,
                      color: ob.textPrimary.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '(${isOz ? 'oz' : 'ml'})',
            style: TextStyle(
              fontSize: 10,
              color: ob.textPrimary.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 4),
          WeekBarChart(
            dailyTotals: dailyTotals,
            dailyGoal: dailyGoal,
            isOz: isOz,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _BottomStat(
                    icon: Icons.water_outlined,
                    iconColor: const Color(0xFF4FC3F7),
                    label: 'total_drink_count'.tr,
                    value: '$totalDrinkCount',
                  ),
                ),
                Container(
                  width: 0.5,
                  height: 36,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                Expanded(
                  child: _BottomStat(
                    icon: Icons.trending_up_rounded,
                    iconColor: const Color(0xFF4FC3F7),
                    label: 'best_time_range'.tr,
                    value: '--',
                  ),
                ),
                Container(
                  width: 0.5,
                  height: 36,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                Expanded(
                  child: _BottomStat(
                    icon: Icons.local_fire_department_rounded,
                    iconColor: const Color(0xFFFF6B6B),
                    label: 'streak_done'.tr,
                    value: streak > 0 ? '$streak ${'unit_days'.tr}' : '--',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomStat extends StatelessWidget {
  const _BottomStat({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 9,
            color: ob.textPrimary.withValues(alpha: 0.55),
          ),
        ),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4FC3F7),
          ),
        ),
      ],
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
