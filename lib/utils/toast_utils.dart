import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';

import 'package:smartdrinkai/controller/settings_controller.dart';
import 'package:smartdrinkai/utils/unit_converter.dart';
import 'package:get/get.dart';

class ToastUtils {
  static void showToast(BuildContext context, String message) {
    showCustomToast(context, message);
  }

  static void showLimitToast(BuildContext context) {
    final volumeUnit = Get.find<SettingsController>().volumeUnit.value;
    final limitLabel = volumeUnit == 'oz'
        ? '${UnitConverter.mlToOz(8000).round()} oz'
        : '8000 ml';
    showCustomToast(
      context,
      'the_target_cannot_exceed'.trParams({'args1': limitLabel}),
    );
  }

  static void showSuccessRatingToast(BuildContext context) {
    showCustomToast(context, 'thank_you'.tr);
  }

  static void showSuccessFeedbackToast(BuildContext context) {
    showCustomToast(context, 'your_feedback_has_been_sent'.tr);
  }

  static void showCustomToast(BuildContext context, String message) {
    final safeContext = Get.context ?? context;
    if (!safeContext.mounted) return;
    
    final ob = OnboardingTheme.of(safeContext);

    final toast = Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.only(top: kToolbarHeight),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: ob.bgToast,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon('assets/images/webp/img_logo.webp', size: 24),
            AppSpacerW4,
            Flexible(
              child: AppText(
                message,
                style: TextStyle(
                  color: ob.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );

    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.showSnackbar(GetSnackBar(
      backgroundColor: Colors.transparent,
      snackPosition: SnackPosition.TOP,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      duration: const Duration(seconds: 3),
      messageText: toast,
    ));
  }
}

