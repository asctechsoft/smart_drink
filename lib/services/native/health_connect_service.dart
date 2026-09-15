import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

/// Mirrors logged drinks into Android Health Connect.
///
/// Sync is one-way by design: AquaMind is the source of truth for what the
/// user drank, so it writes its own hydration records and never imports other
/// apps' — importing would double-count the same glass logged in two places.
/// Write access is all it asks for; Health Connect lets an app delete its own
/// records without read access, and the published privacy policy declares
/// write-only hydration access, so requesting read would contradict it.
///
/// Every method is a no-op off Android, and every call is wrapped: a device
/// without Health Connect, or a user who revoked the permission in system
/// settings, must never break logging a drink.
class HealthConnectService {
  HealthConnectService._();

  static final HealthConnectService instance = HealthConnectService._();

  final Health _health = Health();

  bool _configured = false;

  /// The one data type the app touches.
  static const List<HealthDataType> _types = [HealthDataType.WATER];

  /// Write only — see the class doc. Deleting our own records needs no read.
  static const List<HealthDataAccess> _access = [HealthDataAccess.WRITE];

  /// Health Connect is Android-only. iOS would be HealthKit, which needs its
  /// own entitlement and review — out of scope until that is set up.
  bool get isSupportedPlatform => Platform.isAndroid;

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  /// Whether Health Connect is installed and usable on this device.
  Future<bool> isAvailable() async {
    if (!isSupportedPlatform) return false;
    try {
      await _ensureConfigured();
      return _health.isHealthConnectAvailable();
    } catch (e) {
      debugPrint('HealthConnectService.isAvailable failed: $e');
      return false;
    }
  }

  /// True when hydration write access has already been granted.
  Future<bool> hasPermissions() async {
    if (!isSupportedPlatform) return false;
    try {
      await _ensureConfigured();
      return await _health.hasPermissions(_types, permissions: _access) ?? false;
    } catch (e) {
      debugPrint('HealthConnectService.hasPermissions failed: $e');
      return false;
    }
  }

  /// Shows the Health Connect permission sheet. Returns whether the user
  /// granted hydration access.
  ///
  /// Health Connect stops showing the sheet after two refusals, so a `false`
  /// here can also mean "the user has already said no twice" — the caller
  /// should offer to open Health Connect rather than asking again in a loop.
  Future<bool> requestPermissions() async {
    if (!isSupportedPlatform) return false;
    try {
      await _ensureConfigured();
      return await _health.requestAuthorization(_types, permissions: _access);
    } catch (e) {
      debugPrint('HealthConnectService.requestPermissions failed: $e');
      return false;
    }
  }

  /// Opens the Health Connect app so the user can grant access by hand after
  /// the in-app sheet has stopped appearing.
  Future<void> openHealthConnectSettings() async {
    if (!isSupportedPlatform) return;
    try {
      await _ensureConfigured();
      await _health.installHealthConnect();
    } catch (e) {
      debugPrint('HealthConnectService.openHealthConnectSettings failed: $e');
    }
  }

  /// Ties a Health Connect record back to the row in `drink_record`, so a
  /// deleted drink can be withdrawn by id instead of by guessing a time window.
  static String clientRecordIdFor(int drinkRecordId) =>
      'waternudge-drink-$drinkRecordId';

  /// Writes one drink as a hydration record.
  ///
  /// [amountMl] is the hydrating volume the app already credited to the goal,
  /// not the cup size — a coffee logged as 200 ml at 60% counts as 120 ml here,
  /// which is what "water intake" means to every other app reading it.
  ///
  /// Health Connect stores hydration in litres over an interval; a single sip
  /// has no duration, so the record is stamped as one minute ending at [at].
  Future<bool> writeDrink({
    required int amountMl,
    required int drinkRecordId,
    DateTime? at,
    Duration duration = const Duration(minutes: 1),
  }) async {
    if (!isSupportedPlatform || amountMl <= 0) return false;
    try {
      await _ensureConfigured();
      final end = at ?? DateTime.now();
      return await _health.writeHealthData(
        value: amountMl / 1000.0, // Health Connect hydration is in litres.
        type: HealthDataType.WATER,
        startTime: end.subtract(duration),
        endTime: end,
        clientRecordId: clientRecordIdFor(drinkRecordId),
        recordingMethod: RecordingMethod.manual,
      );
    } catch (e) {
      debugPrint('HealthConnectService.writeDrink failed: $e');
      return false;
    }
  }

  /// Withdraws the hydration record written for [drinkRecordId].
  ///
  /// Health Connect only ever deletes records owned by the caller, so this can
  /// never touch an entry another app wrote.
  Future<bool> deleteDrink(int drinkRecordId) async {
    if (!isSupportedPlatform) return false;
    try {
      await _ensureConfigured();
      return await _health.deleteByClientRecordId(
        dataTypeKey: HealthDataType.WATER,
        clientRecordId: clientRecordIdFor(drinkRecordId),
      );
    } catch (e) {
      debugPrint('HealthConnectService.deleteDrink failed: $e');
      return false;
    }
  }

  /// Removes every hydration record this app wrote inside [from]..[to] — used
  /// when the user turns the sync off and asks for their data to be withdrawn.
  Future<bool> deleteDrinksBetween({
    required DateTime from,
    required DateTime to,
  }) async {
    if (!isSupportedPlatform) return false;
    try {
      await _ensureConfigured();
      return await _health.delete(
        type: HealthDataType.WATER,
        startTime: from,
        endTime: to,
      );
    } catch (e) {
      debugPrint('HealthConnectService.deleteDrinksBetween failed: $e');
      return false;
    }
  }
}
