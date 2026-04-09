import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class WidgetChannel {
  static const _channel = MethodChannel('com.amobi.drinkwater/widget');

  static Future<void> updateWidgetData({
    required int currentMl,
    required int goalMl,
    String? nextReminderTime,
    List<Map<String, String>>? recentDrinks,
    String volumeUnit = 'ml',
    Map<String, String>? labels,
  }) async {
    try {
      await _channel.invokeMethod('updateWidgetData', {
        'currentMl': currentMl,
        'goalMl': goalMl,
        'nextReminderTime': nextReminderTime,
        'recentDrinks': recentDrinks,
        'volumeUnit': volumeUnit,
        'labels': labels,
      });
    } on MissingPluginException {
      debugPrint('WidgetChannel.updateWidgetData: native plugin not available');
    } on PlatformException catch (e) {
      debugPrint('WidgetChannel.updateWidgetData failed: $e');
    }
  }

  /// Requests the system to pin a widget to the home screen.
  /// [widgetType] must be one of: small_a, small_b, medium_a, medium_b, large
  /// Returns true if the request was sent (Android 8.0+), false otherwise.
  static Future<bool> requestPinWidget(String widgetType) async {
    try {
      final result = await _channel.invokeMethod<bool>('requestPinWidget', {
        'widgetType': widgetType,
      });
      return result ?? false;
    } on MissingPluginException {
      debugPrint('WidgetChannel.requestPinWidget: native plugin not available');
      return false;
    } on PlatformException catch (e) {
      debugPrint('WidgetChannel.requestPinWidget failed: $e');
      return false;
    }
  }
}

