import 'package:flutter/material.dart';
import 'package:waternudge/controller/onboarding_controller.dart';
import 'package:waternudge/presentation/common_components/wheel_duration_picker.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// Onboarding entry point for the shared interval sheet, so onboarding and the
/// reminder screen show the exact same picker.
class IntervalPickerSheet {
  const IntervalPickerSheet._();

  static void show(BuildContext context, OnboardingController controller) {
    showWheelDurationPicker(
      context,
      title: 'interval'.tr,
      initialMinutes: controller.intervalMinutes.value,
      onSave: (minutes) => controller.intervalMinutes.value = minutes,
    );
  }
}
