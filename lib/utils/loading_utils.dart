import 'package:waternudge/values/onboarding_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingUtils {
  static void show() {
    if (Get.isDialogOpen ?? false) return;

    final context = Get.overlayContext ?? Get.context;
    if (context == null) return;
    final ob = OnboardingTheme.of(context);
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator(color: ob.textPrimary)),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.3),
    );
  }

  /// Hides the currently visible loading overlay.
  static void hide() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  static Widget widget(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Center(child: CircularProgressIndicator(color: ob.textPrimary));
  }
}
