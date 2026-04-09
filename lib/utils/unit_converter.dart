import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  static String formatTime(String timeStr, String format) {
    if (timeStr.isEmpty) return '';
    
    bool use24h = format == '24h';
    if (format == 'system') {
      final context = Get.context;
      if (context != null) {
        use24h = MediaQuery.of(context).alwaysUse24HourFormat;
      }
    }

    if (use24h) return timeStr;

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


