import 'package:smartdrinkai/configs/pref_const.dart';
import 'package:smartdrinkai/configs/pref_defaults.dart';
import 'package:smartdrinkai/models/data_models/drink_record.dart';
import 'package:smartdrinkai/models/ui_models/activity_level.dart';
import 'package:smartdrinkai/models/ui_models/reminder_mode.dart';
import 'package:smartdrinkai/models/ui_models/weather_condition.dart';
import 'package:smartdrinkai/repository/user_repository.dart';
import 'package:smartdrinkai/services/application/drink_data_service.dart';
import 'package:smartdrinkai/services/native/notification_channel.dart';
import 'package:smartdrinkai/services/native/widget_channel.dart';
import 'package:smartdrinkai/utils/date_utils.dart';
import 'package:smartdrinkai/utils/loading_utils.dart';
import 'package:smartdrinkai/utils/unit_converter.dart';
import 'package:smartdrinkai/utils/water_calculation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'history_controller.dart';
import 'reminder_controller.dart';
import 'settings_controller.dart';
import 'user_profile_controller.dart';

class TodayController extends GetxController with WidgetsBindingObserver {
  final DrinkDataService _drinkService = DrinkDataService();
  final profileCtrl = Get.find<UserProfileController>();
  String _lastLoadedDateKey = '';

  final RxInt currentIntakeMl = 0.obs;
  final RxList<DrinkRecord> todayRecords = <DrinkRecord>[].obs;
  final RxString nextReminderTime = ''.obs;
  final RxString reminderCountdown = ''.obs;

  late final Worker _profileWorker;
  Worker? _languageWorker;
  Worker? _timeFormatWorker;

  int get adjustedGoal => profileCtrl.profile.value.dailyGoalMl;

  ActivityLevel get activityLevel => ActivityLevel.values.firstWhere(
    (e) => e.name == profileCtrl.profile.value.activityLevel,
    orElse: () => ActivityLevel.sedentary,
  );

  WeatherCondition get weatherCondition => WeatherCondition.values.firstWhere(
    (e) => e.name == profileCtrl.profile.value.weatherCondition,
    orElse: () => WeatherCondition.normal,
  );

  double get progress =>
      WaterCalculation.progressPercent(currentIntakeMl.value, adjustedGoal);

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    // React to profile changes (e.g. daily goal updated in Settings)
    final profileCtrl = Get.find<UserProfileController>();
    _profileWorker = ever(profileCtrl.profile, (_) => loadTodayData());

    // React to language changes to update localized strings in the controller
    if (Get.isRegistered<SettingsController>()) {
      final settingsCtrl = Get.find<SettingsController>();
      _languageWorker = ever(settingsCtrl.language, (_) => loadTodayData());
      _timeFormatWorker = ever(settingsCtrl.timeFormat, (_) => updateWidget());
    }

