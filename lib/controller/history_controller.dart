import 'package:smartdrinkai/controller/today_controller.dart';
import 'package:smartdrinkai/models/data_models/daily_summary.dart';
import 'package:smartdrinkai/models/data_models/drink_record.dart';
import 'package:smartdrinkai/services/application/drink_data_service.dart';
import 'package:smartdrinkai/utils/date_utils.dart';
import 'package:get/get.dart';
import 'user_profile_controller.dart';

enum HistoryViewMode { day, week, month, year }

class HistoryController extends GetxController {
  final DrinkDataService _drinkService = DrinkDataService();

  final Rx<HistoryViewMode> viewMode = HistoryViewMode.day.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxList<DrinkRecord> dayRecords = <DrinkRecord>[].obs;
  final RxList<DailySummary> summaries = <DailySummary>[].obs;
  final RxList<DailySummary> weekSummariesForDay = <DailySummary>[].obs;
  final RxInt totalMl = 0.obs;
  final RxInt goalMl = 2000.obs;

  int get computedTotal {
    switch (viewMode.value) {
      case HistoryViewMode.day:
        return dayRecords.fold(0, (sum, r) => sum + r.amountMl);
      case HistoryViewMode.week:
      case HistoryViewMode.month:
      case HistoryViewMode.year:
        return summaries.fold(0, (sum, s) => sum + s.totalMl);
    }
  }

  int get avgPerDayMl {
    if (summaries.isEmpty) return 0;
    final total = summaries.fold(0, (sum, s) => sum + s.totalMl);
    return (total / summaries.length).round();
  }

  int get goalDaysCount {
    return summaries.where((s) => s.goalMl > 0 && s.totalMl >= s.goalMl).length;
  }

  int get periodDayCount {
    switch (viewMode.value) {
      case HistoryViewMode.day:
        return 1;
      case HistoryViewMode.week:
        return 7;
      case HistoryViewMode.month:
        final dt = selectedDate.value;
        return DateTime(dt.year, dt.month + 1, 0).day;
      case HistoryViewMode.year:
        final dt = selectedDate.value;
        return DateTime(dt.year + 1, 1, 1).difference(DateTime(dt.year, 1, 1)).inDays;
    }
  }

  int get dayViewGoalDays =>
      weekSummariesForDay.where((s) => s.goalMl > 0 && s.totalMl >= s.goalMl).length;

  DailySummary? get dayViewMaxSummary {
    final nonZero = weekSummariesForDay.where((s) => s.totalMl > 0).toList();
    if (nonZero.isEmpty) return null;
    return nonZero.reduce((a, b) => a.totalMl >= b.totalMl ? a : b);
  }

  DailySummary? get dayViewMinSummary {
    final nonZero = weekSummariesForDay.where((s) => s.totalMl > 0).toList();
    if (nonZero.isEmpty) return null;
    return nonZero.reduce((a, b) => a.totalMl <= b.totalMl ? a : b);
  }

  DailySummary? get maxDaySummary {
    if (summaries.isEmpty) return null;
    final nonZero = summaries.where((s) => s.totalMl > 0).toList();
    if (nonZero.isEmpty) return null;
    return nonZero.reduce((a, b) => a.totalMl >= b.totalMl ? a : b);
  }

  DailySummary? get minDaySummary {
    if (summaries.isEmpty) return null;
    final nonZero = summaries.where((s) => s.totalMl > 0).toList();
    if (nonZero.isEmpty) return null;
    return nonZero.reduce((a, b) => a.totalMl <= b.totalMl ? a : b);
  }

  Worker? _viewModeWorker;
  Worker? _dateWorker;

  @override
  void onInit() {
    super.onInit();
    loadData();
    _viewModeWorker = debounce(
      viewMode,
      (_) => loadData(),
      time: const Duration(milliseconds: 150),
    );
    _dateWorker = debounce(
      selectedDate,
      (_) => loadData(),
      time: const Duration(milliseconds: 150),
    );
  }

  @override
  void onClose() {
    _viewModeWorker?.dispose();
    _dateWorker?.dispose();
    super.onClose();
  }

  Future<void> loadData() async {
    final profileCtrl = Get.find<UserProfileController>();
    final dailyGoal = profileCtrl.profile.value.dailyGoalMl;

    switch (viewMode.value) {
      case HistoryViewMode.day:
        goalMl.value = dailyGoal;
        await _loadDayData();
      case HistoryViewMode.week:
        goalMl.value = dailyGoal * 7;
        await _loadWeekData();
      case HistoryViewMode.month:
        final dt = selectedDate.value;
        final daysInMonth = DateTime(dt.year, dt.month + 1, 0).day;
        goalMl.value = dailyGoal * daysInMonth;
        await _loadMonthData();
      case HistoryViewMode.year:
        final dt = selectedDate.value;
        final daysInYear = DateTime(dt.year + 1, 1, 1).difference(DateTime(dt.year, 1, 1)).inDays;
        goalMl.value = dailyGoal * daysInYear;
        await _loadYearData();
    }
  }

