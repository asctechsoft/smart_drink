import 'package:smartdrinkai/controller/today_controller.dart';
import 'package:smartdrinkai/models/data_models/daily_summary.dart';
import 'package:smartdrinkai/models/data_models/drink_record.dart';
import 'package:smartdrinkai/services/application/drink_data_service.dart';
import 'package:smartdrinkai/utils/date_utils.dart';
import 'package:get/get.dart';
import 'user_profile_controller.dart';

enum HistoryViewMode { day, week, month }

class HistoryController extends GetxController {
  final DrinkDataService _drinkService = DrinkDataService();

  final Rx<HistoryViewMode> viewMode = HistoryViewMode.day.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxList<DrinkRecord> dayRecords = <DrinkRecord>[].obs;
  final RxList<DailySummary> summaries = <DailySummary>[].obs;
  final RxInt totalMl = 0.obs;
  final RxInt goalMl = 2000.obs;

  /// Computed total that always matches what the chart displays.
  /// For week/month views it sums from [summaries]; for day view from [dayRecords].
  int get computedTotal {
    switch (viewMode.value) {
      case HistoryViewMode.day:
        return dayRecords.fold(0, (sum, r) => sum + r.amountMl);
      case HistoryViewMode.week:
      case HistoryViewMode.month:
        return summaries.fold(0, (sum, s) => sum + s.totalMl);
    }
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
    }
  }

  Future<void> _loadDayData() async {
    final dateKey = AppDateUtils.formatDateKey(selectedDate.value);
    final records = await _drinkService.getRecordsByDate(dateKey);
    dayRecords.assignAll(records);
    totalMl.value = records.fold(0, (sum, r) => sum + r.amountMl);
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

  void previousPeriod() {
    switch (viewMode.value) {
      case HistoryViewMode.day:
        selectedDate.value = selectedDate.value.subtract(
          const Duration(days: 1),
        );
      case HistoryViewMode.week:
        selectedDate.value = selectedDate.value.subtract(
          const Duration(days: 7),
        );
      case HistoryViewMode.month:
        selectedDate.value = DateTime(
          selectedDate.value.year,
          selectedDate.value.month - 1,
          1,
        );
    }
  }

  void nextPeriod() {
    switch (viewMode.value) {
      case HistoryViewMode.day:
        selectedDate.value = selectedDate.value.add(const Duration(days: 1));
      case HistoryViewMode.week:
        selectedDate.value = selectedDate.value.add(const Duration(days: 7));
      case HistoryViewMode.month:
        selectedDate.value = DateTime(
          selectedDate.value.year,
          selectedDate.value.month + 1,
          1,
        );
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
    final mode = viewMode.value;
    switch (mode) {
      case HistoryViewMode.day:
        return DateTime(
          sel.year,
          sel.month,
          sel.day,
        ).isBefore(DateTime(now.year, now.month, now.day));
      case HistoryViewMode.week:
        final selWeek = AppDateUtils.startOfWeek(sel);
        final nowWeek = AppDateUtils.startOfWeek(now);
        return DateTime(
          selWeek.year,
          selWeek.month,
          selWeek.day,
        ).isBefore(DateTime(nowWeek.year, nowWeek.month, nowWeek.day));
      case HistoryViewMode.month:
        return DateTime(
          sel.year,
          sel.month,
          1,
        ).isBefore(DateTime(now.year, now.month, 1));
    }
  }

  String get periodLabel {
    switch (viewMode.value) {
      case HistoryViewMode.day:
        final now = DateTime.now();
        final sel = selectedDate.value;
        if (sel.year == now.year &&
            sel.month == now.month &&
            sel.day == now.day) {
          return 'today';
        }
        return AppDateUtils.formatDateKey(selectedDate.value);
      case HistoryViewMode.week:
        return AppDateUtils.weekRange(selectedDate.value);
      case HistoryViewMode.month:
        return AppDateUtils.monthLabel(selectedDate.value);
    }
  }
}

