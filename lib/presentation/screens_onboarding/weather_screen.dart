import 'package:dsp_base/app_material.dart';
import 'package:get/get.dart';
import 'package:waternudge/controller/onboarding_controller.dart';
import 'package:waternudge/models/ui_models/weather_condition.dart';
import 'package:waternudge/presentation/common_components/onboarding_background.dart';
import 'package:waternudge/presentation/common_components/stagger_reveal.dart';
import 'package:waternudge/presentation/common_components/onboarding_progress_bar.dart';
import 'package:waternudge/presentation/common_components/primary_button.dart';
import 'package:waternudge/presentation/common_components/selectable_option_tile.dart';
import 'package:waternudge/values/app_colors.dart';
import 'package:waternudge/values/route_name.dart';

/// Weather affects the daily goal, so it is asked right after weight.
class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  static const _options = <WeatherCondition, String>{
    WeatherCondition.hot: 'assets/images/svg/ic_wather_hot.svg',
    WeatherCondition.normal: 'assets/images/svg/ic_wather_normal.svg',
    WeatherCondition.cold: 'assets/images/svg/ic_wather_cold.svg',
  };

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
                currentStep: 4,
                totalSteps: 6,
                onBack: () => Get.back(),
              ),
              Expanded(
                child: StaggerColumn(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _buildTitle(),
                    AppSpacerH20,
                    _buildHint(),
                    AppSpacerH24,
                    Obx(
                      () => AppColumn(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        spacing: 12,
                        children: _options.entries
                            .map(
                              (entry) => SelectableOptionTile(
                                icon: entry.value,
                                label: entry.key.label.tr,
                                isSelected:
                                    controller.weather.value == entry.key,
                                onTap: () =>
                                    controller.weather.value = entry.key,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const Spacer(),
                    Obx(
                      () => PrimaryButton(
                        text: 'next'.tr,
                        width: double.infinity,
                        useGradient: true,
                        enabled: controller.weather.value != null,
                        onPressed: () {
                          controller.calculateGoalFromWeight();
                          controller.nextStep();
                          Get.toNamed(RouteName.onboardingWakeup);
                        },
                      ),
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

  Widget _buildTitle() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.basic500,
          height: 1.35,
        ),
        children: [
          TextSpan(text: '${'weather_question'.tr} '),
          TextSpan(
            text: 'weather_question_highlight'.tr,
            style: const TextStyle(color: AppColors.accentTeal),
          ),
        ],
      ),
    );
  }

  Widget _buildHint() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.neutral500.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.basic500.withValues(alpha: 0.14)),
      ),
      child: AppRow(
        children: [
          const AppText('🌍', style: TextStyle(fontSize: 26)),
          AppSpacerW12,
          Expanded(
            child: AppText(
              'weather_hint'.tr,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.basic500.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
