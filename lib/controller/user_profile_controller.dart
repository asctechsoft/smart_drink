import 'package:waternudge/models/data_models/user_profile.dart';
import 'package:waternudge/repository/user_repository.dart';
import 'package:waternudge/utils/analytics.dart';
import 'package:waternudge/utils/water_calculation.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class UserProfileController extends GetxController {
  final UserRepository _userRepo = UserRepository();

  final Rx<UserProfile> profile = UserProfile().obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final saved = await _userRepo.getProfile();
      if (saved != null) {
        profile.value = saved;
      }
    } catch (e, stackTrace) {
      debugPrint('UserProfileController.loadProfile failed: $e\n$stackTrace');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveProfile(UserProfile updated) async {
    try {
      final withTimestamp = updated.copyWith(updatedAt: DateTime.now());
      await _userRepo.insertOrUpdateProfile(withTimestamp);
      profile.value = withTimestamp;
      Analytics.userGender(withTimestamp.gender);
      Analytics.userDailyGoal(withTimestamp.dailyGoalMl);
    } catch (e, stackTrace) {
      debugPrint('UserProfileController.saveProfile failed: $e\n$stackTrace');
    }
  }

  Future<void> updateGender(String gender) async {
    final updated = profile.value.copyWith(
      gender: gender,
      activityLevel: 'sedentary',
      weatherCondition: 'normal',
    );
    await saveProfile(
      updated.copyWith(
        dailyGoalMl: WaterCalculation.calculateDailyGoalFromProfile(updated),
      ),
    );
    Analytics.settingsFieldSave('gender', gender);
  }

  Future<void> updateWeight(double weight, String unit) async {
    final updated = profile.value.copyWith(
      weight: weight,
      weightUnit: unit,
      activityLevel: 'sedentary',
      weatherCondition: 'normal',
    );
    await saveProfile(
      updated.copyWith(
        dailyGoalMl: WaterCalculation.calculateDailyGoalFromProfile(updated),
      ),
    );
    Analytics.settingsFieldSave('weight', '${weight.round()} $unit');
  }

  Future<void> updateHeight(double height, String unit) async {
    await saveProfile(profile.value.copyWith(height: height, heightUnit: unit));
    Analytics.settingsFieldSave('height', '${height.round()} $unit');
  }

  Future<void> updateAge(int age) async {
    await saveProfile(profile.value.copyWith(age: age));
  }

  Future<void> updateDailyGoal(int goalMl) async {
    await saveProfile(profile.value.copyWith(dailyGoalMl: goalMl));
    Analytics.settingsGoalEdit(goalMl);
  }

  Future<void> updateActivityLevel(String level) async {
    final updated = profile.value.copyWith(activityLevel: level);
    await saveProfile(
      updated.copyWith(
        dailyGoalMl: WaterCalculation.calculateDailyGoalFromProfile(updated),
      ),
    );
    Analytics.settingsFieldSave('activity_level', level);
  }

  Future<void> updateWeatherCondition(String condition) async {
    final updated = profile.value.copyWith(weatherCondition: condition);
    await saveProfile(
      updated.copyWith(
        dailyGoalMl: WaterCalculation.calculateDailyGoalFromProfile(updated),
      ),
    );
    Analytics.settingsFieldSave('weather', condition);
  }

  Future<void> updateWakeUpTime(String time) async {
    await saveProfile(profile.value.copyWith(wakeUpTime: time));
    Analytics.settingsFieldSave('wakeup', time);
  }

  Future<void> updateBedTime(String time) async {
    await saveProfile(profile.value.copyWith(bedTime: time));
    Analytics.settingsFieldSave('bedtime', time);
  }
}

