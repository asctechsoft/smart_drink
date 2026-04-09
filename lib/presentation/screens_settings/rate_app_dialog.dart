import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/settings_controller.dart';
import 'package:smartdrinkai/presentation/common_components/primary_button.dart';
import 'package:smartdrinkai/presentation/common_components/primary_dialog.dart';
import 'package:smartdrinkai/utils/toast_utils.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';

Future<void> showRateAppDialog(BuildContext context) {
  return PrimaryDialog.show(
    context: context,
    padding: EdgeInsets.zero,
    content: const _RateAppDialogContent(),
  );
}

class _RateAppDialogContent extends StatelessWidget {
  const _RateAppDialogContent();

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return AppColumn(
      modifier: Modifier.padding(horizontal: 16, vertical: 24),
      mainAxisSize: MainAxisSize.min,
      children: [
        // Star illustration (using webp image)
        Image.asset(
          'assets/images/webp/img_rate.webp',
          height: 140,
          fit: BoxFit.contain,
        ),
        AppSpacerH24,
        // Text
        AppText(
          'rate_app_content'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: ob.textPrimary,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w400,
          ),
        ),
        AppSpacerH(24),
        // Buttons
        AppRow(
          children: [
            Expanded(
              child: PrimaryButton(
                text: 'later'.tr,
                outlined: true,
                onPressed: () => Navigator.of(context).pop(),
                height: 44,
              ),
            ),
            const AppSpacerW(12),
            Expanded(
              child: PrimaryButton(
                text: 'rate_us_5_stars'.tr,
                useGradient: true,
                autoSizeText: true,
                onPressed: () {
                  Get.find<SettingsController>().setRated();
                  ToastUtils.showSuccessRatingToast(context);
                  Navigator.of(context).pop();
                  _requestReview();
                },
                height: 44,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Future<void> _requestReview() async {
    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    } else {
      await inAppReview.openStoreListing();
    }
  }
}

