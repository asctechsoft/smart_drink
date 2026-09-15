import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waternudge/configs/pref_const.dart';
import 'package:waternudge/configs/pref_defaults.dart';
import 'package:waternudge/services/native/health_connect_service.dart';

/// Keeps Health Connect in step with the drink log.
///
/// This is the gate the rest of the app calls: it checks the user's opt-in and
/// then hands off to [HealthConnectService]. Nothing here ever throws or
/// awaits anything slow on the caller's critical path — a Health Connect that
/// is missing, revoked or simply slow must not stop a drink from being logged.
class HealthSyncService {
  const HealthSyncService._();

  static Future<bool> _enabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PrefConst.healthConnectEnabled) ??
        PrefDefaults.healthConnectEnabled;
  }

  /// Mirrors a newly logged drink. [amountMl] is the hydrating volume that was
  /// credited to the daily goal, which is what other health apps expect to see.
  static Future<void> onDrinkAdded({
    required int drinkRecordId,
    required int amountMl,
    DateTime? at,
  }) async {
    try {
      if (!await _enabled()) return;
      await HealthConnectService.instance.writeDrink(
        drinkRecordId: drinkRecordId,
        amountMl: amountMl,
        at: at,
      );
    } catch (e) {
      debugPrint('HealthSyncService.onDrinkAdded failed: $e');
    }
  }

  /// Withdraws the record written for a drink the user has since deleted.
  static Future<void> onDrinkDeleted(int drinkRecordId) async {
    try {
      if (!await _enabled()) return;
      await HealthConnectService.instance.deleteDrink(drinkRecordId);
    } catch (e) {
      debugPrint('HealthSyncService.onDrinkDeleted failed: $e');
    }
  }

  /// Rewrites a drink whose amount or time was edited: the old record is
  /// withdrawn and a new one written under the same client id.
  static Future<void> onDrinkUpdated({
    required int drinkRecordId,
    required int amountMl,
    DateTime? at,
  }) async {
    try {
      if (!await _enabled()) return;
      await HealthConnectService.instance.deleteDrink(drinkRecordId);
      await HealthConnectService.instance.writeDrink(
        drinkRecordId: drinkRecordId,
        amountMl: amountMl,
        at: at,
      );
    } catch (e) {
      debugPrint('HealthSyncService.onDrinkUpdated failed: $e');
    }
  }
}
