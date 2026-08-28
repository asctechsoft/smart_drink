import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class UnitConverter {
  static double mlToOz(double ml) => ml * 0.033814;
  static double ozToMl(double oz) => oz / 0.033814;

  static double kgToLb(double kg) => kg * 2.20462;
  static double lbToKg(double lb) => lb / 2.20462;

  static double cmToM(double cm) => cm / 100;
  static double mToCm(double m) => m * 100;

  static String formatVolumeValue(double ml, String unit) {
    if (unit == 'oz') {
      double oz = mlToOz(ml);
      return oz.toStringAsFixed(2).replaceAll(RegExp(r'\.?0*$'), '');
    }
    return ml.round().toString();
  }

  static String formatVolumeValueUnit(double ml, String unit) {
    if (unit == 'oz') {
      double oz = mlToOz(ml);
      String val = oz.toStringAsFixed(2).replaceAll(RegExp(r'\.?0*$'), '');
      return '$val oz';
    }
    return '${ml.round()} ml';
  }

  /// Same as [formatVolumeValueUnit] but with locale-aware thousand
  /// separators, for the large period totals on the history screen
  /// ("43.250 ml" in Vietnamese, "43,250 ml" in English).
  static String formatVolumeGrouped(double ml, String unit) {
    final locale = Get.locale?.toString();
    if (unit == 'oz') {
      final oz = mlToOz(ml);
      final fmt = NumberFormat('#,##0.#', locale);
      return '${fmt.format(oz)} oz';
    }
    return '${NumberFormat('#,##0', locale).format(ml.round())} ml';
  }

  /// Compact axis label for large values: 20000 -> "20K".
  static String formatCompact(double value) {
    if (value.abs() >= 1000) {
      final k = value / 1000;
      final text = k
          .toStringAsFixed(k.abs() < 10 ? 1 : 0)
          .replaceAll(RegExp(r'\.0$'), '');
      return '${text}K';
    }
    return value.round().toString();
  }

  static String formatVolume(double ml, String unit) {
    if (unit == 'oz') {
      final oz = mlToOz(ml);
      return '${oz.toStringAsFixed(2).replaceAll(RegExp(r'\.?0*$'), '')} oz';
    }
    return '${ml.round()} ml';
  }

  static String formatWeight(double weight, String unit) {
    if (unit == 'lb') {
      return '${kgToLb(weight).round()} lb';
    }
    return '${weight.round()} kg';
  }

  static String formatHeight(double height, String unit) {
    if (unit == 'm') {
      return '${cmToM(height).toStringAsFixed(2)} m';
    }
    return '${height.round()} cm';
  }

  /// Whether the device is configured for 24-hour time. The app always follows
  /// the device setting (there is no in-app time format option).
  static bool deviceUses24h() {
    final context = Get.context;
    if (context != null) return MediaQuery.of(context).alwaysUse24HourFormat;
    return true;
  }

  static String formatTime(String timeStr) {
    if (timeStr.isEmpty) return '';

    if (deviceUses24h()) return timeStr;

    final parts = timeStr.split(':');
    if (parts.length != 2) return timeStr;

    int hour = int.tryParse(parts[0]) ?? 0;
    final int minute = int.tryParse(parts[1]) ?? 0;

    final period = hour >= 12 ? 'pm'.tr : 'am'.tr;
    hour = hour % 12;
    if (hour == 0) hour = 12;

    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
}


