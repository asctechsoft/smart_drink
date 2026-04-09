import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/onboarding_controller.dart';
import 'package:smartdrinkai/presentation/common_components/primary_bottom_sheet.dart';
import 'package:smartdrinkai/presentation/common_components/primary_button.dart';
import 'package:smartdrinkai/presentation/common_components/toggle_selector.dart';
import 'package:smartdrinkai/presentation/common_components/water_wave_background.dart';
import 'package:smartdrinkai/presentation/common_components/wheel_picker.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:get/get.dart';

class DailyGoalScreen extends StatelessWidget {
  const DailyGoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    final ob = OnboardingTheme.of(context);
    return WaterWaveBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(90),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Title centered
              AppText(
                'set_daily_goal'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ob.textPrimary,
                  letterSpacing: 0.3,
                ),
              ),
              // Back button on the left
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: AppIcon(
                  'assets/images/svg/ic_back_left.svg',
                  size: 24,
                  onClick: () => Get.back(),
                  tint: ob.textPrimary,
                  autoMirror: true,
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: AppColumn(
            modifier: Modifier.paddingAll(24),
            children: [
              AppText(
                'daily_water_drinking_goal'.tr,
                style: TextStyle(
                  fontSize: 18,
                  color: ob.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacerH(48),
              Stack(
                alignment: Alignment.center,
                children: [
                  AppIcon('assets/images/webp/img_water_big.webp', size: 300),
                  AppColumn(
                    modifier: Modifier.padding(top: 40),
                    children: [
                      Obx(
                        () => AppText(
                          '${controller.dailyGoalMl.value} ${controller.volumeUnit.value}',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      AppIcon(
                        'assets/images/svg/ic_edit_water.svg',
                        size: 32,
                        tint: Colors.white,
                        onClick: () => _showGoalPicker(context, controller),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              PrimaryButton(
                width: double.infinity,
                text: 'start'.tr,
                useGradient: true,
                onPressed: () => controller.completeOnboarding(),
              ),
              AppSpacerH20,
            ],
          ),
        ),
      ),
    );
  }

  void _showGoalPicker(BuildContext context, OnboardingController controller) {
    PrimaryBottomSheet.show(
      context: context,
      title: 'set_daily_goal'.tr,
      buttonText: 'save'.tr,
      content: AppColumn(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () => ToggleSelector(
              options: const ['ml', 'oz'],
              selectedIndex: controller.volumeUnit.value == 'ml' ? 0 : 1,
              onChanged: (i) =>
                  controller.updateVolumeUnit(i == 0 ? 'ml' : 'oz'),
            ),
          ),
          const AppSpacerH(16),
          Obx(() {
            final isMl = controller.volumeUnit.value == 'ml';
            return WheelPicker(
              key: ValueKey(controller.volumeUnit.value),
              minValue: isMl ? 500 : 16,
              maxValue: isMl ? 8000 : 270,
              initialValue: controller.dailyGoalMl.value,
              onChanged: (v) => controller.dailyGoalMl.value = v,
              suffix: controller.volumeUnit.value,
              textColor: Colors.white,
              suffixColor: Colors.white70,
              showIndicator: true,
              step: controller.volumeUnit.value == 'ml' ? 50 : 1,
            );
          }),
        ],
      ),
    );
  }
}

