import 'package:dsp_base/app_material.dart';
import 'package:waternudge/controller/onboarding_controller.dart';
import 'package:waternudge/presentation/common_components/circular_time_picker.dart';
import 'package:waternudge/presentation/common_components/onboarding_background.dart';
import 'package:waternudge/presentation/common_components/stagger_reveal.dart';
import 'package:waternudge/presentation/common_components/onboarding_progress_bar.dart';
import 'package:waternudge/presentation/common_components/onboarding_step_header.dart';
import 'package:waternudge/presentation/common_components/primary_button.dart';
import 'package:waternudge/values/route_name.dart';
import 'package:get/get.dart';

class WakeupScreen extends StatelessWidget {
  const WakeupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: AppColumn(
            children: [
              OnboardingProgressBar(
                currentStep: 5,
                totalSteps: 7,
                onBack: () => Get.back(),
              ),
              Expanded(
                child: StaggerColumn(
                  padding: const EdgeInsets.all(24),
                  children: [
                    OnboardingStepHeader(
                      title: 'what_time_do_you_wake_up'.tr,
                      subtitle: 'helps_remind_you_to_drink_water'.tr,
                    ),
                    AppSpacerH40,
                    CircularTimePicker(
                      initialTime: controller.wakeUpTime.value,
                      isNight: false,
                      onChanged: (time) => controller.wakeUpTime.value = time,
                    ),
                    const Spacer(),
                    PrimaryButton(
                      text: 'next'.tr,
                      width: double.infinity,
                      useGradient: true,
                      onPressed: () {
                        controller.nextStep();
                        Get.toNamed(RouteName.onboardingNap);
                      },
                    ),
                    AppSpacerH20,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
