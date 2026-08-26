import 'package:dsp_base/app_material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternudge/values/app_colors.dart';
import 'package:waternudge/values/onboarding_theme.dart';

import 'history_section.dart';

/// Week / month / year hero: the period total and daily average on the left,
/// the editable daily goal on the right, and the tab's chart underneath.
class PeriodOverviewCard extends StatelessWidget {
  const PeriodOverviewCard({
    super.key,
    required this.totalLabel,
    required this.totalValue,
    required this.averageLine,
    required this.goalValue,
    required this.onEditGoal,
    required this.chart,
  });

  final String totalLabel;
  final String totalValue;
  final String averageLine;
  final String goalValue;
  final VoidCallback onEditGoal;
  final Widget chart;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);

    return HistoryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      totalLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: ob.textPrimary.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        totalValue,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: ob.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      averageLine,
                      style: TextStyle(
                        fontSize: 11,
                        color: ob.textPrimary.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'goal_per_day'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        color: ob.textPrimary.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: onEditGoal,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              goalValue,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: ob.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.edit_outlined,
                            size: 14,
                            color: AppColors.primary500Dark,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          chart,
        ],
      ),
    );
  }
}
