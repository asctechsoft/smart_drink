import 'package:waternudge/configs/pref_const.dart';
import 'package:waternudge/configs/pref_defaults.dart';
import 'package:waternudge/services/native/health_connect_service.dart';
import 'package:waternudge/utils/analytics.dart';
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
  final RxBool isRated = false.obs;

  /// Whether logged drinks are mirrored into Health Connect. Android-only, and
  /// only ever true while the hydration permission is actually granted.
  final RxBool healthConnectEnabled = PrefDefaults.healthConnectEnabled.obs;

  /// Whether the Settings row should appear at all: Android with Health
  /// Connect installed. Resolved once at startup.
  final RxBool healthConnectAvailable = false.obs;

  /// True while the permission sheet is open, so the tile can show a spinner
  /// and refuse a second tap.
  final RxBool healthConnectBusy = false.obs;

  final HealthConnectService _healthConnect = HealthConnectService.instance;

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

    await _loadHealthConnect(prefs);

    Analytics.userTheme(themeMode.value);
    Analytics.userVolumeUnit(volumeUnit.value);
    Analytics.userWeightUnit(weightUnit.value);
    Analytics.userHealthConnectEnabled(healthConnectEnabled.value);
  }

  /// Resolves the Health Connect row's state on startup.
  ///
  /// The stored flag is only half the answer: the user can revoke hydration
  /// access in system settings at any time, which would leave the toggle on
  /// while nothing syncs. Permission is therefore re-checked here and the flag
  /// is corrected to match reality.
  Future<void> _loadHealthConnect(SharedPreferences prefs) async {
    healthConnectAvailable.value = await _healthConnect.isAvailable();
    if (!healthConnectAvailable.value) {
      healthConnectEnabled.value = false;
      return;
    }

    final stored =
        prefs.getBool(PrefConst.healthConnectEnabled) ??
        PrefDefaults.healthConnectEnabled;
    if (!stored) {
      healthConnectEnabled.value = false;
      return;
    }

    final granted = await _healthConnect.hasPermissions();
    healthConnectEnabled.value = granted;
    if (!granted) {
      await prefs.setBool(PrefConst.healthConnectEnabled, false);
    }
  }

  /// Turns the Health Connect sync on or off.
  ///
  /// Turning it on asks for the hydration permission; if the user declines, the
  /// toggle stays off rather than pretending to sync. Returns false when the
  /// request was refused, so the caller can point the user at Health Connect —
  /// it stops showing its own sheet after two refusals.
  Future<bool> setHealthConnectEnabled(bool value) async {
    if (healthConnectBusy.value) return healthConnectEnabled.value;
    healthConnectBusy.value = true;
    try {
      if (!value) {
        healthConnectEnabled.value = false;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(PrefConst.healthConnectEnabled, false);
        return true;
      }

      if (!await _healthConnect.isAvailable()) {
        healthConnectAvailable.value = false;
        healthConnectEnabled.value = false;
        return false;
      }

      final granted = await _healthConnect.hasPermissions()
          ? true
          : await _healthConnect.requestPermissions();

      healthConnectEnabled.value = granted;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(PrefConst.healthConnectEnabled, granted);
      return granted;
    } finally {
      healthConnectBusy.value = false;
    }
  }

  /// Opens Health Connect so the user can grant hydration access by hand.
  Future<void> openHealthConnect() =>
      _healthConnect.openHealthConnectSettings();

  Future<void> setThemeMode(String mode) async {
    themeMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefConst.themeMode, mode);
    _applyTheme(mode);
    Analytics.settingsThemeSelect(mode);
  }

  /// The app ships one look, so the theme never follows the device.
  ///
  /// [mode] is still stored (a saved 'system' from an older build included), but
  /// the applied mode is always dark: the foreground palette is fixed
  /// dark-on-dark, so letting the device switch this to light left unreadable
  /// text on a light background.
  void _applyTheme(String mode) {
    Get.changeThemeMode(ThemeMode.dark);
  }

  Future<void> setVolumeUnit(String unit) async {
    volumeUnit.value = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefConst.volumeUnit, unit);
    // Refresh the home screen widget so it shows the new unit
    if (Get.isRegistered<TodayController>()) {
      Get.find<TodayController>().updateWidget();
    }
    Analytics.settingsUnitSelect('volume', unit);
  }

  Future<void> setWeightUnit(String unit) async {
    weightUnit.value = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefConst.weightUnit, unit);
    Analytics.settingsUnitSelect('weight', unit);
  }

  Future<void> setHeightUnit(String unit) async {
    heightUnit.value = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefConst.heightUnit, unit);
    Analytics.settingsUnitSelect('height', unit);
  }

  Future<void> setRated() async {
    isRated.value = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefConst.isRated, true);
  }
}

