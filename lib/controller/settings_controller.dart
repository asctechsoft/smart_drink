import 'package:smartdrinkai/configs/pref_const.dart';
import 'package:smartdrinkai/configs/pref_defaults.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'today_controller.dart';
import 'user_profile_controller.dart';

class SettingsController extends GetxController {
  final RxString themeMode = PrefDefaults.themeMode.obs;
  final RxString language = PrefDefaults.language.obs;
  final RxString volumeUnit = PrefDefaults.volumeUnit.obs;
  final RxString weightUnit = PrefDefaults.weightUnit.obs;
  final RxString heightUnit = PrefDefaults.heightUnit.obs;
  final RxString timeFormat = PrefDefaults.timeFormat.obs;
  final RxBool isRated = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    themeMode.value =
        prefs.getString(PrefConst.themeMode) ?? PrefDefaults.themeMode;
    language.value =
        prefs.getString(PrefConst.language) ?? PrefDefaults.language;
    timeFormat.value =
        prefs.getString(PrefConst.timeFormat) ?? PrefDefaults.timeFormat;
    isRated.value = prefs.getBool(PrefConst.isRated) ?? false;

    // For unit settings, prefer SharedPreferences but fall back to UserProfile
    // to handle cases where onboarding saved to profile but not to prefs
    final savedVolume = prefs.getString(PrefConst.volumeUnit);
    final savedWeight = prefs.getString(PrefConst.weightUnit);
    final savedHeight = prefs.getString(PrefConst.heightUnit);

    if (savedVolume != null && savedWeight != null && savedHeight != null) {
      volumeUnit.value = savedVolume;
      weightUnit.value = savedWeight;
      heightUnit.value = savedHeight;
    } else if (Get.isRegistered<UserProfileController>()) {
      final profile = Get.find<UserProfileController>().profile.value;
      volumeUnit.value = savedVolume ?? profile.volumeUnit;
      weightUnit.value = savedWeight ?? profile.weightUnit;
      heightUnit.value = savedHeight ?? profile.heightUnit;
      // Persist to SharedPreferences so future loads are consistent
      if (savedVolume == null) {
        await prefs.setString(PrefConst.volumeUnit, volumeUnit.value);
      }
      if (savedWeight == null) {
        await prefs.setString(PrefConst.weightUnit, weightUnit.value);
      }
      if (savedHeight == null) {
        await prefs.setString(PrefConst.heightUnit, heightUnit.value);
      }
    } else {
      volumeUnit.value = PrefDefaults.volumeUnit;
      weightUnit.value = PrefDefaults.weightUnit;
      heightUnit.value = PrefDefaults.heightUnit;
    }

    _applyTheme(themeMode.value);
  }

  Future<void> setThemeMode(String mode) async {
    themeMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefConst.themeMode, mode);
    _applyTheme(mode);
  }

  void _applyTheme(String mode) {
    switch (mode) {
      case 'light':
        Get.changeThemeMode(ThemeMode.light);
      case 'dark':
        Get.changeThemeMode(ThemeMode.dark);
      default:
        Get.changeThemeMode(ThemeMode.system);
    }
  }

  Future<void> setTimeFormat(String format) async {
    timeFormat.value = format;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefConst.timeFormat, format);
    // Refresh the home screen widget so it shows the new format
    if (Get.isRegistered<TodayController>()) {
      Get.find<TodayController>().updateWidget();
    }
  }

  Future<void> setVolumeUnit(String unit) async {
    volumeUnit.value = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefConst.volumeUnit, unit);
    // Refresh the home screen widget so it shows the new unit
    if (Get.isRegistered<TodayController>()) {
      Get.find<TodayController>().updateWidget();
    }
  }

  Future<void> setWeightUnit(String unit) async {
    weightUnit.value = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefConst.weightUnit, unit);
  }

  Future<void> setHeightUnit(String unit) async {
    heightUnit.value = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefConst.heightUnit, unit);
  }

  Future<void> setRated() async {
    isRated.value = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefConst.isRated, true);
  }
}

