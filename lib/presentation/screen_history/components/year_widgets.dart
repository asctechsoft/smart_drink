import 'package:flutter/material.dart';
import 'package:smartdrinkai/utils/unit_converter.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';

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
    required this.maxMonthLabel,
    required this.minMl,
    required this.minMonthLabel,
    required this.avgPerMonthMl,
    required this.isOz,
  });

  final List<int> monthlyTotals;
  final List<int> monthlyGoals;
  final bool Function(int month) isFutureMonth;
  final String goalLabel;
  final int maxMl;
  final String maxMonthLabel;
  final int minMl;
  final String minMonthLabel;
  final int avgPerMonthMl;
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tổng lượng nước theo tháng',
                  style: TextStyle(
                    color: ob.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _Pill(label: 'Theo tháng'),
            ],
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
                  child: YearBottomStat(
                    icon: Icons.trending_up_rounded,
                    iconColor: const Color(0xFF4FC3F7),
                    label: 'Tháng cao nhất',
                    line1: maxMonthLabel,
                    line2: maxMl > 0
                        ? UnitConverter.formatVolumeGrouped(
                            maxMl.toDouble(),
                            unit,
                          )
                        : '--',
                  ),
                ),
                Container(
                  width: 0.5,
                  height: 44,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                Expanded(
                  child: YearBottomStat(
                    icon: Icons.trending_down_rounded,
                    iconColor: const Color(0xFFFF6B6B),
                    label: 'Tháng thấp nhất',
                    line1: minMonthLabel,
                    line2: minMl > 0
                        ? UnitConverter.formatVolumeGrouped(
                            minMl.toDouble(),
                            unit,
                          )
                        : '--',
                  ),
                ),
                Container(
                  width: 0.5,
                  height: 44,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                Expanded(
                  child: YearBottomStat(
                    icon: Icons.water_rounded,
                    iconColor: const Color(0xFF4FC3F7),
                    label: 'Trung bình tháng',
                    line1: UnitConverter.formatVolumeGrouped(
                      avgPerMonthMl.toDouble(),
                      unit,
                    ),
                    line2: '',
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
            'Tỷ lệ đạt mục tiêu theo tháng',
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

class _Pill extends StatelessWidget {
  const _Pill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
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
    );
  }
}

class YearBottomStat extends StatelessWidget {
  const YearBottomStat({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.line1,
    required this.line2,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String line1;
  final String line2;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 15, color: iconColor),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: ob.textPrimary.withValues(alpha: 0.55),
                ),
              ),
              Text(
                line1,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ob.textPrimary.withValues(alpha: 0.85),
                ),
              ),
              if (line2.isNotEmpty)
                Text(
                  line2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4FC3F7),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
