import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/onboarding_controller.dart';
import 'package:smartdrinkai/presentation/common_components/onboarding_progress_bar.dart';
import 'package:smartdrinkai/presentation/common_components/primary_button.dart';
import 'package:smartdrinkai/presentation/common_components/water_wave_background.dart';
import 'package:smartdrinkai/presentation/common_components/wheel_time_picker.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:smartdrinkai/values/route_name.dart';
import 'package:get/get.dart';

class WakeupScreen extends StatelessWidget {
  const WakeupScreen({super.key});

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
            currentStep: 3,
            totalSteps: 4,
            onBack: () => Get.back(),
          ),
        ),
        body: SafeArea(
          child: AppColumn(
            modifier: Modifier.paddingAll(24),
            children: [
              AppText(
                'what_time_do_you_wake_up'.tr,
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
                  initialTime: controller.wakeUpTime.value,
                  onChanged: (time) => controller.wakeUpTime.value = time,
                  colorBorder: ob.bgOnboarding,
                ),
              ),
              const Spacer(),
              PrimaryButton(
                text: 'next'.tr,
                width: double.infinity,
                useGradient: true,
                onPressed: () {
                  controller.nextStep();
                  Get.toNamed(RouteName.onboardingBedtime);
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

