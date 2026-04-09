import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/onboarding_controller.dart';
import 'package:smartdrinkai/presentation/common_components/onboarding_progress_bar.dart';
import 'package:smartdrinkai/presentation/common_components/primary_button.dart';
import 'package:smartdrinkai/presentation/common_components/water_wave_background.dart';
import 'package:smartdrinkai/presentation/common_components/wheel_time_picker.dart';
import 'package:smartdrinkai/utils/toast_utils.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:smartdrinkai/values/route_name.dart';
import 'package:get/get.dart';

class BedtimeScreen extends StatelessWidget {
  const BedtimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    final ob = OnboardingTheme.of(context);
    return WaterWaveBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(90),
          child: OnboardingProgressBar(
            currentStep: 4,
            totalSteps: 4,
            onBack: () => Get.back(),
          ),
        ),
        body: SafeArea(
          child: AppColumn(
            modifier: Modifier.paddingAll(24),
            children: [
              AppText(
                'what_time_do_you_go_to_bed'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ob.textPrimary,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacerH(48),

              Obx(
                () => WheelTimePicker(
                  initialTime: controller.bedTime.value,
                  onChanged: (time) => controller.bedTime.value = time,
                  colorBorder: ob.bgOnboarding,
                ),
              ),
              const Spacer(),
              PrimaryButton(
                text: 'next'.tr,
                width: double.infinity,
                useGradient: true,
                onPressed: () {
                  // Kiểm tra thời gian ngủ # thời gia dậy
                  if (controller.wakeUpTime.value == controller.bedTime.value) {
                    ToastUtils.showToast(
                      context,
                      'wake_up_and_bedtime_cannot_be_same'.tr,
                    );
                    return;
                  }
                  Get.toNamed(RouteName.onboardingReminder);
                },
              ),
              AppSpacerH20,
            ],
          ),
        ),
      ),
    );
  }
}

