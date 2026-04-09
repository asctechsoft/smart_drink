import 'package:smartdrinkai/models/data_models/user_profile.dart';
import 'package:smartdrinkai/repository/user_repository.dart';
import 'package:smartdrinkai/utils/water_calculation.dart';
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
  }

  Future<void> updateHeight(double height, String unit) async {
    await saveProfile(profile.value.copyWith(height: height, heightUnit: unit));
  }

  Future<void> updateAge(int age) async {
    await saveProfile(profile.value.copyWith(age: age));
  }

  Future<void> updateDailyGoal(int goalMl) async {
    await saveProfile(profile.value.copyWith(dailyGoalMl: goalMl));
  }

  Future<void> updateActivityLevel(String level) async {
    final updated = profile.value.copyWith(activityLevel: level);
    await saveProfile(
      updated.copyWith(
        dailyGoalMl: WaterCalculation.calculateDailyGoalFromProfile(updated),
      ),
    );
  }

  Future<void> updateWeatherCondition(String condition) async {
    final updated = profile.value.copyWith(weatherCondition: condition);
    await saveProfile(
      updated.copyWith(
        dailyGoalMl: WaterCalculation.calculateDailyGoalFromProfile(updated),
      ),
    );
  }

  Future<void> updateWakeUpTime(String time) async {
    await saveProfile(profile.value.copyWith(wakeUpTime: time));
  }

  Future<void> updateBedTime(String time) async {
    await saveProfile(profile.value.copyWith(bedTime: time));
  }
}