    _checkPendingWaterAndReload();
  }

  @override
  void onClose() {
    _profileWorker.dispose();
    _languageWorker?.dispose();
    _timeFormatWorker?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPendingWaterAndReload();
    }
  }

  Future<void> _checkPendingWaterAndReload() async {
    // Check if date has changed since last load (midnight crossing)
    final currentDateKey = AppDateUtils.todayKey();
    if (_lastLoadedDateKey.isNotEmpty && _lastLoadedDateKey != currentDateKey) {
      // Date changed - reset view to today's fresh data
      await loadTodayData();
      return;
    }

    final pendingDrinks = await NotificationChannel.checkPendingAddWater();
    if (pendingDrinks.isNotEmpty) {
      for (final drink in pendingDrinks) {
        final amount = drink['amount'] as int? ?? 0;
        final type = drink['type'] as String? ?? 'water';
        if (amount > 0) {
          await addDrink(amount, drinkType: type);
        }
      }
    } else {
      await loadTodayData();
    }
  }

  Future<void> loadTodayData() async {
    final total = await _drinkService.getTodayTotal();
    _lastLoadedDateKey = AppDateUtils.todayKey();
    currentIntakeMl.value = total;

    final records = await _drinkService.getTodayRecords();
    todayRecords.assignAll(records);

    await _updateNextReminder();
    updateWidget();
    _ensureOngoingNotification();
    _ensureDailyNotifications();
  }

  Future<void> _ensureOngoingNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled =
        prefs.getBool(PrefConst.notificationOngoingEnabled) ??
        PrefDefaults.notificationOngoingEnabled;
    if (enabled) {
      await NotificationChannel.requestPermission();
      await NotificationChannel.startOngoingNotification();
    }
  }

  /// Sync reminder schedule to native alarms.
  /// Reads directly from prefs + DB so it works without ReminderController.
  Future<void> _ensureDailyNotifications() async {
    // If ReminderController is alive, delegate to it (has latest in-memory state)
    if (Get.isRegistered<ReminderController>()) {
      final reminderCtrl = Get.find<ReminderController>();
      await reminderCtrl.syncNativeSchedule();
      return;
    }

    // Otherwise, read from SharedPreferences + DB directly
    final prefs = await SharedPreferences.getInstance();
    final reminderEnabled =
        prefs.getBool(PrefConst.reminderEnabled) ??
        PrefDefaults.reminderEnabled;
    if (!reminderEnabled) return;

    final activeMode = ReminderMode.fromString(
      prefs.getString(PrefConst.reminderMode) ?? PrefDefaults.reminderMode,
    );

    List<Map<String, int>> times;

    if (activeMode == ReminderMode.interval) {
      final intervalMins =
          prefs.getInt(PrefConst.intervalMinutes) ??
          PrefDefaults.intervalMinutes;
      final wakeTime =
          prefs.getString(PrefConst.sleepTimeEnd) ?? PrefDefaults.sleepTimeEnd;
      final bedTimeStr =
          prefs.getString(PrefConst.sleepTimeStart) ??
          PrefDefaults.sleepTimeStart;

      final wakeParts = wakeTime.split(':');
      final bedParts = bedTimeStr.split(':');
      final wakeHour = int.tryParse(wakeParts[0]) ?? 6;
      final wakeMin = wakeParts.length > 1
          ? (int.tryParse(wakeParts[1]) ?? 0)
          : 0;
      final bedHour = int.tryParse(bedParts[0]) ?? 23;
      final bedMin = bedParts.length > 1 ? (int.tryParse(bedParts[1]) ?? 0) : 0;

      final wakeTotal = wakeHour * 60 + wakeMin;
      final bedTotal = bedHour * 60 + bedMin;
      final end = bedTotal > wakeTotal ? bedTotal : bedTotal + 24 * 60;

      times = [];
      var current = wakeTotal;
      while (current <= end && times.length < PrefDefaults.maxReminderAlarms) {
        times.add({'hour': (current ~/ 60) % 24, 'minute': current % 60});
        current += intervalMins;
      }
    } else {
      final repo = UserRepository();
      final allSchedules = await repo.getReminderSchedules(
        mode: activeMode.name,
      );
      final enabledSchedules = allSchedules.where((s) => s.enabled).toList();

      if (enabledSchedules.isEmpty) return;

      times = enabledSchedules.map((s) {
        final parts = s.time.split(':');
        return {
          'hour': int.tryParse(parts[0]) ?? 8,
          'minute': parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
        };
      }).toList();
    }

    if (times.isNotEmpty) {
      await NotificationChannel.syncReminders(times);
    }
  }

  Future<void> addDrink(
    int amountMl, {
    double? originalAmountMl,
    String drinkType = 'water',
  }) async {
    final actVolume = originalAmountMl ?? amountMl.toDouble();
    if (actVolume <= 0)
      return; // Guard: reject invalid original capacity, but allow 0 hydration amount

    // Ghi nhớ lượng nước TRƯỚC khi uống thêm
    final wasBelowGoal = currentIntakeMl.value < adjustedGoal;

    await _drinkService.addDrink(
      amountMl: amountMl,
      originalAmountMl: originalAmountMl,
      drinkType: drinkType,
      goalMl: adjustedGoal,
    );
    await loadTodayData();
    _refreshHistoryIfNeeded();

    // Nếu lúc nãy chưa đạt mốc, mà bây giờ đạt hoặc vượt mốc -> Bắn pháo hoa!
    if (wasBelowGoal && currentIntakeMl.value >= adjustedGoal) {
      LoadingUtils.showConfetti();
    }
  }

  void _refreshHistoryIfNeeded() {
    if (Get.isRegistered<HistoryController>()) {
      Get.find<HistoryController>().loadData();
    }
  }

  Future<void> setActivityLevel(ActivityLevel level) async {
    await profileCtrl.updateActivityLevel(level.name);
  }

  Future<void> setWeatherCondition(WeatherCondition condition) async {
    await profileCtrl.updateWeatherCondition(condition.name);
  }

  Future<void> _updateNextReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final reminderEnabled =
        prefs.getBool(PrefConst.reminderEnabled) ??
        PrefDefaults.reminderEnabled;

    if (!reminderEnabled) {
      nextReminderTime.value = '';
      reminderCountdown.value = '';
      return;
    }

    final activeMode = ReminderMode.fromString(
      prefs.getString(PrefConst.reminderMode) ?? PrefDefaults.reminderMode,
    );

    final repo = UserRepository();
    final allSchedules = await repo.getReminderSchedules();

    // Interval mode: calculate next reminder from interval + sleep window
    if (activeMode == ReminderMode.interval) {
      final intervalMins =
          prefs.getInt(PrefConst.intervalMinutes) ??
          PrefDefaults.intervalMinutes;
      final wakeTime =
          prefs.getString(PrefConst.sleepTimeEnd) ?? PrefDefaults.sleepTimeEnd;
      final bedTime =
          prefs.getString(PrefConst.sleepTimeStart) ??
          PrefDefaults.sleepTimeStart;

      // Parse wake/sleep times
      final wakeParts = wakeTime.split(':');
      final bedParts = bedTime.split(':');
      if (wakeParts.length == 2 && bedParts.length == 2) {
        final wakeHour = int.tryParse(wakeParts[0]) ?? 6;
        final wakeMin = int.tryParse(wakeParts[1]) ?? 0;
        final bedHour = int.tryParse(bedParts[0]) ?? 23;
        final bedMin = int.tryParse(bedParts[1]) ?? 0;

        final now = DateTime.now();
        final todayWake = DateTime(
          now.year,
          now.month,
          now.day,
          wakeHour,
          wakeMin,
        );
        final todayBed = DateTime(
          now.year,
          now.month,
          now.day,
          bedHour,
          bedMin,
        );
        final interval = Duration(minutes: intervalMins);

        DateTime awakeStart;
        DateTime awakeEnd;

        // Xử lý logic chia khoảng thời gian qua đêm (vd thức 15h, ngủ 7h sáng)
        if (todayBed.isBefore(todayWake)) {
          if (now.isBefore(todayBed)) {
            // Hiện tại đang từ 0h đến lúc đi ngủ (thuộc khoảng thức của ngày hôm qua)
            awakeStart = todayWake.subtract(const Duration(days: 1));
            awakeEnd = todayBed;
          } else {
            // Hiện tại đang sau lúc đi ngủ, chờ đến giờ thức của hôm nay
            awakeStart = todayWake;
            awakeEnd = todayBed.add(const Duration(days: 1));
          }
        } else {
          // Thức và ngủ trong cùng 1 ngày (vd thức 7h, ngủ 23h)
          awakeStart = todayWake;
          awakeEnd = todayBed;
        }

        // Generate all interval times for the active awake window
        DateTime? nearest;
        var candidate = awakeStart;
        while (!candidate.isAfter(awakeEnd)) {
          if (candidate.isAfter(now)) {
            nearest = candidate;
            break;
          }
          candidate = candidate.add(interval);
        }

        // Khong còn giờ nhắc nhở nào trong khung giờ thức hiện tại -> lấy khung giờ thức ngày mơi
        nearest ??= awakeStart.add(const Duration(days: 1));

        nextReminderTime.value =
            '${nearest.hour.toString().padLeft(2, '0')}:${nearest.minute.toString().padLeft(2, '0')}';

        final diff = nearest.difference(now);
        final hours = diff.inHours;
        final minutes = diff.inMinutes % 60;
        if (hours > 0) {
          reminderCountdown.value = 'remaining_hm'.trParams({
            'args1': hours.toString(),
            'args2': minutes.toString().padLeft(2, '0'),
          });
        } else {
          reminderCountdown.value = 'remaining_m'.trParams({
            'args1': minutes.toString(),
          });
        }
      }
      return;
    }

    // Filter to the active mode's enabled schedules
    final enabledSchedules = allSchedules
        .where((s) => s.mode == activeMode.name && s.enabled)
        .toList();

    if (enabledSchedules.isEmpty) {
      nextReminderTime.value = '';
      reminderCountdown.value = '';
      return;
    }

    final now = DateTime.now();
    DateTime? nearest;

    for (final schedule in enabledSchedules) {
      final parts = schedule.time.split(':');
      if (parts.length != 2) continue;
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null || minute == null) continue;

      var candidate = DateTime(now.year, now.month, now.day, hour, minute);
      if (candidate.isBefore(now)) {
        candidate = candidate.add(const Duration(days: 1));
      }
      if (nearest == null || candidate.isBefore(nearest)) {
        nearest = candidate;
      }
    }

    if (nearest == null) {
      nextReminderTime.value = '';
      reminderCountdown.value = '';
      return;
    }

    nextReminderTime.value =
        '${nearest.hour.toString().padLeft(2, '0')}:${nearest.minute.toString().padLeft(2, '0')}';

    final diff = nearest.difference(now);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    if (hours > 0) {
      reminderCountdown.value = 'remaining_hm'.trParams({
        'args1': hours.toString(),
        'args2': minutes.toString().padLeft(2, '0'),
      });
    } else {
      reminderCountdown.value = 'remaining_m'.trParams({
        'args1': minutes.toString(),
      });
    }
  }

  void updateWidget() {
    final volumeUnit = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>().volumeUnit.value
        : 'ml';
    final timeFormat = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>().timeFormat.value
        : '24h';

    // Build recent drinks list (last 2, newest first) for the large widget
    final recent = todayRecords.reversed.take(2).map((r) {
      final timeStr = UnitConverter.formatTime(
        '${r.timestamp.hour.toString().padLeft(2, '0')}:${r.timestamp.minute.toString().padLeft(2, '0')}',
        timeFormat,
      );

      final String displayAmount;
      if (volumeUnit == 'oz') {
        final oz = r.amountMl * 0.033814;
        displayAmount =
            '${oz.toStringAsFixed(2).replaceAll(RegExp(r'\.?0*$'), '')} oz';
      } else {
        displayAmount = '${r.amountMl} ml';
      }

      // Localize drink name (e.g. "milk".tr)
      final localizedName = r.drinkType.tr;
      final capitalizedName = localizedName.isNotEmpty
          ? localizedName[0].toUpperCase() + localizedName.substring(1)
          : localizedName;

      return <String, String>{
        'name': capitalizedName,
        'amount': displayAmount,
        'time': timeStr,
        'type': r.drinkType,
      };
    }).toList();

    // Localize UI labels for the widgets
    final labels = {
      'add_drink': 'add_drink'.tr,
      'today_s_intake': 'today_s_intake'.tr,
      'remaining': 'remaining'.tr,
      'exceeded_your_goal': 'exceeded_your_goal'.tr,
      'goal_completed': 'goal_completed'.tr,
      'no_records_today': 'no_records_today'.tr,
      'next_reminder': 'next_reminder'.tr,
      'no_reminder_set': 'no_reminder_set'.tr,
      'hours': 'hours'.tr.toUpperCase(),
      'minutes': 'minutes'.tr.toUpperCase(),
      'seconds': 'second'.tr.toUpperCase(), // Using 'second' as base
      'custom': 'custom'.tr,
    };

    WidgetChannel.updateWidgetData(
      currentMl: currentIntakeMl.value,
      goalMl: adjustedGoal,
      nextReminderTime: nextReminderTime.value,
      recentDrinks: recent,
      volumeUnit: volumeUnit,
      labels: labels,
    );

    // Sync ongoing notification data
    final lastDrink = todayRecords.isNotEmpty ? todayRecords.last : null;
    final lastDrinkText = lastDrink != null
        ? 'Last drink: ${lastDrink.amountMl}ml at ${lastDrink.timestamp.hour.toString().padLeft(2, '0')}:${lastDrink.timestamp.minute.toString().padLeft(2, '0')}'
        : '';
    NotificationChannel.updateOngoingData(
      currentMl: currentIntakeMl.value,
      goalMl: adjustedGoal,
      lastDrinkText: lastDrinkText,
    );
  }
}

