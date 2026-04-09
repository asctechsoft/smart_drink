import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NotificationChannel {
  static const _channel = MethodChannel('com.amobi.drinkwater/notifications');

  static Future<bool> requestPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestPermission');
      return result ?? false;
    } on MissingPluginException {
      debugPrint(
        'NotificationChannel.requestPermission: native plugin not available',
      );
      return false;
    } on PlatformException catch (e) {
      debugPrint('NotificationChannel.requestPermission failed: $e');
      return false;
    }
  }

  static Future<void> scheduleReminder({
    required int id,
    required String time,
    required String title,
    required String body,
    String? sound,
    bool vibrate = true,
  }) async {
    try {
      await _channel.invokeMethod('scheduleReminder', {
        'id': id,
        'time': time,
        'title': title,
        'body': body,
        'sound': sound,
        'vibrate': vibrate,
      });
    } on MissingPluginException {
      debugPrint(
        'NotificationChannel.scheduleReminder: native plugin not available',
      );
    } on PlatformException catch (e) {
      debugPrint('NotificationChannel.scheduleReminder failed: $e');
    }
  }

  static Future<void> cancelReminder(int id) async {
    try {
      await _channel.invokeMethod('cancelReminder', {'id': id});
    } on MissingPluginException {
      debugPrint(
        'NotificationChannel.cancelReminder: native plugin not available',
      );
    } on PlatformException catch (e) {
      debugPrint('NotificationChannel.cancelReminder failed: $e');
    }
  }

  static Future<void> cancelAll() async {
    try {
      await _channel.invokeMethod('cancelAll');
    } on MissingPluginException {
      debugPrint('NotificationChannel.cancelAll: native plugin not available');
    } on PlatformException catch (e) {
      debugPrint('NotificationChannel.cancelAll failed: $e');
    }
  }

  static Future<void> startOngoingNotification() async {
    try {
      await _channel.invokeMethod('startOngoingNotification');
    } on MissingPluginException {
      debugPrint(
        'NotificationChannel.startOngoingNotification: native plugin not available',
      );
    } on PlatformException catch (e) {
      debugPrint('NotificationChannel.startOngoingNotification failed: $e');
    }
  }

  static Future<void> stopOngoingNotification() async {
    try {
      await _channel.invokeMethod('stopOngoingNotification');
    } on MissingPluginException {
      debugPrint(
        'NotificationChannel.stopOngoingNotification: native plugin not available',
      );
    } on PlatformException catch (e) {
      debugPrint('NotificationChannel.stopOngoingNotification failed: $e');
    }
  }

  static Future<void> updateOngoingData({
    required int currentMl,
    required int goalMl,
    required String lastDrinkText,
  }) async {
    try {
      await _channel.invokeMethod('updateOngoingData', {
        'currentMl': currentMl,
        'goalMl': goalMl,
        'lastDrinkText': lastDrinkText,
      });
    } on MissingPluginException {
      debugPrint(
        'NotificationChannel.updateOngoingData: native plugin not available',
      );
    } on PlatformException catch (e) {
      debugPrint('NotificationChannel.updateOngoingData failed: $e');
    }
  }

  /// Sync all reminder schedule times to native for alarm scheduling.
  /// Each entry is a {'hour': int, 'minute': int} map.
  static Future<void> syncReminders(List<Map<String, int>> schedules) async {
    try {
      final jsonEntries = schedules
          .map((s) => '{"hour":${s["hour"]},"minute":${s["minute"]}}')
          .join(',');
      await _channel.invokeMethod('syncReminders', {
        'schedulesJson': '[$jsonEntries]',
      });
    } on MissingPluginException {
      debugPrint(
        'NotificationChannel.syncReminders: native plugin not available',
      );
    } on PlatformException catch (e) {
      debugPrint('NotificationChannel.syncReminders failed: $e');
    }
  }

  static Future<void> scheduleDailyNotification({
    int morningHour = 8,
    int afternoonHour = 13,
    int nightHour = 21,
  }) async {
    try {
      await _channel.invokeMethod('scheduleDailyNotification', {
        'morningHour': morningHour,
        'afternoonHour': afternoonHour,
        'nightHour': nightHour,
      });
    } on MissingPluginException {
      debugPrint(
        'NotificationChannel.scheduleDailyNotification: native plugin not available',
      );
    } on PlatformException catch (e) {
      debugPrint('NotificationChannel.scheduleDailyNotification failed: $e');
    }
  }

  static Future<void> cancelDailyNotification() async {
    try {
      await _channel.invokeMethod('cancelDailyNotification');
    } on MissingPluginException {
      debugPrint(
        'NotificationChannel.cancelDailyNotification: native plugin not available',
      );
    } on PlatformException catch (e) {
      debugPrint('NotificationChannel.cancelDailyNotification failed: $e');
    }
  }

  static Future<void> setFullScreenIntentEnabled(bool enabled) async {
    try {
      await _channel.invokeMethod('setFullScreenIntentEnabled', {
        'enabled': enabled,
      });
    } on MissingPluginException {
      debugPrint(
        'NotificationChannel.setFullScreenIntentEnabled: native plugin not available',
      );
    } on PlatformException catch (e) {
      debugPrint('NotificationChannel.setFullScreenIntentEnabled failed: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> checkPendingAddWater() async {
    try {
      final json = await _channel.invokeMethod<String>('checkPendingAddWater');
      if (json == null || json.isEmpty) return [];

      try {
        final List<dynamic> list = await compute(_parseJson, json);
        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      } catch (e) {
        debugPrint('checkPendingAddWater.parse error: $e');
        return [];
      }
    } on MissingPluginException {
      debugPrint(
        'NotificationChannel.checkPendingAddWater: native plugin not available',
      );
      return [];
    } on PlatformException catch (e) {
      debugPrint('NotificationChannel.checkPendingAddWater failed: $e');
      return [];
    }
  }

  static List<dynamic> _parseJson(String json) {
    return jsonDecode(json);
  }
}