  Future<void> _loadDayData() async {
    final dateKey = AppDateUtils.formatDateKey(selectedDate.value);
    final records = await _drinkService.getRecordsByDate(dateKey);
    dayRecords.assignAll(records);
    totalMl.value = records.fold(0, (sum, r) => sum + r.amountMl);

    final weekStart = AppDateUtils.startOfWeek(selectedDate.value);
    final weekEnd = AppDateUtils.endOfWeek(selectedDate.value);
    final weekData = await _drinkService.getSummariesBetween(
      AppDateUtils.formatDateKey(weekStart),
      AppDateUtils.formatDateKey(weekEnd),
    );
    weekSummariesForDay.assignAll(weekData);
  }

  Future<void> _loadWeekData() async {
    final start = AppDateUtils.startOfWeek(selectedDate.value);
    final end = AppDateUtils.endOfWeek(selectedDate.value);
    final data = await _drinkService.getSummariesBetween(
      AppDateUtils.formatDateKey(start),
      AppDateUtils.formatDateKey(end),
    );
    summaries.assignAll(data);
    totalMl.value = data.fold(0, (sum, s) => sum + s.totalMl);
  }

  Future<void> _loadMonthData() async {
    final start = AppDateUtils.startOfMonth(selectedDate.value);
    final end = AppDateUtils.endOfMonth(selectedDate.value);
    final data = await _drinkService.getSummariesBetween(
      AppDateUtils.formatDateKey(start),
      AppDateUtils.formatDateKey(end),
    );
    summaries.assignAll(data);
    totalMl.value = data.fold(0, (sum, s) => sum + s.totalMl);
  }

  Future<void> _loadYearData() async {
    final start = AppDateUtils.startOfYear(selectedDate.value);
    final end = AppDateUtils.endOfYear(selectedDate.value);
    final data = await _drinkService.getSummariesBetween(
      AppDateUtils.formatDateKey(start),
      AppDateUtils.formatDateKey(end),
    );
    summaries.assignAll(data);
    totalMl.value = data.fold(0, (sum, s) => sum + s.totalMl);
  }

  void previousPeriod() {
    switch (viewMode.value) {
      case HistoryViewMode.day:
        selectedDate.value = selectedDate.value.subtract(const Duration(days: 1));
      case HistoryViewMode.week:
        selectedDate.value = selectedDate.value.subtract(const Duration(days: 7));
      case HistoryViewMode.month:
        selectedDate.value = DateTime(selectedDate.value.year, selectedDate.value.month - 1, 1);
      case HistoryViewMode.year:
        selectedDate.value = DateTime(selectedDate.value.year - 1, 1, 1);
    }
  }

  void nextPeriod() {
    switch (viewMode.value) {
      case HistoryViewMode.day:
        selectedDate.value = selectedDate.value.add(const Duration(days: 1));
      case HistoryViewMode.week:
        selectedDate.value = selectedDate.value.add(const Duration(days: 7));
      case HistoryViewMode.month:
        selectedDate.value = DateTime(selectedDate.value.year, selectedDate.value.month + 1, 1);
      case HistoryViewMode.year:
        selectedDate.value = DateTime(selectedDate.value.year + 1, 1, 1);
    }
  }

  void backToToday() {
    selectedDate.value = DateTime.now();
  }

  Future<void> updateRecord(DrinkRecord record) async {
    await _drinkService.updateRecord(record, goalMl.value);
    await loadData();
    _refreshTodayIfNeeded(record.dateKey);
  }

  Future<void> deleteRecord(DrinkRecord record) async {
    await _drinkService.deleteRecord(record.id!, record.dateKey, goalMl.value);
    await loadData();
    _refreshTodayIfNeeded(record.dateKey);
  }

  void _refreshTodayIfNeeded(String dateKey) {
    final todayKey = AppDateUtils.formatDateKey(DateTime.now());
    if (dateKey == todayKey && Get.isRegistered<TodayController>()) {
      Get.find<TodayController>().loadTodayData();
    }
  }

  bool get canGoNext {
    final now = DateTime.now();
    final sel = selectedDate.value;
    switch (viewMode.value) {
      case HistoryViewMode.day:
        return DateTime(sel.year, sel.month, sel.day)
            .isBefore(DateTime(now.year, now.month, now.day));
      case HistoryViewMode.week:
        final selWeek = AppDateUtils.startOfWeek(sel);
        final nowWeek = AppDateUtils.startOfWeek(now);
        return DateTime(selWeek.year, selWeek.month, selWeek.day)
            .isBefore(DateTime(nowWeek.year, nowWeek.month, nowWeek.day));
      case HistoryViewMode.month:
        return DateTime(sel.year, sel.month, 1)
            .isBefore(DateTime(now.year, now.month, 1));
      case HistoryViewMode.year:
        return sel.year < now.year;
    }
  }

  String get periodLabel {
    switch (viewMode.value) {
      case HistoryViewMode.day:
        final now = DateTime.now();
        final sel = selectedDate.value;
        if (sel.year == now.year && sel.month == now.month && sel.day == now.day) {
          return 'today';
        }
        return AppDateUtils.formatDateKey(selectedDate.value);
      case HistoryViewMode.week:
        return AppDateUtils.weekRange(selectedDate.value);
      case HistoryViewMode.month:
        return AppDateUtils.monthLabel(selectedDate.value);
      case HistoryViewMode.year:
        return AppDateUtils.yearLabel(selectedDate.value);
    }
  }
}
