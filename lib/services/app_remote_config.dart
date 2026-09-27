import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-owned replacement for dsp_base's `RconfAssist` — reads Firebase
/// Remote Config, with an optional persisted local override so a debug/test
/// build can pin a value without a live Remote Config experiment (see
/// `TourController.assignLocalVariant`). Only the `String` get/set this app
/// actually calls are ported.
class AppRemoteConfig {
  AppRemoteConfig._();

  static const String _testKeyPrefix = 'app_remote_config_test_';

  /// Populated by the first [setTestString] call. `getString` degrades to
  /// the live Remote Config value until then, same as dsp_base's
  /// `PrefAssist`-backed original when read before `PrefAssist.init()`.
  static SharedPreferences? _prefs;

  static String getString(String key, {required bool testOptionEnabled}) {
    if (testOptionEnabled) {
      final override = _prefs?.getString(_testKeyPrefix + key);
      if (override != null) return override;
    }
    return FirebaseRemoteConfig.instance.getString(key);
  }

  static Future<void> setTestString(
    String key,
    String value, {
    required bool testOptionEnabled,
  }) async {
    if (!testOptionEnabled) return;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_testKeyPrefix + key, value);
  }
}
