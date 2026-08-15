import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/history_controller.dart';
import 'package:smartdrinkai/controller/settings_controller.dart';
import 'package:smartdrinkai/controller/today_controller.dart';
import 'package:smartdrinkai/models/data_models/daily_summary.dart';
import 'package:smartdrinkai/models/data_models/drink_record.dart';
import 'package:smartdrinkai/models/ui_models/drink_type.dart';
import 'package:smartdrinkai/presentation/common_components/onboarding_background.dart';
import 'package:smartdrinkai/presentation/common_components/primary_button.dart';
import 'package:smartdrinkai/utils/date_utils.dart';
import 'package:smartdrinkai/utils/unit_converter.dart';
import 'package:smartdrinkai/values/app_colors.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:smartdrinkai/presentation/common_components/primary_dialog.dart';
import 'package:smartdrinkai/utils/toast_utils.dart';
import 'package:get/get.dart';
import 'history_bar_chart.dart';
import 'components/history_period_selector.dart';
import 'components/history_date_picker.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final RxBool _showAllRecords = false.obs;

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _shortDayName(DateTime day) {
    const viNames = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return viNames[day.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final controller = Get.find<HistoryController>();
    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 10,
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      Text(
                        'history'.tr,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: ob.textPrimary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const Spacer(),
                      Obx(() {
                        final isDay =
                            controller.viewMode.value == HistoryViewMode.day;
                        if (!isDay) return const SizedBox.shrink();
                        return GestureDetector(
                          onTap: () {
                            HistoryDatePicker.show(
                              context,
                              initialDate: controller.selectedDate.value,
                              lastDate: DateTime.now(),
                            ).then((d) {
                              if (d != null) controller.selectedDate.value = d;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ob.bgOption,
                              border: Border.all(
                                color: ob.borderTabHistory,
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.calendar_month_rounded,
                              color: ob.textPrimary,
                              size: 20,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Segment tabs ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Obx(() => _buildTabs(context, controller)),
                ),

                const SizedBox(height: 10),

                // ── Scrollable content ───────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Period navigator OR week day strip
                        Obx(() {
                          final isDay =
                              controller.viewMode.value == HistoryViewMode.day;
                          if (isDay) {
                            return _buildDayWeekStrip(context, controller);
                          }
                          return HistoryPeriodSelector(
                            controller: controller,
                            onTitleTap: () {
                              if (controller.viewMode.value ==
                                  HistoryViewMode.day) {
                                HistoryDatePicker.show(
                                  context,
                                  initialDate: controller.selectedDate.value,
                                  lastDate: DateTime.now(),
                                ).then((d) {
                                  if (d != null)
                                    controller.selectedDate.value = d;
                                });
                              }
                            },
                          );
                        }),

                        // Date label (day view only)
                        Obx(() {
                          if (controller.viewMode.value !=
                              HistoryViewMode.day) {
                            return const SizedBox.shrink();
                          }
                          return _buildDayDateLabel(context, controller);
                        }),

                        const SizedBox(height: 8),

                        // ── Chart card ───────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: ob.bgReminderOption,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(
                                  () => _buildChartStats(context, controller),
                                ),
                                const SizedBox(height: 16),
                                const SizedBox(
                                  height: 130,
                                  child: HistoryBarChart(),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ── Stats section (week/month/year only) ──────────
                        Obx(() {
                          final isDay =
                              controller.viewMode.value == HistoryViewMode.day;
                          if (isDay) return const SizedBox.shrink();
                          final summLen = controller.summaries.length;
                          if (summLen == 0) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildStatsSection(
                              context,
                              controller,
                              isDay: isDay,
                            ),
                          );
                        }),

                        // ── Drink records (day view) ─────────────────────
                        Obx(() {
                          if (controller.viewMode.value !=
                              HistoryViewMode.day) {
                            return const SizedBox.shrink();
                          }
                          // Force track both dayRecords and showAll toggle
                          final recordCount = controller.dayRecords.length;
                          final showAll = _showAllRecords.value;
                          if (recordCount == 0) {
                            return _buildEmptyState(ob);
                          }
                          return _buildDayDrinkLog(
                            context,
                            controller,
                            showAll: showAll,
                            recordCount: recordCount,
                          );
                        }),

                        // ── Lịch sử uống nước (week/month/year) ─────────
                        Obx(() {
                          if (controller.viewMode.value ==
                              HistoryViewMode.day) {
                            return const SizedBox.shrink();
                          }
                          final sortedSummaries = controller.summaries.toList()
                            ..sort((a, b) => b.dateKey.compareTo(a.dateKey));
                          if (sortedSummaries.isEmpty)
                            return _buildEmptyState(ob);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  12,
                                ),
                                child: Text(
                                  'Lịch sử uống nước',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: ob.textPrimary,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: ob.bgReminderOption,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: sortedSummaries.length,
                                    separatorBuilder: (context2, i2) => Divider(
                                      height: 1,
                                      color: ob.borderTabHistory,
                                    ),
                                    itemBuilder: (ctx, i) => _SummaryItem(
                                      summary: sortedSummaries[i],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Day week strip ─────────────────────────────────────────────────────────

  Widget _buildDayWeekStrip(
    BuildContext context,
    HistoryController controller,
  ) {
    final ob = OnboardingTheme.of(context);
    final sel = controller.selectedDate.value;
    final weekStart = AppDateUtils.startOfWeek(sel);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nowWeekStart = AppDateUtils.startOfWeek(now);
    final canGoNext = weekStart.isBefore(nowWeekStart);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              controller.selectedDate.value = sel.subtract(
                const Duration(days: 7),
              );
            },
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ob.bgOption,
                border: Border.all(color: ob.borderTabHistory, width: 1),
              ),
              child: Icon(
                Icons.chevron_left_rounded,
                size: 20,
                color: ob.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 2),
          ...List.generate(7, (i) {
            final day = weekStart.add(Duration(days: i));
            final dayOnly = DateTime(day.year, day.month, day.day);
            final isSelected = _isSameDay(day, sel);
            final isFuture = dayOnly.isAfter(today);
            return Expanded(
              child: GestureDetector(
                onTap: isFuture
                    ? null
                    : () => controller.selectedDate.value = day,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _shortDayName(day),
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? ob.accent : ob.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? ob.accent : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isFuture
                                    ? ob.textSecondary.withValues(alpha: 0.35)
                                    : ob.textPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(width: 2),
          SizedBox(
            width: 32,
            height: 32,
            child: canGoNext
                ? GestureDetector(
                    onTap: () {
                      final next = sel.add(const Duration(days: 7));
                      controller.selectedDate.value = next.isAfter(now)
                          ? now
                          : next;
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ob.bgOption,
                        border: Border.all(
                          color: ob.borderTabHistory,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: ob.textPrimary,
                      ),
                    ),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  // ── Day date label ─────────────────────────────────────────────────────────

  Widget _buildDayDateLabel(
    BuildContext context,
    HistoryController controller,
  ) {
    final ob = OnboardingTheme.of(context);
    final sel = controller.selectedDate.value;
    final dayName = AppDateUtils.viDayName(sel);
    final label = '$dayName, ${sel.day} Thg ${sel.month}, ${sel.year}';

    return GestureDetector(
      onTap: () =>
          HistoryDatePicker.show(
            context,
            initialDate: sel,
            lastDate: DateTime.now(),
          ).then((d) {
            if (d != null) controller.selectedDate.value = d;
          }),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ob.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.calendar_month_outlined,
              size: 16,
              color: ob.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  // ── Day drink log ──────────────────────────────────────────────────────────

  Widget _buildDayDrinkLog(
    BuildContext context,
    HistoryController controller, {
    required bool showAll,
    required int recordCount,
  }) {
    final ob = OnboardingTheme.of(context);
    final records = controller.dayRecords;
    final maxVisible = showAll ? recordCount : recordCount.clamp(0, 4);
    final hasMore = recordCount > 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              Text(
                'drink_history'.tr,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: ob.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                'Tổng ${records.length} lần uống',
                style: TextStyle(
                  fontSize: 13,
                  color: ob.switchActive,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (int i = 0; i < maxVisible; i++) ...[
                if (i > 0) const SizedBox(height: 2),
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(i == 0 ? 16 : 0),
                    topRight: Radius.circular(i == 0 ? 16 : 0),
                    bottomLeft: Radius.circular(i == maxVisible - 1 ? 16 : 0),
                    bottomRight: Radius.circular(i == maxVisible - 1 ? 16 : 0),
                  ),
                  child: _NewDrinkItem(
                    record: records[i],
                    onEdit: () =>
                        _showEditDialog(context, controller, records[i]),
                    onDelete: () => controller.deleteRecord(records[i]),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (hasMore) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showAllRecords.value = !_showAllRecords.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: ob.bgOption,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ob.borderTabHistory, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      showAll ? 'Thu gọn' : 'Xem tất cả',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: ob.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      showAll
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: ob.textPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }

  // ── Tabs ───────────────────────────────────────────────────────────────────

  Widget _buildTabs(BuildContext context, HistoryController controller) {
    final ob = OnboardingTheme.of(context);
    final modes = [
      (HistoryViewMode.day, 'day'),
      (HistoryViewMode.week, 'week'),
      (HistoryViewMode.month, 'month'),
      (HistoryViewMode.year, 'year'),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ob.bgOption,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: ob.borderTabHistory, width: 1),
      ),
      child: Row(
        children: modes.map((entry) {
          final mode = entry.$1;
          final key = entry.$2;
          final isSelected = controller.viewMode.value == mode;
          final raw = key.tr;
          final label = raw[0].toUpperCase() + raw.substring(1);
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.viewMode.value = mode,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? ob.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? ob.textToggleActive : ob.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Chart stats ────────────────────────────────────────────────────────────

  Widget _buildChartStats(BuildContext context, HistoryController controller) {
    final ob = OnboardingTheme.of(context);
    final volumeUnit = Get.find<SettingsController>().volumeUnit.value;
    final isDay = controller.viewMode.value == HistoryViewMode.day;

    if (isDay) {
      final total = controller.computedTotal;
      final goal = controller.goalMl.value;
      final totalFmt = UnitConverter.formatVolumeValue(
        total.toDouble(),
        volumeUnit,
      );
      final goalFmt = UnitConverter.formatVolumeValue(
        goal.toDouble(),
        volumeUnit,
      );
      final pct = goal > 0 ? ((total / goal) * 100).clamp(0, 100).round() : 0;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tổng lượng nước',
                  style: TextStyle(
                    fontSize: 12,
                    color: ob.textPrimary.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  totalFmt,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: ob.switchActive,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Mục tiêu: $goalFmt',
                      style: TextStyle(fontSize: 12, color: ob.textSecondary),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.edit_outlined,
                      size: 12,
                      color: ob.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hoàn thành',
                  style: TextStyle(
                    fontSize: 12,
                    color: ob.textPrimary.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$pct%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: ob.switchActive,
                  ),
                ),
                if (pct >= 100) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: ob.switchActive.withValues(alpha: 0.5),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      'Đã đạt mục tiêu! 🎉',
                      style: TextStyle(
                        fontSize: 11,
                        color: ob.switchActive,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    // Week/month/year: avg + total side by side
    final avg = controller.avgPerDayMl;
    final total = controller.computedTotal;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trung bình mỗi ngày',
                style: TextStyle(
                  fontSize: 12,
                  color: ob.textPrimary.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                UnitConverter.formatVolumeValue(avg.toDouble(), volumeUnit),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: ob.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tổng lượng nước',
                style: TextStyle(
                  fontSize: 12,
                  color: ob.textPrimary.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                UnitConverter.formatVolumeValue(total.toDouble(), volumeUnit),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: ob.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Stats section ──────────────────────────────────────────────────────────

  Widget _buildStatsSection(
    BuildContext context,
    HistoryController controller, {
    bool isDay = false,
  }) {
    final ob = OnboardingTheme.of(context);
    final volumeUnit = Get.find<SettingsController>().volumeUnit.value;

    final int goalDays;
    final int periodDays;
    final DailySummary? maxS;
    final DailySummary? minS;

    if (isDay) {
      goalDays = controller.dayViewGoalDays;
      periodDays = controller.weekSummariesForDay.length;
      maxS = controller.dayViewMaxSummary;
      minS = controller.dayViewMinSummary;
    } else {
      goalDays = controller.goalDaysCount;
      periodDays = controller.summaries.length;
      maxS = controller.maxDaySummary;
      minS = controller.minDaySummary;
    }

    final streakDays = Get.isRegistered<TodayController>()
        ? Get.find<TodayController>().streakDays.value
        : 0;

    String maxVal = '--';
    String maxDay = '';
    String minVal = '--';
    String minDay = '';

    if (maxS != null) {
      maxVal = UnitConverter.formatVolumeValue(
        maxS.totalMl.toDouble(),
        volumeUnit,
      );
      try {
        maxDay = AppDateUtils.viDayName(DateTime.parse(maxS.dateKey));
      } catch (_) {}
    }
    if (minS != null) {
      minVal = UnitConverter.formatVolumeValue(
        minS.totalMl.toDouble(),
        volumeUnit,
      );
      try {
        minDay = AppDateUtils.viDayName(DateTime.parse(minS.dateKey));
      } catch (_) {}
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isDay) ...[
          Text(
            'Thống kê',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ob.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: _StatBlock(
                emoji: '🎯',
                label: 'Đạt mục tiêu',
                value: '$goalDays/$periodDays ngày',
                ob: ob,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatBlock(
                emoji: '🔥',
                label: 'Chuỗi ngày hiện tại',
                value: '$streakDays ngày',
                ob: ob,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _StatBlock(
                emoji: '⭐',
                label: 'Uống nhiều nhất',
                value: maxVal,
                sub: maxDay,
                ob: ob,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatBlock(
                emoji: '💧',
                label: 'Uống ít nhất',
                value: minVal,
                sub: minDay,
                ob: ob,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildEmptyState(OnboardingTheme ob) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon('assets/images/svg/ic_no_record.svg', size: 80),
          const SizedBox(height: 12),
          Text(
            'no_records_found'.tr,
            style: TextStyle(fontSize: 14, color: ob.bgDrag),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    HistoryController controller,
    DrinkRecord record,
  ) {
    final volumeUnit = Get.find<SettingsController>().volumeUnit.value;
    final isOz = volumeUnit == 'oz';
    final displayMl = record.originalAmountMl > 0
        ? record.originalAmountMl
        : record.amountMl.toDouble();
    final initialValueStr = UnitConverter.formatVolumeValue(
      displayMl,
      volumeUnit,
    );
    final textController = TextEditingController(text: initialValueStr);
    final focusNode = FocusNode();

    Future.delayed(
      const Duration(milliseconds: 150),
      () => focusNode.requestFocus(),
    );

    PrimaryDialog.show(
      context: context,
      title: 'edit_drink'.tr,
      content: StatefulBuilder(
        builder: (ctx, setState) {
          final ob = OnboardingTheme.of(ctx);
          return AppColumn(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppRow(
                modifier: Modifier.background(
                  color: ob.bgToggle,
                  radius: 12,
                ).padding(horizontal: 16),
                children: [
                  AppIcon(
                    'assets/images/webp/img_measuring_cup.webp',
                    size: 24,
                    tint: ob.switchActive,
                  ),
                  const AppSpacerW(8),
                  Expanded(
                    child: TextField(
                      controller: textController,
                      focusNode: focusNode,
                      keyboardType: isOz
                          ? const TextInputType.numberWithOptions(decimal: true)
                          : TextInputType.number,
                      inputFormatters: [
                        isOz
                            ? FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              )
                            : FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: TextStyle(color: ob.textPrimary, fontSize: 16),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '',
                      ),
                      autofocus: false,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  AppText(
                    volumeUnit,
                    style: TextStyle(
                      color: ob.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const AppSpacerH(32),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: 'cancel'.tr,
                      outlined: true,
                      onPressed: () => Navigator.pop(ctx),
                      height: 44,
                    ),
                  ),
                  const AppSpacerW(12),
                  Expanded(
                    child: PrimaryButton(
                      text: 'save'.tr,
                      useGradient: true,
                      height: 44,
                      enabled: textController.text.trim().isNotEmpty,
                      onPressed: () {
                        final val = double.tryParse(textController.text);
                        if (val != null && val > 0) {
                          Navigator.pop(ctx);
                          final type = DrinkType.values.firstWhere(
                            (t) => t.name == record.drinkType,
                            orElse: () => DrinkType.water,
                          );
                          final double valInMl = isOz
                              ? UnitConverter.ozToMl(val)
                              : val;
                          final effectiveWater =
                              (valInMl * type.waterPercent / 100).round();
                          final todayController = Get.find<TodayController>();
                          final intakeWithoutThis =
                              todayController.currentIntakeMl.value -
                              record.amountMl;
                          if (intakeWithoutThis + effectiveWater > 8000) {
                            ToastUtils.showLimitToast(context);
                            return;
                          }
                          controller.updateRecord(
                            record.copyWith(
                              amountMl: effectiveWater,
                              originalAmountMl: valInMl,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Stat block ────────────────────────────────────────────────────────────────

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.emoji,
    required this.label,
    required this.value,
    this.sub,
    required this.ob,
  });

  final String emoji;
  final String label;
  final String value;
  final String? sub;
  final OnboardingTheme ob;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ob.bgOption,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: ob.textPrimary.withValues(alpha: 0.6),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ob.textPrimary,
                    height: 1,
                  ),
                ),
                if (sub != null && sub!.isNotEmpty)
                  Text(
                    sub!,
                    style: TextStyle(
                      fontSize: 12,
                      color: ob.textPrimary.withValues(alpha: 0.6),
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

// ─── Daily summary item ────────────────────────────────────────────────────────

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.summary});

  final DailySummary summary;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final volumeUnit = Get.find<SettingsController>().volumeUnit.value;
    DateTime? dt;
    try {
      dt = DateTime.parse(summary.dateKey);
    } catch (_) {}
    final dateStr = dt != null
        ? AppDateUtils.formatViDate(dt)
        : summary.dateKey;
    final totalVal = UnitConverter.formatVolumeValue(
      summary.totalMl.toDouble(),
      volumeUnit,
    );
    final goalVal = UnitConverter.formatVolumeValue(
      summary.goalMl.toDouble(),
      volumeUnit,
    );
    final pct = summary.goalMl > 0
        ? ((summary.totalMl / summary.goalMl) * 100).clamp(0, 100).toInt()
        : 0;
    final progress = summary.goalMl > 0
        ? (summary.totalMl / summary.goalMl).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 13,
                  color: ob.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: totalVal,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF67B5E2),
                      ),
                    ),
                    TextSpan(
                      text: ' / $goalVal',
                      style: TextStyle(
                        fontSize: 13,
                        color: ob.textPrimary.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: ob.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: ob.textPrimary.withValues(alpha: 0.4),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: ob.borderTabHistory,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF4DC0FC)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── New drink item (day view redesign) ───────────────────────────────────────

class _NewDrinkItem extends StatelessWidget {
  const _NewDrinkItem({
    required this.record,
    required this.onEdit,
    required this.onDelete,
  });

  final DrinkRecord record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final type = DrinkType.values.firstWhere(
      (t) => t.name == record.drinkType,
      orElse: () => DrinkType.water,
    );
    final timeFormat = Get.find<SettingsController>().timeFormat.value;
    final timeStr = UnitConverter.formatTime(
      '${record.timestamp.hour.toString().padLeft(2, '0')}:${record.timestamp.minute.toString().padLeft(2, '0')}',
      timeFormat,
    );
    final volumeUnit = Get.find<SettingsController>().volumeUnit.value;
    final displayMl = record.originalAmountMl > 0
        ? record.originalAmountMl
        : record.amountMl.toDouble();
    final amountDisplay = UnitConverter.formatVolumeValueUnit(
      displayMl,
      volumeUnit,
    );

    return Container(
      color: ob.bgOption,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ob.switchActive.withValues(alpha: 0.12),
            ),
            padding: const EdgeInsets.all(8),
            child: Image.asset(type.imagePath, fit: BoxFit.contain),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: ob.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  type.label.tr,
                  style: TextStyle(fontSize: 12, color: ob.textSecondary),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 160,
            height: 44,
            child: Slidable(
              key: ValueKey(
                'amount-${record.id ?? record.timestamp.microsecondsSinceEpoch}',
              ),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.5,
                children: [
                  SlidableAction(
                    onPressed: (_) => onEdit(),
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    icon: Icons.edit_outlined,
                  ),
                  SlidableAction(
                    onPressed: (_) => onDelete(),
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    icon: Icons.delete_outline,
                  ),
                ],
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  amountDisplay,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ob.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
