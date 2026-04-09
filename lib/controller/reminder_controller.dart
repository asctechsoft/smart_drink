import 'package:smartdrinkai/configs/pref_const.dart';
import 'package:smartdrinkai/configs/pref_defaults.dart';
import 'package:smartdrinkai/models/data_models/reminder_schedule.dart';
import 'package:smartdrinkai/models/ui_models/reminder_mode.dart';
import 'package:smartdrinkai/repository/user_repository.dart';
import 'package:smartdrinkai/services/native/notification_channel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_controller.dart';

class ReminderController extends GetxController {
  final UserRepository _userRepo = UserRepository();

  final RxBool enabled = true.obs;
  final Rx<ReminderMode> mode = ReminderMode.standard.obs;
  final RxList<ReminderSchedule> schedules = <ReminderSchedule>[].obs;
  final RxString soundEffect = PrefDefaults.soundEffect.obs;
  final RxBool soundEffectEnabled = true.obs;
  final RxBool vibrate = true.obs;
  final RxList<int> repeatDays = <int>[1, 2, 3, 4, 5].obs;
  final RxInt intervalMinutes = 120.obs;
  final RxString sleepTimeStart = '23:00'.obs;
  final RxString sleepTimeEnd = '06:00'.obs;

  static const standardLabels = [
    'after_wake_up',
    'before_breakfast',
    'after_breakfast',
    'before_lunch',
    'after_lunch',
    'before_dinner',
    'after_dinner',
    'before_sleep',
  ];

  static const standardTimes = [
    '06:00',
    '08:00',
    '09:30',
    '11:00',
    '13:00',
    '18:00',
    '20:00',
    '22:00',
  ];

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    enabled.value =
        prefs.getBool(PrefConst.reminderEnabled) ??
        PrefDefaults.reminderEnabled;
    mode.value = ReminderMode.fromString(
      prefs.getString(PrefConst.reminderMode) ?? PrefDefaults.reminderMode,
    );
    soundEffect.value =
        prefs.getString(PrefConst.soundEffect) ?? PrefDefaults.soundEffect;
    soundEffectEnabled.value =
        prefs.getBool(PrefConst.soundEffectEnabled) ??
        PrefDefaults.soundEffectEnabled;
    vibrate.value =
        prefs.getBool(PrefConst.vibrateEnabled) ?? PrefDefaults.vibrateEnabled;
    intervalMinutes.value =
        prefs.getInt(PrefConst.intervalMinutes) ?? PrefDefaults.intervalMinutes;
    sleepTimeStart.value =
        prefs.getString(PrefConst.sleepTimeStart) ??
        PrefDefaults.sleepTimeStart;
    sleepTimeEnd.value =
        prefs.getString(PrefConst.sleepTimeEnd) ?? PrefDefaults.sleepTimeEnd;

    // Load repeat days
    final repeatDaysStr =
        prefs.getString(PrefConst.repeatDays) ?? PrefDefaults.repeatDays;
    repeatDays.assignAll(
      repeatDaysStr
          .split(',')
          .where((s) => s.isNotEmpty)
          .map((s) => int.parse(s.trim()))
          .toList(),
    );

    // Load all schedules (not filtered by mode)
    final scheduleList = await _userRepo.getReminderSchedules();
    schedules.assignAll(scheduleList);

    // Seed default standard schedules if none exist
    final standardSchedules = scheduleList
        .where((s) => s.mode == 'standard')
        .toList();
    if (standardSchedules.isEmpty) {
      await _seedDefaultStandardSchedules();
    }

