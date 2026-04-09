import 'package:smartdrinkai/configs/pref_const.dart';
import 'package:smartdrinkai/models/data_models/user_profile.dart';
import 'package:smartdrinkai/models/ui_models/reminder_mode.dart';
import 'package:smartdrinkai/services/native/notification_channel.dart';
import 'package:smartdrinkai/utils/water_calculation.dart';
import 'package:smartdrinkai/values/route_name.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_controller.dart';
import 'user_profile_controller.dart';

class OnboardingController extends GetxController {
  final RxInt currentStep = 0.obs;
  final RxString gender = 'female'.obs;
  final RxDouble weight = 60.0.obs;
  final RxString weightUnit = 'kg'.obs;
  final RxString wakeUpTime = '07:00'.obs;
  final RxString bedTime = '22:00'.obs;
  final RxInt intervalMinutes = 90.obs;
  final RxString soundEffect = 'universfield_notification'.obs;
  final RxBool vibrate = true.obs;
  final RxInt dailyGoalMl = 2000.obs;
  final RxString volumeUnit = 'ml'.obs;

  void updateWeightUnit(String unit) {
    if (weightUnit.value == unit) return;

    if (unit == 'kg') {
      weight.value = weight.value / 2.20462;
    } else {
      weight.value = weight.value * 2.20462;
    }
    weightUnit.value = unit;
  }

  void updateVolumeUnit(String unit) {
    if (volumeUnit.value == unit) return;

    if (unit == 'ml') {
      dailyGoalMl.value = (dailyGoalMl.value / 0.033814).round();
    } else {
      dailyGoalMl.value = (dailyGoalMl.value * 0.033814).round();
    }
    volumeUnit.value = unit;
  }

  static const int totalSteps = 4;

  void nextStep() {
    if (currentStep.value < totalSteps) {
      currentStep.value++;
    }
  }

  void prevStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  void calculateGoalFromWeight() {
    double weightKg = weight.value;
    if (weightUnit.value == 'lb') {
      weightKg = weight.value * 0.453592;
    }
    dailyGoalMl.value = WaterCalculation.calculateDailyGoal(weightKg: weightKg);
  }

  /// Derive reminder schedule times from the user's onboarding settings.
  List<Map<String, int>> _deriveOnboardingScheduleTimes() {
    final wakeParts = wakeUpTime.value.split(':');
    final bedParts = bedTime.value.split(':');
    final wakeHour = int.tryParse(wakeParts[0]) ?? 7;
    final wakeMin = wakeParts.length > 1
        ? (int.tryParse(wakeParts[1]) ?? 0)
        : 0;
    final bedHour = int.tryParse(bedParts[0]) ?? 22;
    final bedMin = bedParts.length > 1 ? (int.tryParse(bedParts[1]) ?? 0) : 0;

    final wakeTotal = wakeHour * 60 + wakeMin;
    final bedTotal = bedHour * 60 + bedMin;
    final interval = intervalMinutes.value;
    if (interval <= 0) {
      return [
        {'hour': 8, 'minute': 0},
        {'hour': 13, 'minute': 0},
        {'hour': 21, 'minute': 0},
      ];
    }

    final times = <Map<String, int>>[];
    var current = wakeTotal;
    final end = bedTotal > wakeTotal ? bedTotal : bedTotal + 24 * 60;

    while (current <= end) {
      final h = (current ~/ 60) % 24;
      final m = current % 60;
      times.add({'hour': h, 'minute': m});
      current += interval;
    }

    return times.isNotEmpty
        ? times
        : [
            {'hour': 8, 'minute': 0},
            {'hour': 13, 'minute': 0},
            {'hour': 21, 'minute': 0},
          ];
  }

  Future<void> completeOnboarding() async {
    try {
      final profile = UserProfile(
        gender: gender.value,
        weight: weight.value,
        weightUnit: weightUnit.value,
        wakeUpTime: wakeUpTime.value,
        bedTime: bedTime.value,
        dailyGoalMl: dailyGoalMl.value,
        volumeUnit: volumeUnit.value,
      );

      final profileCtrl = Get.find<UserProfileController>();
      await profileCtrl.saveProfile(profile);

      // Sync unit settings to SharedPreferences so SettingsController stays in sync
      final settingsCtrl = Get.find<SettingsController>();
      await settingsCtrl.setVolumeUnit(volumeUnit.value);
      await settingsCtrl.setWeightUnit(weightUnit.value);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(PrefConst.onboardingCompleted, true);
      await prefs.setInt(PrefConst.intervalMinutes, intervalMinutes.value);
      await prefs.setString(PrefConst.soundEffect, soundEffect.value);
      await prefs.setBool(PrefConst.vibrateEnabled, vibrate.value);
      await prefs.setBool(PrefConst.notificationOngoingEnabled, true);
      await prefs.setBool(PrefConst.reminderEnabled, true);
      await prefs.setString(PrefConst.reminderMode, ReminderMode.interval.name);
      await prefs.setString(PrefConst.sleepTimeStart, bedTime.value);
      await prefs.setString(PrefConst.sleepTimeEnd, wakeUpTime.value);

      await NotificationChannel.startOngoingNotification();

      // Derive reminder times from user's actual wake/bed/interval settings
      final times = _deriveOnboardingScheduleTimes();
      await NotificationChannel.syncReminders(times);

      Get.offAllNamed(RouteName.home);
    } catch (e, stackTrace) {
      debugPrint(
        'OnboardingController.completeOnboarding failed: $e\n$stackTrace',
      );
      Get.snackbar(
        'Error',
        'Failed to complete setup. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

