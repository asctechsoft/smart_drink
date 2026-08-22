import 'package:dsp_base/app_material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smartdrinkai/controller/history_controller.dart';
import 'package:smartdrinkai/controller/settings_controller.dart';
import 'package:smartdrinkai/controller/today_controller.dart';
import 'package:smartdrinkai/models/data_models/daily_summary.dart';
import 'package:smartdrinkai/models/data_models/drink_record.dart';
import 'package:smartdrinkai/models/ui_models/drink_type.dart';
import 'package:smartdrinkai/presentation/common_components/onboarding_background.dart';
import 'package:smartdrinkai/presentation/common_components/primary_button.dart';
import 'package:smartdrinkai/presentation/common_components/primary_dialog.dart';
import 'package:smartdrinkai/utils/date_utils.dart';
import 'package:smartdrinkai/utils/toast_utils.dart';
import 'package:smartdrinkai/utils/unit_converter.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';

import 'components/history_charts.dart';
import 'components/history_date_picker.dart';
import 'components/history_detail_section.dart';
import 'components/history_nav_bar.dart';
import 'components/history_section.dart';
import 'components/day_progress_card.dart';
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

  String? get _locale => Get.locale?.toString();

  @override
  Widget build(BuildContext context) {
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
          // Jumps the whole screen back to the current period; the date picker
          // lives on the label in the nav bar below.
          GestureDetector(
            onTap: controller.backToToday,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Icon(
                Icons.calendar_month_rounded,
                color: ob.textPrimary,
                size: 20,
              ),
            ),
          ),
        ],
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
    final total = controller.computedTotal;
    final goal = controller.dailyGoalMl;
    final progress = goal > 0 ? (total / goal).clamp(0.0, 1.0) : 0.0;
    final selected = controller.selectedDate.value;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      children: [
        DayProgressCard(
          totalLabel: UnitConverter.formatVolumeValue(total.toDouble(), unit),
          goalLabel: UnitConverter.formatVolumeValue(goal.toDouble(), unit),
          unit: unit,
          progress: progress,
          dateLabel: DateFormat('d MMMM, y', _locale).format(selected),
          drinkCount: controller.dayDrinkCount,
          lastDrinkTime: controller.lastDrinkTime,
        ),
        const SizedBox(height: 14),
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
          for (final record in controller.dayRecords) ...[
            DrinkRecordRow(
              record: record,
              onEdit: () => _showEditDialog(context, controller, record),
              onDelete: () => controller.deleteRecord(record),
            ),
            const SizedBox(height: 8),
          ],
      ],
    );
  }

  // ── Week tab ───────────────────────────────────────────────────────────────

  Widget _buildWeekTab(BuildContext context, HistoryController controller) {
    final unit = Get.find<SettingsController>().volumeUnit.value;
    final isOz = unit == 'oz';
    final total = controller.computedTotal;
    final goal = controller.dailyGoalMl;
    final selected = controller.selectedDate.value;

    final dailyTotals = List<int>.filled(7, 0);
    for (final s in controller.summaries) {
      final dt = DateTime.tryParse(s.dateKey);
      if (dt == null) continue;
      dailyTotals[dt.weekday - 1] += s.totalMl;
    }

    final totalDrinkCount =
        controller.summaries.fold(0, (acc, s) => acc + s.drinkCount);

    final best = controller.maxDaySummary;
    final bestDayLabel =
        best == null ? '--' : _formatDate(best.dateKey, 'EEE');

    // Monday of the selected week
    final monday = selected.subtract(Duration(days: selected.weekday - 1));
    String dateKey(int offset) {
      final d = monday.add(Duration(days: offset));
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }

    final weekdays = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      children: [
        WeekOverviewCard(
          weekLabel: AppDateUtils.weekRange(selected),
          totalMl: total,
          weekGoalMl: goal * 7,
          avgPerDayMl: controller.avgPerDayMl,
          goalDaysCount: controller.goalDaysCount,
          bestDayLabel: bestDayLabel,
          isOz: isOz,
        ),
        const SizedBox(height: 14),
        WeekChartCard(
          dailyTotals: dailyTotals,
          dailyGoal: goal,
          totalDrinkCount: totalDrinkCount,
          streak: 0,
          isOz: isOz,
        ),
        const SizedBox(height: 20),
        HistorySectionTitle('detail_history'.tr),
        const SizedBox(height: 12),
        for (var i = 0; i < 7; i++) ...[
          Builder(builder: (ctx) {
            final dk = dateKey(i);
            final dayDate = monday.add(Duration(days: i));
            final summary = controller.summaries
                    .where((s) => s.dateKey == dk)
                    .firstOrNull ??
                DailySummary(dateKey: dk, goalMl: goal);
            final weekdayLabel = weekdays[i].tr;
            final dateLabel =
                DateFormat('d MMMM', _locale).format(dayDate);
            return WeekDayRow(
              summary: summary,
              weekdayLabel: weekdayLabel,
              dateLabel: dateLabel,
              isOz: isOz,
            );
          }),
          const SizedBox(height: 8),
        ],
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

    // Most recent day that has any intake, used for the "last drink" stat.
    DateTime? lastDrink;
    for (final s in controller.summaries) {
      if (s.totalMl <= 0) continue;
      if (lastDrink == null || s.updatedAt.isAfter(lastDrink)) {
        lastDrink = s.updatedAt;
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      children: [
        HistoryNavBar(
          label: AppDateUtils.monthLabel(selected),
          onPrevious: controller.previousPeriod,
          onNext: controller.nextPeriod,
          canGoNext: controller.canGoNext,
          trailingIcon: Icons.keyboard_arrow_down_rounded,
          onLabelTap: () => _pickDate(context, controller),
        ),
        const SizedBox(height: 12),
        MonthSummaryCard(
          totalMl: total,
          monthGoalMl: goal * daysInMonth,
          avgPerDayMl: controller.avgPerDayMl,
          dailyGoalMl: goal,
          goalDaysCount: controller.goalDaysCount,
          daysInMonth: daysInMonth,
          lastDrink: lastDrink,
          isOz: isOz,
        ),
        const SizedBox(height: 14),
        MonthChartCard(
          dailyTotals: dailyTotals,
          dailyGoal: goal,
          maxMl: best?.totalMl ?? 0,
          maxDayLabel: best == null ? '--' : _formatDate(best.dateKey, 'd MMMM'),
          minMl: worst?.totalMl ?? 0,
          minDayLabel:
              worst == null ? '--' : _formatDate(worst.dateKey, 'd MMMM'),
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
    final daysInYear =
        DateTime(year + 1, 1, 1).difference(DateTime(year, 1, 1)).inDays;

    // Best / worst / average across months that actually have data.
    var maxMl = 0, minMl = 0, maxMonth = 0, minMonth = 0, monthsWithData = 0;
    for (var m = 1; m <= 12; m++) {
      final v = monthlyTotals[m - 1];
      if (v <= 0) continue;
      monthsWithData++;
      if (v > maxMl) {
        maxMl = v;
        maxMonth = m;
      }
      if (minMl == 0 || v < minMl) {
        minMl = v;
        minMonth = m;
      }
    }
    final avgPerMonth = monthsWithData > 0 ? total ~/ monthsWithData : 0;

    // Each month's completion percentage against that month's goal.
    final monthlyRates = [
      for (var m = 1; m <= 12; m++)
        monthlyGoals[m - 1] > 0
            ? (monthlyTotals[m - 1] / monthlyGoals[m - 1] * 100)
            : 0.0,
    ];

    // Most recent day with intake, for the "last drink" stat.
    DateTime? lastDrink;
    for (final s in controller.summaries) {
      if (s.totalMl <= 0) continue;
      if (lastDrink == null || s.updatedAt.isAfter(lastDrink)) {
        lastDrink = s.updatedAt;
      }
    }

    String monthLabel(int m) =>
        'Tháng $m'; // TODO: dịch sau

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      children: [
        HistoryNavBar(
          label: '$year',
          onPrevious: controller.previousPeriod,
          onNext: controller.nextPeriod,
          canGoNext: controller.canGoNext,
          trailingIcon: Icons.keyboard_arrow_down_rounded,
          onLabelTap: () => _pickDate(context, controller),
        ),
        const SizedBox(height: 12),
        MonthSummaryCard(
          totalMl: total,
          monthGoalMl: yearGoal,
          avgPerDayMl: controller.avgPerDayMl,
          dailyGoalMl: dailyGoal,
          goalDaysCount: controller.goalDaysCount,
          daysInMonth: daysInYear,
          lastDrink: lastDrink,
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
          maxMonthLabel: maxMonth > 0 ? monthLabel(maxMonth) : '--',
          minMl: minMl,
          minMonthLabel: minMonth > 0 ? monthLabel(minMonth) : '--',
          avgPerMonthMl: avgPerMonth,
          isOz: isOz,
        ),
        const SizedBox(height: 14),
        YearGoalRateCard(
          monthlyRates: monthlyRates,
          targetPct: 75,
        ),
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
          AppIcon('assets/images/svg/ic_no_record.svg', size: 80),
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

  String _formatDate(String dateKey, String pattern) {
    final dt = DateTime.tryParse(dateKey);
    if (dt == null) return dateKey;
    return DateFormat(pattern, _locale).format(dt);
  }

  void _pickDate(BuildContext context, HistoryController controller) {
    HistoryDatePicker.show(
      context,
      initialDate: controller.selectedDate.value,
      lastDate: DateTime.now(),
    ).then((picked) {
      if (picked != null) controller.selectedDate.value = picked;
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
