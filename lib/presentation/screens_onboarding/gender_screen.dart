import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/onboarding_controller.dart';
import 'package:smartdrinkai/presentation/common_components/gender_card.dart';
import 'package:smartdrinkai/presentation/common_components/onboarding_background.dart';
import 'package:smartdrinkai/presentation/common_components/onboarding_progress_bar.dart';
import 'package:smartdrinkai/presentation/common_components/onboarding_step_header.dart';
import 'package:smartdrinkai/presentation/common_components/primary_button.dart';
import 'package:smartdrinkai/values/route_name.dart';
import 'package:get/get.dart';

class GenderScreen extends StatelessWidget {
  const GenderScreen({super.key});

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
                currentStep: 1,
                totalSteps: 6,
                onBack: null,
              ),
              Expanded(
                child: AppColumn(
                  modifier: Modifier.paddingAll(24),
                  children: [
                    OnboardingStepHeader(
                      title: 'select_your_gender'.tr,
                      subtitle: 'personalize_your_water_needs'.tr,
                    ),
                    AppSpacerH40,
                    Obx(
                      () => AppRow(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GenderCard(
                            label: 'male',
                            icon: 'assets/images/webp/img_men.webp',
                            isSelected: controller.gender.value == 'male',
                            onTap: () => controller.gender.value = 'male',
                          ),
                          AppSpacerW16,
                          GenderCard(
                            label: 'female',
                            icon: 'assets/images/webp/img_women.webp',
                            isSelected: controller.gender.value == 'female',
                            onTap: () => controller.gender.value = 'female',
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Obx(
                      () => PrimaryButton(
                        text: 'next'.tr,
                        width: double.infinity,
                        useGradient: true,
                        enabled: controller.gender.value.isNotEmpty,
                        onPressed: () {
                          controller.nextStep();
                          Get.toNamed(RouteName.onboardingHeight);
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
}
