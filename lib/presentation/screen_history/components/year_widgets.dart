import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternudge/utils/unit_converter.dart';
import 'package:waternudge/values/app_colors.dart';
import 'package:waternudge/values/onboarding_theme.dart';

import 'history_charts.dart';
import 'history_section.dart';

// ── Chart card 1: total volume per month + 3 bottom stats ────────────────────

class YearVolumeCard extends StatelessWidget {
  const YearVolumeCard({
    super.key,
    required this.monthlyTotals,
    required this.monthlyGoals,
    required this.isFutureMonth,
    required this.goalLabel,
    required this.maxMl,
    required this.minMl,
    required this.avgPerMonthMl,
    required this.isOz,
  });

  final List<int> monthlyTotals;
  final List<int> monthlyGoals;
  final bool Function(int month) isFutureMonth;
  final String goalLabel;
  final int maxMl;
  final int minMl;
  final int avgPerMonthMl;
  final bool isOz;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final unit = isOz ? 'oz' : 'ml';

    return HistoryCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'history_year_volume_title'.tr,
            style: TextStyle(
              color: ob.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          YearBarChart(
            monthlyTotals: monthlyTotals,
            monthlyGoals: monthlyGoals,
            isFutureMonth: isFutureMonth,
            goalLabel: goalLabel,
            isOz: isOz,
          ),
          const SizedBox(height: 12),
          ChartStatsRow(
            stats: [
              ChartStat(
                icon: Icons.trending_down_rounded,
                iconColor: const Color(0xFFFF6B6B),
                label: 'history_stat_lowest_month'.tr,
                value: minMl > 0
                    ? UnitConverter.formatVolumeGrouped(minMl.toDouble(), unit)
                    : '--',
              ),
              ChartStat(
                icon: Icons.water_rounded,
                iconColor: AppColors.accentTeal,
                label: 'history_stat_avg_per_month'.tr,
                value: UnitConverter.formatVolumeGrouped(
                  avgPerMonthMl.toDouble(),
                  unit,
                ),
              ),
              ChartStat(
                icon: Icons.trending_up_rounded,
                iconColor: AppColors.primary500Dark,
                label: 'history_stat_highest_month'.tr,
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

// ── Chart card 2: goal-completion rate per month ─────────────────────────────

class YearGoalRateCard extends StatelessWidget {
  const YearGoalRateCard({
    super.key,
    required this.monthlyRates,
    this.targetPct = 100,
  });

  final List<double> monthlyRates;
  final double targetPct;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return HistoryCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'history_year_goal_rate_title'.tr,
            style: TextStyle(
              color: ob.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          YearGoalRateChart(
            monthlyRates: monthlyRates,
            targetPct: targetPct,
          ),
        ],
      ),
    );
  }
}

