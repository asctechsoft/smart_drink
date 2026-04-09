import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/onboarding_controller.dart';
import 'package:smartdrinkai/presentation/common_components/onboarding_progress_bar.dart';
import 'package:smartdrinkai/presentation/common_components/primary_button.dart';
import 'package:smartdrinkai/presentation/common_components/toggle_selector.dart';
import 'package:smartdrinkai/presentation/common_components/water_wave_background.dart';
import 'package:smartdrinkai/presentation/common_components/wheel_picker.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:smartdrinkai/values/route_name.dart';
import 'package:get/get.dart';

class WeightScreen extends StatelessWidget {
  const WeightScreen({super.key});

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
            currentStep: 2,
            totalSteps: 4,
            onBack: () => Get.back(),
          ),
        ),
        body: SafeArea(
          child: AppColumn(
            modifier: Modifier.paddingAll(24),
            children: [
              AppText(
                'weight'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ob.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              AppSpacerH24,
              Obx(
                () => ToggleSelector(
                  options: const ['kg', 'lb'],
                  selectedIndex: controller.weightUnit.value == 'kg' ? 0 : 1,
                  onChanged: (i) =>
                      controller.updateWeightUnit(i == 0 ? 'kg' : 'lb'),
                ),
              ),
              AppSpacerH24,
              Obx(() {
                final isKg = controller.weightUnit.value == 'kg';
                return WheelPicker(
                  key: ValueKey(controller.weightUnit.value),
                  minValue: isKg ? 20 : 44,
                  maxValue: isKg ? 200 : 441,
                  initialValue: controller.weight.value.round(),
                  onChanged: (v) => controller.weight.value = v.toDouble(),
                  suffix: controller.weightUnit.value,
                  showIndicator: true,
                  colorBorder: ob.bgOnboarding,
                );
              }),
              const Spacer(),
              PrimaryButton(
                text: 'next'.tr,
                useGradient: true,
                width: double.infinity,
                onPressed: () {
                  controller.calculateGoalFromWeight();
                  controller.nextStep();
                  Get.toNamed(RouteName.onboardingWakeup);
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

