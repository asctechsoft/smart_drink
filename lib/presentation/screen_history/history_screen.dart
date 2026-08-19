import 'package:dsp_base/app_material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smartdrinkai/controller/history_controller.dart';
import 'package:smartdrinkai/controller/settings_controller.dart';
import 'package:smartdrinkai/controller/today_controller.dart';
import 'package:smartdrinkai/models/data_models/drink_record.dart';
import 'package:smartdrinkai/models/ui_models/drink_type.dart';
import 'package:smartdrinkai/presentation/common_components/onboarding_background.dart';
import 'package:smartdrinkai/presentation/common_components/primary_button.dart';
import 'package:smartdrinkai/presentation/common_components/primary_dialog.dart';
import 'package:smartdrinkai/presentation/screens_settings/settings_bottom_sheets.dart';
import 'package:smartdrinkai/utils/date_utils.dart';
import 'package:smartdrinkai/utils/toast_utils.dart';
import 'package:smartdrinkai/utils/unit_converter.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';

import 'components/history_charts.dart';
import 'components/history_date_picker.dart';
import 'components/history_detail_section.dart';
import 'components/history_nav_bar.dart';
import 'components/history_section.dart';
import 'components/history_summary_tiles.dart';
import 'components/day_progress_card.dart';
import 'components/period_overview_card.dart';

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
                color: ob.bgOption,
                border: Border.all(color: ob.borderTabHistory, width: 1),
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
    final ob = OnboardingTheme.of(context);
    const modes = [
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
                  color: isSelected ? ob.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  raw.isEmpty ? raw : raw[0].toUpperCase() + raw.substring(1),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? ob.textToggleActive : ob.textPrimary,
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
        HistoryNavBar(
          label: DateFormat('EEEE, d MMM, y', _locale).format(selected),
          onPrevious: controller.previousPeriod,
          onNext: controller.nextPeriod,
          canGoNext: controller.canGoNext,
          trailingIcon: Icons.calendar_today_rounded,
          onLabelTap: () => _pickDate(context, controller),
        ),
        const SizedBox(height: 12),
        DayProgressCard(
          totalLabel: UnitConverter.formatVolumeValue(total.toDouble(), unit),
          goalLabel: UnitConverter.formatVolumeValue(goal.toDouble(), unit),
          unit: unit,
          progress: progress,
        ),
        const SizedBox(height: 14),
        HistoryCard(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HistorySectionTitle('by_hour'.tr),
              const SizedBox(height: 10),
              DayHourlyChart(
                hourlyTotals: controller.hourlyTotals,
                isOz: unit == 'oz',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        HistorySectionTitle('day_summary'.tr),
        const SizedBox(height: 12),
        HistorySummaryTiles(
          tiles: [
            HistorySummaryTile(
              icon: Icons.water_drop_rounded,
              iconColor: ob.switchActive,
              value: UnitConverter.formatVolumeGrouped(total.toDouble(), unit),
              caption: 'total_volume'.tr,
            ),
            HistorySummaryTile(
              icon: Icons.star_rounded,
              iconColor: const Color(0xFFFACA1F),
              value: '${controller.dayDrinkCount} ${'unit_times'.tr}',
              caption: 'drink_count'.tr,
            ),
            HistorySummaryTile(
              icon: Icons.track_changes_rounded,
              iconColor: const Color(0xFF4ADE80),
              value: UnitConverter.formatVolumeGrouped(goal.toDouble(), unit),
              caption: 'goal'.tr,
            ),
          ],
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
    final ob = OnboardingTheme.of(context);
    final unit = Get.find<SettingsController>().volumeUnit.value;
    final total = controller.computedTotal;
    final goal = controller.dailyGoalMl;

    // Seven slots, Monday first, so an untracked day still holds its place.
    final dailyTotals = List<int>.filled(7, 0);
    for (final s in controller.summaries) {
      final dt = DateTime.tryParse(s.dateKey);
      if (dt == null) continue;
      dailyTotals[dt.weekday - 1] += s.totalMl;
    }

    final best = controller.maxDaySummary;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      children: [
        HistoryNavBar(
          label: AppDateUtils.weekRange(controller.selectedDate.value),
          onPrevious: controller.previousPeriod,
          onNext: controller.nextPeriod,
          canGoNext: controller.canGoNext,
        ),
        const SizedBox(height: 12),
        PeriodOverviewCard(
          totalLabel: 'week_total'.tr,
          totalValue: UnitConverter.formatVolumeGrouped(
            total.toDouble(),
            unit,
          ),
          averageLine: 'avg_per_day_value'.trParams({
            'args1': UnitConverter.formatVolumeGrouped(
              controller.avgPerDayMl.toDouble(),
              unit,
            ),
          }),
          goalValue: UnitConverter.formatVolumeValueUnit(goal.toDouble(), unit),
          onEditGoal: () => showDailyGoalSheet(context),
          chart: WeekBarChart(
            dailyTotals: dailyTotals,
            dailyGoal: goal,
            isOz: unit == 'oz',
          ),
        ),
        const SizedBox(height: 20),
        HistorySectionTitle('week_summary'.tr),
        const SizedBox(height: 12),
        _buildPeriodTiles(
          context,
          total: total,
          unit: unit,
          goalReached: '${controller.goalDaysCount}/7 ${'unit_days'.tr}',
          average: controller.avgPerDayMl,
        ),
        const SizedBox(height: 20),
        HistorySectionTitle('best_day'.tr),
        const SizedBox(height: 12),
        HistoryHighlightCard(
          label: best == null
              ? '--'
              : _formatDate(best.dateKey, 'EEEE'),
          value: best == null
              ? '--'
              : UnitConverter.formatVolumeGrouped(
                  best.totalMl.toDouble(),
                  unit,
                ),
        ),
        const SizedBox(height: 20),
        ..._buildCollapsibleDetail(
          context,
          rows: _dailyRows(controller),
          emptyState: _buildEmptyState(ob),
        ),
      ],
    );
  }

  // ── Month tab ──────────────────────────────────────────────────────────────

  Widget _buildMonthTab(BuildContext context, HistoryController controller) {
    final ob = OnboardingTheme.of(context);
    final unit = Get.find<SettingsController>().volumeUnit.value;
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
        PeriodOverviewCard(
          totalLabel: 'month_total'.tr,
          totalValue: UnitConverter.formatVolumeGrouped(
            total.toDouble(),
            unit,
          ),
          averageLine: 'avg_per_day_value'.trParams({
            'args1': UnitConverter.formatVolumeGrouped(
              controller.avgPerDayMl.toDouble(),
              unit,
            ),
          }),
          goalValue: UnitConverter.formatVolumeValueUnit(goal.toDouble(), unit),
          onEditGoal: () => showDailyGoalSheet(context),
          chart: MonthLineChart(
            dailyTotals: dailyTotals,
            dailyGoal: goal,
            isOz: unit == 'oz',
          ),
        ),
        const SizedBox(height: 20),
        HistorySectionTitle('month_summary'.tr),
        const SizedBox(height: 12),
        _buildPeriodTiles(
          context,
          total: total,
          unit: unit,
          goalReached:
              '${controller.goalDaysCount}/$daysInMonth ${'unit_days'.tr}',
          average: controller.avgPerDayMl,
        ),
        const SizedBox(height: 20),
        HistorySectionTitle('best_day'.tr),
        const SizedBox(height: 12),
        HistoryHighlightCard(
          label: best == null ? '--' : _formatDate(best.dateKey, 'd MMMM'),
          value: best == null
              ? '--'
              : UnitConverter.formatVolumeGrouped(
                  best.totalMl.toDouble(),
                  unit,
                ),
        ),
        const SizedBox(height: 20),
        ..._buildCollapsibleDetail(
          context,
          rows: _dailyRows(controller),
          emptyState: _buildEmptyState(ob),
        ),
      ],
    );
  }

  // ── Year tab ───────────────────────────────────────────────────────────────

  Widget _buildYearTab(BuildContext context, HistoryController controller) {
    final ob = OnboardingTheme.of(context);
    final unit = Get.find<SettingsController>().volumeUnit.value;
    final total = controller.computedTotal;
    final dailyGoal = controller.dailyGoalMl;
    final year = controller.selectedDate.value.year;
    final monthlyTotals = controller.monthlyTotals;

    final monthlyGoals = [
      for (var m = 1; m <= 12; m++) dailyGoal * DateTime(year, m + 1, 0).day,
    ];
    final yearGoal = monthlyGoals.reduce((a, b) => a + b);

    final best = controller.bestMonth;

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
        PeriodOverviewCard(
          totalLabel: 'year_total'.tr,
          totalValue: UnitConverter.formatVolumeGrouped(
            total.toDouble(),
            unit,
          ),
          averageLine: 'avg_per_day_value'.trParams({
            'args1': UnitConverter.formatVolumeGrouped(
              controller.avgPerDayMl.toDouble(),
              unit,
            ),
          }),
          goalValue: UnitConverter.formatVolumeValueUnit(
            dailyGoal.toDouble(),
            unit,
          ),
          onEditGoal: () => showDailyGoalSheet(context),
          chart: YearBarChart(
            monthlyTotals: monthlyTotals,
            monthlyGoals: monthlyGoals,
            isFutureMonth: controller.isFutureMonth,
            goalLabel: 'goal_with_value'.trParams({
              'args1': UnitConverter.formatVolumeGrouped(
                yearGoal.toDouble(),
                unit,
              ),
            }),
            isOz: unit == 'oz',
          ),
        ),
        const SizedBox(height: 20),
        HistorySectionTitle('year_summary'.tr),
        const SizedBox(height: 12),
        _buildPeriodTiles(
          context,
          total: total,
          unit: unit,
          goalReached:
              '${controller.goalMonthsCount}/12 ${'unit_months'.tr}',
          average: controller.avgPerDayMl,
        ),
        const SizedBox(height: 20),
        HistorySectionTitle('best_month'.tr),
        const SizedBox(height: 12),
        HistoryHighlightCard(
          label: best == null
              ? '--'
              : DateFormat('MMMM', _locale).format(DateTime(year, best.key)),
          value: best == null
              ? '--'
              : UnitConverter.formatVolumeGrouped(
                  best.value.toDouble(),
                  unit,
                ),
        ),
        const SizedBox(height: 20),
        ..._buildCollapsibleDetail(
          context,
          rows: [
            for (var m = 1; m <= 12; m++)
              if (monthlyTotals[m - 1] > 0)
                PeriodSummaryRow(
                  label: DateFormat(
                    'MMMM',
                    _locale,
                  ).format(DateTime(year, m)),
                  totalMl: monthlyTotals[m - 1],
                  goalMl: monthlyGoals[m - 1],
                ),
          ],
          emptyState: _buildEmptyState(ob),
        ),
      ],
    );
  }

  // ── Shared pieces ──────────────────────────────────────────────────────────

  Widget _buildPeriodTiles(
    BuildContext context, {
    required int total,
    required String unit,
    required String goalReached,
    required int average,
  }) {
    final ob = OnboardingTheme.of(context);
    return HistorySummaryTiles(
      tiles: [
        HistorySummaryTile(
          icon: Icons.water_drop_rounded,
          iconColor: ob.switchActive,
          value: UnitConverter.formatVolumeGrouped(total.toDouble(), unit),
          caption: 'total_volume'.tr,
        ),
        HistorySummaryTile(
          icon: Icons.star_rounded,
          iconColor: const Color(0xFFFACA1F),
          value: goalReached,
          caption: 'goal_reached'.tr,
        ),
        HistorySummaryTile(
          icon: Icons.trending_up_rounded,
          iconColor: const Color(0xFF4ADE80),
          value: UnitConverter.formatVolumeGrouped(average.toDouble(), unit),
          caption: 'avg_per_day'.tr,
        ),
      ],
    );
  }

  List<PeriodSummaryRow> _dailyRows(HistoryController controller) {
    final sorted = controller.summaries.where((s) => s.totalMl > 0).toList()
      ..sort((a, b) => b.dateKey.compareTo(a.dateKey));
    return [
      for (final s in sorted)
        PeriodSummaryRow.fromSummary(s, controller.dailyGoalMl),
    ];
  }

  /// Heading plus the rows it hides, so the period tabs open with the summary
  /// visible rather than a long list.
  List<Widget> _buildCollapsibleDetail(
    BuildContext context, {
    required List<Widget> rows,
    required Widget emptyState,
  }) {
    final expanded = _detailExpanded.value;
    return [
      HistoryDetailHeader(
        title: 'detail_history'.tr,
        expanded: expanded,
        onToggle: () => _detailExpanded.value = !expanded,
      ),
      if (expanded) ...[
        const SizedBox(height: 12),
        if (rows.isEmpty)
          emptyState
        else
          for (final row in rows) ...[row, const SizedBox(height: 8)],
      ],
    ];
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
                        final valInMl = isOz
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

