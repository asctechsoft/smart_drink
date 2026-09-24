import 'package:dsp_base/app_material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:waternudge/controller/history_controller.dart';
import 'package:waternudge/controller/settings_controller.dart';
import 'package:waternudge/controller/today_controller.dart';
import 'package:waternudge/models/data_models/daily_summary.dart';
import 'package:waternudge/models/data_models/drink_record.dart';
import 'package:waternudge/models/ui_models/drink_type.dart';
import 'package:waternudge/presentation/common_components/onboarding_background.dart';
import 'package:waternudge/presentation/common_components/primary_button.dart';
import 'package:waternudge/presentation/common_components/primary_dialog.dart';
import 'package:waternudge/utils/analytics.dart';
import 'package:waternudge/utils/date_utils.dart';
import 'package:waternudge/utils/toast_utils.dart';
import 'package:waternudge/utils/unit_converter.dart';
import 'package:waternudge/values/onboarding_theme.dart';

import 'components/history_charts.dart';
import 'components/history_date_picker.dart';
import 'components/history_detail_section.dart';
import 'components/history_section.dart';
import 'components/week_widgets.dart';
import 'components/month_widgets.dart';
import 'components/year_widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  /// The detail list starts collapsed on the period tabs, as in the design.
  final RxBool _detailExpanded = false.obs;

  static const EdgeInsets _hPad = EdgeInsets.symmetric(horizontal: 16);

  // Week tab: scrolls the day-card row to the selected day whenever it's
  // built (entering the tab, changing week, or picking another day).
  final ScrollController _weekScrollController = ScrollController();
  final List<GlobalKey> _weekDayKeys = List.generate(7, (_) => GlobalKey());

  String? get _locale => Get.locale?.toString();

  @override
  void dispose() {
    _weekScrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedWeekDay(int index) {
    if (index < 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _weekDayKeys[index].currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HistoryController>();

    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(context, controller),
              const SizedBox(height: 14),
              Padding(
                padding: _hPad,
                child: Obx(() => _buildTabs(context, controller)),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Obx(() {
                  switch (controller.viewMode.value) {
                    case HistoryViewMode.day:
                      return _buildDayTab(context, controller);
                    case HistoryViewMode.week:
                      return _buildWeekTab(context, controller);
                    case HistoryViewMode.month:
                      return _buildMonthTab(context, controller);
                    case HistoryViewMode.year:
                      return _buildYearTab(context, controller);
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header & tabs ──────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, HistoryController controller) {
    final ob = OnboardingTheme.of(context);
    return Padding(
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
          // Reset to the current day/week/month/year — shown only when the user
          // has navigated away from it.
          Obx(
            () => controller.isCurrentPeriod
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _headerIconButton(
                      ob,
                      icon: Icons.restart_alt_rounded,
                      onTap: () {
                        controller.backToToday();
                        controller.selectedDate.refresh();
                      },
                    ),
                  ),
          ),
          // Single entry point for period navigation: opens the date picker to
          // jump to any day/week/month/year.
          _headerIconButton(
            ob,
            icon: Icons.calendar_month_rounded,
            onTap: () => _pickDate(context, controller),
          ),
        ],
      ),
    );
  }

  Widget _headerIconButton(
    OnboardingTheme ob, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Icon(icon, color: ob.textPrimary, size: 20),
        ),
      ),
    );
  }

  Widget _buildTabs(BuildContext context, HistoryController controller) {
    const modes = [
      (HistoryViewMode.day, 'day'),
      (HistoryViewMode.week, 'week'),
      (HistoryViewMode.month, 'month'),
      (HistoryViewMode.year, 'year'),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: modes.map((entry) {
          final isSelected = controller.viewMode.value == entry.$1;
          final raw = entry.$2.tr;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                _detailExpanded.value = false;
                controller.viewMode.value = entry.$1;
                Analytics.historyPeriodSelect(entry.$2);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF1575CE), Color(0xFF0B58D6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFF1575CE,
                            ).withValues(alpha: 0.40),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  raw.isEmpty ? raw : raw[0].toUpperCase() + raw.substring(1),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.60),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Day tab ────────────────────────────────────────────────────────────────

  Widget _buildDayTab(BuildContext context, HistoryController controller) {
    final ob = OnboardingTheme.of(context);
    final unit = Get.find<SettingsController>().volumeUnit.value;
    final goal = controller.dailyGoalMl;

    return ListView(
      key: const ValueKey('history_day'),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 132),
      children: [
        HistoryCard(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HistorySectionTitle('by_hour'.tr),
              const SizedBox(height: 10),
              DayHourlyChart(
                hourlyTotals: controller.hourlyTotals,
                isOz: unit == 'oz',
                dailyGoal: goal,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        HistoryDetailHeader(title: 'detail_history'.tr),
        const SizedBox(height: 12),
        if (controller.dayRecords.isEmpty)
          _buildEmptyState(ob)
        else
          for (final record in controller.dayRecords)
            RemovableRecordRow(
              key: ValueKey(
                'record-${record.id ?? record.timestamp.microsecondsSinceEpoch}',
              ),
              record: record,
              onEdit: () => _showEditDialog(context, controller, record),
              onDelete: () => controller.deleteRecord(record),
            ),
      ],
    );
  }

  // ── Week tab ───────────────────────────────────────────────────────────────

  Widget _buildWeekTab(BuildContext context, HistoryController controller) {
    final unit = Get.find<SettingsController>().volumeUnit.value;
    final isOz = unit == 'oz';
    final goal = controller.dailyGoalMl;
    final selected = controller.selectedDate.value;

    final dailyTotals = List<int>.filled(7, 0);
    for (final s in controller.summaries) {
      final dt = DateTime.tryParse(s.dateKey);
      if (dt == null) continue;
      dailyTotals[dt.weekday - 1] += s.totalMl;
    }

    final totalDrinkCount = controller.summaries.fold(
      0,
      (acc, s) => acc + s.drinkCount,
    );

    // Monday of the selected week
    final monday = selected.subtract(Duration(days: selected.weekday - 1));
    String dateKey(int offset) {
      final d = monday.add(Duration(days: offset));
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }

    final weekdays = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

    return ListView(
      key: const ValueKey('history_week'),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 132),
      children: [
        WeekChartCard(
          weekLabel: AppDateUtils.weekRange(selected),
          dailyTotals: dailyTotals,
          dailyGoal: goal,
          totalDrinkCount: totalDrinkCount,
          streak: controller.weekStreak,
          bestTimeRange: controller.bestTimeRange,
          isOz: isOz,
        ),
        const SizedBox(height: 20),
        HistorySectionTitle('history_current_week'.tr),
        const SizedBox(height: 8),
        const WeekStatusLegend(),
        const SizedBox(height: 12),
        Obx(() {
          final sel = controller.selectedDate.value;
          var selectedIndex = -1;
          for (var i = 0; i < 7; i++) {
            final d = monday.add(Duration(days: i));
            if (d.year == sel.year && d.month == sel.month && d.day == sel.day) {
              selectedIndex = i;
              break;
            }
          }
          _scrollToSelectedWeekDay(selectedIndex);

          return SingleChildScrollView(
            controller: _weekScrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < 7; i++) ...[
                  Builder(
                    builder: (ctx) {
                      final dk = dateKey(i);
                      final dayDate = monday.add(Duration(days: i));
                      final summary =
                          controller.summaries
                              .where((s) => s.dateKey == dk)
                              .firstOrNull ??
                          DailySummary(dateKey: dk, goalMl: goal);
                      final weekdayLabel = weekdays[i].tr;
                      final dateLabel = DateFormat(
                        'd MMM',
                        _locale,
                      ).format(dayDate);
                      return SizedBox(
                        key: _weekDayKeys[i],
                        width: 84,
                        child: WeekDayCard(
                          summary: summary,
                          weekdayLabel: weekdayLabel,
                          dateLabel: dateLabel,
                          isOz: isOz,
                          isSelected: i == selectedIndex,
                          onTap: () => controller.selectedDate.value = dayDate,
                        ),
                      );
                    },
                  ),
                  if (i < 6) const SizedBox(width: 8),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  // ── Month tab ──────────────────────────────────────────────────────────────

  Widget _buildMonthTab(BuildContext context, HistoryController controller) {
    final unit = Get.find<SettingsController>().volumeUnit.value;
    final isOz = unit == 'oz';
    final total = controller.computedTotal;
    final goal = controller.dailyGoalMl;
    final selected = controller.selectedDate.value;
    final daysInMonth = DateTime(selected.year, selected.month + 1, 0).day;

    final dailyTotals = List<int>.filled(daysInMonth, 0);
    for (final s in controller.summaries) {
      final dt = DateTime.tryParse(s.dateKey);
      if (dt == null || dt.month != selected.month) continue;
      dailyTotals[dt.day - 1] += s.totalMl;
    }

    final best = controller.maxDaySummary;
    final worst = controller.minDaySummary;

    return ListView(
      key: const ValueKey('history_month'),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 142),
      children: [
        MonthSummaryCard(
          title: 'history_overview_title'.tr,
          subtitle: AppDateUtils.monthLabel(selected),
          totalMl: total,
          monthGoalMl: goal * daysInMonth,
          avgPerDayMl: controller.avgPerDayMl,
          dailyGoalMl: goal,
          goalDaysCount: controller.goalDaysCount,
          daysInMonth: daysInMonth,
          isOz: isOz,
        ),
        const SizedBox(height: 14),
        MonthChartCard(
          dailyTotals: dailyTotals,
          dailyGoal: goal,
          maxMl: best?.totalMl ?? 0,
          minMl: worst?.totalMl ?? 0,
          avgPerDayMl: controller.avgPerDayMl,
          isOz: isOz,
        ),
        const SizedBox(height: 14),
        MonthCalendarGrid(
          year: selected.year,
          month: selected.month,
          dailyTotals: dailyTotals,
          dailyGoal: goal,
          selectedDay: selected.day,
          isOz: isOz,
        ),
      ],
    );
  }

  // ── Year tab ───────────────────────────────────────────────────────────────

  Widget _buildYearTab(BuildContext context, HistoryController controller) {
    final unit = Get.find<SettingsController>().volumeUnit.value;
    final isOz = unit == 'oz';
    final total = controller.computedTotal;
    final dailyGoal = controller.dailyGoalMl;
    final year = controller.selectedDate.value.year;
    final monthlyTotals = controller.monthlyTotals;

    final monthlyGoals = [
      for (var m = 1; m <= 12; m++) dailyGoal * DateTime(year, m + 1, 0).day,
    ];
    final yearGoal = monthlyGoals.reduce((a, b) => a + b);
    final daysInYear = DateTime(
      year + 1,
      1,
      1,
    ).difference(DateTime(year, 1, 1)).inDays;

    // Best / worst / average across months that actually have data.
    var maxMl = 0, minMl = 0, monthsWithData = 0;
    for (var m = 1; m <= 12; m++) {
      final v = monthlyTotals[m - 1];
      if (v <= 0) continue;
      monthsWithData++;
      if (v > maxMl) maxMl = v;
      if (minMl == 0 || v < minMl) minMl = v;
    }
    final avgPerMonth = monthsWithData > 0 ? total ~/ monthsWithData : 0;

    // Each month's completion percentage against that month's goal.
    final monthlyRates = [
      for (var m = 1; m <= 12; m++)
        monthlyGoals[m - 1] > 0
            ? (monthlyTotals[m - 1] / monthlyGoals[m - 1] * 100)
            : 0.0,
    ];

    return ListView(
      key: const ValueKey('history_year'),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 142),
      children: [
        MonthSummaryCard(
          title: 'history_overview_title'.tr,
          subtitle: '$year',
          totalMl: total,
          monthGoalMl: yearGoal,
          avgPerDayMl: controller.avgPerDayMl,
          dailyGoalMl: dailyGoal,
          goalDaysCount: controller.goalDaysCount,
          daysInMonth: daysInYear,
          isOz: isOz,
        ),
        const SizedBox(height: 14),
        YearVolumeCard(
          monthlyTotals: monthlyTotals,
          monthlyGoals: monthlyGoals,
          isFutureMonth: controller.isFutureMonth,
          goalLabel:
              'Mục tiêu ${UnitConverter.formatVolumeGrouped(monthlyGoals.first.toDouble(), unit)}',
          maxMl: maxMl,
          minMl: minMl,
          avgPerMonthMl: avgPerMonth,
          isOz: isOz,
        ),
        const SizedBox(height: 14),
        YearGoalRateCard(monthlyRates: monthlyRates, targetPct: 75),
      ],
    );
  }

  // ── Shared pieces ──────────────────────────────────────────────────────────

  Widget _buildEmptyState(OnboardingTheme ob) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon('assets/images/webp/img_not_found_history.webp', size: 90),
          const SizedBox(height: 12),
          Text(
            'no_records_found'.tr,
            style: TextStyle(
              fontSize: 14,
              color: ob.textPrimary.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _pickDate(BuildContext context, HistoryController controller) {
    HistoryDatePicker.show(
      context,
      initialDate: controller.selectedDate.value,
      lastDate: DateTime.now(),
      mode: controller.viewMode.value,
    ).then((picked) {
      if (picked != null) {
        // Force a reload even when the picked date equals the current one —
        // GetX skips notifying on same-value assignment, which otherwise made
        // "Apply" appear dead until a different date was chosen.
        controller.selectedDate.value = picked;
        controller.selectedDate.refresh();
      }
    });
  }

  // ── Edit dialog ────────────────────────────────────────────────────────────

  void _showEditDialog(
    BuildContext context,
    HistoryController controller,
    DrinkRecord record,
  ) {
    final volumeUnit = Get.find<SettingsController>().volumeUnit.value;
    final isOz = volumeUnit == 'oz';
    // Show the artwork of whatever drink this record is, matching the list row.
    final drinkType = DrinkType.values.firstWhere(
      (t) => t.name == record.drinkType,
      orElse: () => DrinkType.water,
    );
    final displayMl = record.originalAmountMl > 0
        ? record.originalAmountMl
        : record.amountMl.toDouble();
    final textController = TextEditingController(
      text: UnitConverter.formatVolumeValue(displayMl, volumeUnit),
    );
    final focusNode = FocusNode();

    Future.delayed(
      const Duration(milliseconds: 150),
      () => focusNode.requestFocus(),
    );

    PrimaryDialog.show(
      context: context,
      content: StatefulBuilder(
        builder: (ctx, setState) {
          final ob = OnboardingTheme.of(ctx);
          final double sliderMax = isOz ? 101 : 3000;
          final String sliderMaxLabel = isOz ? '101' : '3000';
          return AppColumn(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  AppText(
                    'edit_drink'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ob.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ob.bgToggle,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: ob.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const AppSpacerH(20),
              AppRow(
                modifier: Modifier.background(
                  color: ob.bgToggle,
                  radius: 14,
                ).padding(horizontal: 16, vertical: 4),
                children: [
                  Image.asset(
                    drinkType.imagePath,
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                  const AppSpacerW(10),
                  Container(
                    width: 1,
                    height: 24,
                    color: ob.textSecondary.withValues(alpha: 0.3),
                  ),
                  const AppSpacerW(10),
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
                      onChanged: (v) {
                        // Cap typed values at the same ceiling as the slider.
                        final parsed = double.tryParse(v);
                        if (parsed != null && parsed > sliderMax) {
                          final capped = sliderMax.round().toString();
                          textController.value = TextEditingValue(
                            text: capped,
                            selection: TextSelection.collapsed(
                              offset: capped.length,
                            ),
                          );
                        }
                        setState(() {});
                      },
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
              const AppSpacerH(16),
              Row(
                children: [
                  AppText(
                    '0',
                    style: TextStyle(color: ob.textSecondary, fontSize: 12),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(ctx).copyWith(
                        trackHeight: 4,
                        activeTrackColor: ob.switchActive,
                        inactiveTrackColor: ob.switchActive.withValues(
                          alpha: 0.2,
                        ),
                        thumbColor: ob.switchActive,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 10,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 18,
                        ),
                      ),
                      child: Slider(
                        min: 0,
                        max: sliderMax,
                        value: (double.tryParse(textController.text) ?? 0).clamp(
                          0,
                          sliderMax,
                        ),
                        onChanged: (v) {
                          setState(() {
                            textController.text = isOz
                                ? v.toStringAsFixed(1)
                                : v.round().toString();
                          });
                        },
                      ),
                    ),
                  ),
                  AppText(
                    sliderMaxLabel,
                    style: TextStyle(color: ob.textSecondary, fontSize: 12),
                  ),
                ],
              ),
              const AppSpacerH(24),
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
                        if (val == null || val <= 0) return;
                        Navigator.pop(ctx);

                        final type = DrinkType.values.firstWhere(
                          (t) => t.name == record.drinkType,
                          orElse: () => DrinkType.water,
                        );
                        final valInMl = isOz ? UnitConverter.ozToMl(val) : val;
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
