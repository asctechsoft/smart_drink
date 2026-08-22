import 'package:dsp_base/app_material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smartdrinkai/controller/streak_controller.dart';
import 'package:smartdrinkai/utils/date_utils.dart';
import 'package:smartdrinkai/values/app_colors.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';

/// Month grid marking every day as tracked / partially met / missed.
class StreakCalendar extends StatelessWidget {
  const StreakCalendar({super.key, required this.controller});

  final StreakController controller;

  static const Color _trackedColor = Color(0xFF4ADE80);
  static const Color _partialColor = Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: ob.cardGlowShadow,
      ),
      child: Obx(() {
        final month = controller.visibleMonth.value;
        return Column(
          children: [
            _buildMonthHeader(context, month),
            const SizedBox(height: 16),
            _buildWeekdayRow(context),
            const SizedBox(height: 8),
            _buildDayGrid(context, month),
            const SizedBox(height: 16),
            _buildLegend(context),
          ],
        );
      }),
    );
  }

  Widget _buildMonthHeader(BuildContext context, DateTime month) {
    final ob = OnboardingTheme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _NavArrow(
          icon: Icons.chevron_left_rounded,
          onTap: controller.previousMonth,
        ),
        Text(
          AppDateUtils.monthLabel(month),
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: ob.textPrimary,
          ),
        ),
        _NavArrow(
          icon: Icons.chevron_right_rounded,
          onTap: controller.nextMonth,
        ),
      ],
    );
  }

  Widget _buildWeekdayRow(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final loc = Get.locale?.languageCode;
    final fmt = DateFormat('E', loc);
    // Any known Monday works as the anchor for the short weekday names.
    final monday = DateTime(2024, 1, 1);

    return Row(
      children: List.generate(7, (i) {
        return Expanded(
          child: Center(
            child: Text(
              fmt.format(monday.add(Duration(days: i))),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: ob.textPrimary.withValues(alpha: 0.55),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDayGrid(BuildContext context, DateTime month) {
    final firstOfMonth = DateTime(month.year, month.month, 1);
    // Monday-first grid: back up to the Monday on or before the 1st.
    final gridStart = firstOfMonth.subtract(
      Duration(days: firstOfMonth.weekday - 1),
    );

    final rows = <Widget>[];
    for (var week = 0; week < 6; week++) {
      rows.add(
        Row(
          children: List.generate(7, (day) {
            final date = gridStart.add(Duration(days: week * 7 + day));
            return Expanded(
              child: _DayCell(
                date: date,
                inMonth: date.month == month.month,
                status: controller.statusOf(date),
                trackedColor: _trackedColor,
                partialColor: _partialColor,
              ),
            );
          }),
        ),
      );
    }

    return Column(children: rows);
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _LegendItem(label: 'streak_tracked'.tr, color: _trackedColor),
        _LegendItem(
          label: 'streak_partially_met'.tr,
          color: _partialColor,
          outlined: true,
        ),
        _LegendItem(label: 'streak_missed'.tr, color: AppColors.basic300),
      ],
    );
  }
}

class _NavArrow extends StatelessWidget {
  const _NavArrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Icon(icon, size: 26, color: ob.textPrimary),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.inMonth,
    required this.status,
    required this.trackedColor,
    required this.partialColor,
  });

  final DateTime date;
  final bool inMonth;
  final DayStatus status;
  final Color trackedColor;
  final Color partialColor;

  bool get _isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);

    Color textColor = ob.textPrimary;
    Color? fill;
    Color? border;

    if (!inMonth) {
      textColor = ob.textPrimary.withValues(alpha: 0.25);
    } else {
      switch (status) {
        case DayStatus.tracked:
          fill = trackedColor.withValues(alpha: 0.22);
          textColor = trackedColor;
          break;
        case DayStatus.partial:
          border = partialColor;
          break;
        case DayStatus.missed:
          textColor = ob.textPrimary.withValues(alpha: 0.85);
          break;
      }
    }

    if (_isToday && inMonth) {
      border = AppColors.primary500Dark;
    }

    return SizedBox(
      height: 36,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: fill,
                border: border == null
                    ? null
                    : Border.all(color: border, width: 1.5),
              ),
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: _isToday ? FontWeight.w700 : FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.label,
    required this.color,
    this.outlined = false,
  });

  final String label;
  final Color color;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: outlined ? Colors.transparent : color,
            border: outlined ? Border.all(color: color, width: 1.5) : null,
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: ob.textPrimary.withValues(alpha: 0.75),
            ),
          ),
        ),
      ],
    );
  }
}
