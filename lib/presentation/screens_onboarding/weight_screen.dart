import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/onboarding_controller.dart';
import 'package:smartdrinkai/presentation/common_components/onboarding_background.dart';
import 'package:smartdrinkai/presentation/common_components/onboarding_progress_bar.dart';
import 'package:smartdrinkai/presentation/common_components/onboarding_step_header.dart';
import 'package:smartdrinkai/presentation/common_components/primary_button.dart';
import 'package:smartdrinkai/presentation/common_components/ruler_picker.dart';
import 'package:smartdrinkai/presentation/common_components/toggle_selector.dart';
import 'package:smartdrinkai/values/route_name.dart';
import 'package:get/get.dart';

class WeightScreen extends StatelessWidget {
  const WeightScreen({super.key});

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
                currentStep: 3,
                totalSteps: 6,
                onBack: () => Get.back(),
              ),
              Expanded(
                child: AppColumn(
                  modifier: Modifier.paddingAll(24),
                  children: [
                    OnboardingStepHeader(
                      title: 'weight'.tr,
                      subtitle: 'personalize_your_water_needs'.tr,
                    ),
                    AppSpacerH16,
                    Obx(
                      () => ToggleSelector(
                        options: const ['kg', 'lb'],
                        selectedIndex: controller.weightUnit.value == 'kg'
                            ? 0
                            : 1,
                        onGradient: true,
                        onChanged: (i) =>
                            controller.updateWeightUnit(i == 0 ? 'kg' : 'lb'),
                      ),
                    ),
                    AppSpacerH16,
                    Obx(() {
                      final isKg = controller.weightUnit.value == 'kg';
                      return RulerPicker(
                        key: ValueKey(controller.weightUnit.value),
                        minValue: isKg ? 20 : 44,
                        maxValue: isKg ? 200 : 441,
                        initialValue: controller.weight.value.round(),
                        unit: controller.weightUnit.value,
                        onChanged: (v) =>
                            controller.weight.value = v.toDouble(),
                      );
                    }),
                    const Spacer(),
                    PrimaryButton(
                      text: 'next'.tr,
                      width: double.infinity,
                      useGradient: true,
                      onPressed: () {
                        controller.nextStep();
                        Get.toNamed(RouteName.onboardingWeather);
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
