import 'package:dsp_base/app_material.dart';
import 'package:waternudge/controller/onboarding_controller.dart';
import 'package:waternudge/presentation/common_components/circular_time_picker.dart';
import 'package:waternudge/presentation/common_components/onboarding_background.dart';
import 'package:waternudge/presentation/common_components/stagger_reveal.dart';
import 'package:waternudge/presentation/common_components/onboarding_progress_bar.dart';
import 'package:waternudge/presentation/common_components/onboarding_step_header.dart';
import 'package:waternudge/presentation/common_components/primary_button.dart';
import 'package:waternudge/utils/toast_utils.dart';
import 'package:waternudge/values/route_name.dart';
import 'package:get/get.dart';

class BedtimeScreen extends StatelessWidget {
  const BedtimeScreen({super.key});

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
                currentStep: 7,
                totalSteps: 7,
                onBack: () => Get.back(),
              ),
              Expanded(
                child: StaggerColumn(
                  padding: const EdgeInsets.all(24),
                  children: [
                    OnboardingStepHeader(
                      title: 'what_time_do_you_go_to_bed'.tr,
                      subtitle: 'helps_remind_you_to_drink_water'.tr,
                    ),
                    AppSpacerH40,
                    CircularTimePicker(
                      initialTime: controller.bedTime.value,
                      isNight: true,
                      onChanged: (time) => controller.bedTime.value = time,
                    ),
                    const Spacer(),
                    PrimaryButton(
                      text: 'start'.tr,
                      width: double.infinity,
                      useGradient: true,
                      onPressed: () {
                        if (controller.wakeUpTime.value ==
                            controller.bedTime.value) {
                          ToastUtils.showToast(
                            context,
                            'wake_up_and_bedtime_cannot_be_same'.tr,
                          );
                          return;
                        }
                        Get.toNamed(RouteName.onboardingBuildingSchedule);
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
