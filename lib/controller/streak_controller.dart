import 'package:get/get.dart';
import 'package:smartdrinkai/models/data_models/daily_summary.dart';
import 'package:smartdrinkai/services/application/drink_data_service.dart';
import 'package:smartdrinkai/utils/date_utils.dart';

/// How a single calendar day scored against the daily goal.
enum DayStatus {
  /// Goal reached.
  tracked,

  /// Drank something, but stopped short of the goal.
  partial,

  /// Nothing logged.
  missed,
}

class StreakController extends GetxController {
  final DrinkDataService _drinkService = DrinkDataService();

  /// Milestones the header nudges the user toward.
  static const List<int> milestones = [3, 7, 14, 30, 60, 100, 365];

  /// `date_key` -> summary, for every day the user has ever logged.
  final RxMap<String, DailySummary> summaries = <String, DailySummary>{}.obs;

  final RxInt currentStreak = 0.obs;
  final RxInt longestStreak = 0.obs;
  final RxInt totalDaysTracked = 0.obs;
  final RxBool isLoading = true.obs;

  /// Month currently shown by the calendar (always the 1st of that month).
  final Rx<DateTime> visibleMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  ).obs;

  @override
  void onInit() {
    super.onInit();
    loadStreakData();
  }

  Future<void> loadStreakData() async {
    isLoading.value = true;
    try {
      // Wide enough to cover any realistic history while staying a single query.
      final now = DateTime.now();
      final start = DateTime(now.year - 5, 1, 1);
      final end = DateTime(now.year + 1, 12, 31);

      final list = await _drinkService.getSummariesBetween(
        AppDateUtils.formatDateKey(start),
        AppDateUtils.formatDateKey(end),
      );

      final map = <String, DailySummary>{};
      for (final s in list) {
        if (s.totalMl > 0) map[s.dateKey] = s;
      }
      summaries.assignAll(map);

      totalDaysTracked.value = map.length;
      currentStreak.value = _computeCurrentStreak(map);
      longestStreak.value = _computeLongestStreak(map);
    } finally {
      isLoading.value = false;
    }
  }

  /// A day counts toward the streak once anything is logged for it.
  bool _isStreakDay(Map<String, DailySummary> map, DateTime day) =>
      map.containsKey(AppDateUtils.formatDateKey(day));

  int _computeCurrentStreak(Map<String, DailySummary> map) {
    final today = DateTime.now();
    var cursor = DateTime(today.year, today.month, today.day);

    // Today not being logged yet shouldn't break a streak that is still alive
    // from yesterday — start counting from yesterday in that case.
    if (!_isStreakDay(map, cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
      if (!_isStreakDay(map, cursor)) return 0;
    }

    var streak = 0;
    while (_isStreakDay(map, cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int _computeLongestStreak(Map<String, DailySummary> map) {
    if (map.isEmpty) return 0;

    final days = map.keys.map(AppDateUtils.parseDateKey).toList()..sort();

    var longest = 1;
    var run = 1;
    for (var i = 1; i < days.length; i++) {
      final diff = days[i].difference(days[i - 1]).inDays;
      run = diff == 1 ? run + 1 : 1;
      if (run > longest) longest = run;
    }
    return longest;
  }

  DayStatus statusOf(DateTime day) {
    final summary = summaries[AppDateUtils.formatDateKey(day)];
    if (summary == null || summary.totalMl <= 0) return DayStatus.missed;
    final goal = summary.goalMl > 0 ? summary.goalMl : 2000;
    return summary.totalMl >= goal ? DayStatus.tracked : DayStatus.partial;
  }

  /// Next milestone above the current streak, or `null` once all are passed.
  int? get nextMilestone {
    for (final m in milestones) {
      if (m > currentStreak.value) return m;
    }
    return null;
  }

  int get daysToNextMilestone {
    final next = nextMilestone;
    return next == null ? 0 : next - currentStreak.value;
  }

  /// Days in the current week (Mon–Sun) where the goal was reached.
  int get goalDaysThisWeek {
    final monday = AppDateUtils.startOfWeek(DateTime.now());
    var count = 0;
    for (var i = 0; i < 7; i++) {
      if (statusOf(monday.add(Duration(days: i))) == DayStatus.tracked) count++;
    }
    return count;
  }

  double get weekProgress => goalDaysThisWeek / 7;

  void previousMonth() {
    final m = visibleMonth.value;
    visibleMonth.value = DateTime(m.year, m.month - 1);
  }

  void nextMonth() {
    final m = visibleMonth.value;
    visibleMonth.value = DateTime(m.year, m.month + 1);
  }
}