    // Seed default custom schedule if none exist
    final customSchedulesTemp = scheduleList
        .where((s) => s.mode == 'custom')
        .toList();
    if (customSchedulesTemp.isEmpty) {
      await _seedDefaultCustomSchedules();
    }
  }

  Future<void> _seedDefaultStandardSchedules() async {
    for (int i = 0; i < standardLabels.length; i++) {
      final schedule = ReminderSchedule(
        mode: 'standard',
        time: standardTimes[i],
        label: standardLabels[i],
        enabled: true,
      );
      final id = await _userRepo.insertReminderSchedule(schedule);
      schedules.add(schedule.copyWith(id: id));
    }
  }

  Future<void> _seedDefaultCustomSchedules() async {
    final schedule = ReminderSchedule(
      mode: 'custom',
      time: '08:00',
      label: 'custom_1',
      enabled: true,
    );
    final id = await _userRepo.insertReminderSchedule(schedule);
    schedules.add(schedule.copyWith(id: id));
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefConst.reminderEnabled, enabled.value);
    await prefs.setString(PrefConst.reminderMode, mode.value.name);
    await prefs.setString(PrefConst.soundEffect, soundEffect.value);
    await prefs.setBool(PrefConst.soundEffectEnabled, soundEffectEnabled.value);
    await prefs.setBool(PrefConst.vibrateEnabled, vibrate.value);
    await prefs.setInt(PrefConst.intervalMinutes, intervalMinutes.value);
    await prefs.setString(PrefConst.sleepTimeStart, sleepTimeStart.value);
    await prefs.setString(PrefConst.sleepTimeEnd, sleepTimeEnd.value);
    await prefs.setString(PrefConst.repeatDays, repeatDays.join(','));
    await syncNativeSchedule();
  }

  /// Sync all enabled reminder times to native Android alarm scheduling.
  Future<void> syncNativeSchedule() async {
    if (!enabled.value) {
      await NotificationChannel.cancelDailyNotification();
      return;
    }

    final times = _buildScheduleTimes();
    await NotificationChannel.syncReminders(times);
  }

  /// Build the full list of {hour, minute} maps from enabled schedules.
  List<Map<String, int>> _buildScheduleTimes() {
    if (mode.value == ReminderMode.interval) {
      return _buildIntervalTimes();
    }

    // Standard or custom mode: use ALL enabled schedule times
    final modeSchedules = schedules
        .where((s) => s.mode == mode.value.name && s.enabled)
        .toList();

    if (modeSchedules.isEmpty) {
      return [
        {'hour': PrefDefaults.notificationDailyHourMorning, 'minute': 0},
        {'hour': PrefDefaults.notificationDailyHourAfternoon, 'minute': 0},
        {'hour': PrefDefaults.notificationDailyHourNight, 'minute': 0},
      ];
    }

    return modeSchedules.map((s) {
      final parts = s.time.split(':');
      return {
        'hour': int.tryParse(parts[0]) ?? 8,
        'minute': parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
      };
    }).toList();
  }

  /// Build interval-based schedule times within the awake window.
  List<Map<String, int>> _buildIntervalTimes() {
    final wakeParts = sleepTimeEnd.value.split(':');
    final bedParts = sleepTimeStart.value.split(':');
    final wakeHour = int.tryParse(wakeParts[0]) ?? 6;
    final wakeMin = wakeParts.length > 1
        ? (int.tryParse(wakeParts[1]) ?? 0)
        : 0;
    final bedHour = int.tryParse(bedParts[0]) ?? 23;
    final bedMin = bedParts.length > 1 ? (int.tryParse(bedParts[1]) ?? 0) : 0;

    final wakeTotal = wakeHour * 60 + wakeMin;
    final bedTotal = bedHour * 60 + bedMin;
    final interval = intervalMinutes.value;
    if (interval <= 0) return [];

    final times = <Map<String, int>>[];
    var current = wakeTotal;
    final end = bedTotal > wakeTotal ? bedTotal : bedTotal + 24 * 60;

    while (current <= end && times.length < PrefDefaults.maxReminderAlarms) {
      final h = (current ~/ 60) % 24;
      final m = current % 60;
      times.add({'hour': h, 'minute': m});
      current += interval;
    }

    return times;
  }

  Future<void> setMode(ReminderMode newMode) async {
    mode.value = newMode;
    await saveSettings(); // saveSettings already calls syncNativeSchedule
  }

  String getRepeatDaysSummary() {
    if (repeatDays.length == 7) return 'everyday'.tr;
    if (repeatDays.length == 5 &&
        repeatDays.contains(1) &&
        repeatDays.contains(2) &&
        repeatDays.contains(3) &&
        repeatDays.contains(4) &&
        repeatDays.contains(5) &&
        !repeatDays.contains(6) &&
        !repeatDays.contains(7)) {
      return 'weekdays'.tr;
    }
    if (repeatDays.length == 2 &&
        repeatDays.contains(6) &&
        repeatDays.contains(7)) {
      return 'weekends'.tr;
    }
    final dayNames = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    return repeatDays.map((d) => dayNames[d - 1].tr).join(', ');
  }

  Future<void> addSchedule(ReminderSchedule schedule) async {
    final id = await _userRepo.insertReminderSchedule(schedule);
    schedules.add(schedule.copyWith(id: id));
    await syncNativeSchedule();
  }

  Future<void> updateSchedule(ReminderSchedule schedule) async {
    await _userRepo.updateReminderSchedule(schedule);
    final index = schedules.indexWhere((s) => s.id == schedule.id);
    if (index >= 0) {
      schedules[index] = schedule;
    }
    await syncNativeSchedule();
  }

  Future<void> removeSchedule(int id) async {
    await _userRepo.deleteReminderSchedule(id);
    schedules.removeWhere((s) => s.id == id);
    await syncNativeSchedule();
  }

  Future<void> toggleDay(int day) async {
    if (repeatDays.contains(day)) {
      repeatDays.remove(day);
    } else {
      repeatDays.add(day);
      repeatDays.sort();
    }
    await saveSettings();
  }

  /// Get standard schedules, creating defaults if needed
  List<ReminderSchedule> get standardSchedules {
    return schedules.where((s) => s.mode == 'standard').toList();
  }

  /// Get custom schedules
  List<ReminderSchedule> get customSchedules {
    return schedules.where((s) => s.mode == 'custom').toList();
  }

  /// Format time for display based on settings
  String formatDisplayTime(String time24) {
    final settingsCtrl = Get.find<SettingsController>();
    bool is12h = false;

    if (settingsCtrl.timeFormat.value == 'system') {
      final context = Get.context;
      if (context != null) {
        is12h = !MediaQuery.of(context).alwaysUse24HourFormat;
      }
    } else {
      is12h = settingsCtrl.timeFormat.value == '12h';
    }

    if (!is12h) return time24;

    final parts = time24.split(':');
    if (parts.length != 2) return time24;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    final isPm = hour >= 12;
    // Mốc 0h sáng hiển thị là 12 AM theo chuẩn 12-hour format
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final period = isPm ? 'pm'.tr : 'am'.tr;

    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  /// Format interval for display
  String get intervalDisplay {
    final h = intervalMinutes.value ~/ 60;
    final m = intervalMinutes.value % 60;
    if (h > 0 && m > 0)
      return '$h ${h <= 1 ? 'hour'.tr : 'hours'.tr} $m ${'min'.tr}';
    if (h > 0) return '$h ${h <= 1 ? 'hour'.tr : 'hours'.tr}';
    return '$m ${'min'.tr}';
  }
}

