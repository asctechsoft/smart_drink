import 'package:dsp_base/app_material.dart';
import 'package:waternudge/controller/onboarding_controller.dart';
import 'package:waternudge/presentation/common_components/onboarding_background.dart';
import 'package:waternudge/presentation/common_components/stagger_reveal.dart';
import 'package:waternudge/presentation/common_components/onboarding_progress_bar.dart';
import 'package:waternudge/presentation/common_components/onboarding_step_header.dart';
import 'package:waternudge/presentation/common_components/primary_button.dart';
import 'package:waternudge/presentation/common_components/ruler_picker.dart';
import 'package:waternudge/presentation/common_components/toggle_selector.dart';
import 'package:waternudge/values/route_name.dart';
import 'package:get/get.dart';

class HeightScreen extends StatelessWidget {
  const HeightScreen({super.key});

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
                currentStep: 2,
                totalSteps: 6,
                onBack: () => Get.back(),
              ),
              Expanded(
                child: StaggerColumn(
                  padding: const EdgeInsets.all(24),
                  children: [
                    OnboardingStepHeader(
                      title: 'height'.tr,
                      subtitle: 'personalize_your_water_needs'.tr,
                    ),
                    AppSpacerH16,
                    Obx(
                      () => ToggleSelector(
                        options: const ['cm', 'm'],
                        selectedIndex: controller.heightUnit.value == 'cm'
                            ? 0
                            : 1,
                        onGradient: true,
                        onChanged: (i) =>
                            controller.updateHeightUnit(i == 0 ? 'cm' : 'm'),
                      ),
                    ),
                    AppSpacerH16,
                    Obx(() {
                      final isCm = controller.heightUnit.value == 'cm';
                      final cm = isCm
                          ? controller.height.value.round()
                          : (controller.height.value * 100).round();
                      return RulerPicker(
                        key: ValueKey(controller.heightUnit.value),
                        minValue: 100,
                        maxValue: 250,
                        initialValue: cm,
                        unit: controller.heightUnit.value,
                        labelBuilder: isCm
                            ? null
                            : (v) => (v / 100).toStringAsFixed(2),
                        onChanged: (v) => controller.height.value = isCm
                            ? v.toDouble()
                            : v / 100,
                      );
                    }),
                    const Spacer(),
                    PrimaryButton(
                      text: 'next'.tr,
                      width: double.infinity,
                      useGradient: true,
                      onPressed: () {
                        controller.nextStep();
                        Get.toNamed(RouteName.onboardingWeight);
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
