import 'package:flutter/material.dart';
import 'package:waternudge/controller/onboarding_controller.dart';
import 'package:waternudge/presentation/common_components/gender_card.dart';
import 'package:waternudge/presentation/common_components/onboarding_background.dart';
import 'package:waternudge/presentation/common_components/onboarding_progress_bar.dart';
import 'package:waternudge/presentation/common_components/onboarding_step_header.dart';
import 'package:waternudge/presentation/common_components/stagger_reveal.dart';
import 'package:waternudge/presentation/common_components/primary_button.dart';
import 'package:waternudge/utils/analytics.dart';
import 'package:waternudge/values/route_name.dart';
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
          child: Column(
            children: [
              OnboardingProgressBar(
                currentStep: 1,
                totalSteps: 7,
                onBack: null,
              ),
              Expanded(
                child: StaggerColumn(
                  padding: const EdgeInsets.all(24),
                  children: [
                    OnboardingStepHeader(
                      title: 'select_your_gender'.tr,
                      subtitle: 'personalize_your_water_needs'.tr,
                    ),
                    const SizedBox(height: 40),
                    Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GenderCard(
                            label: 'male',
                            icon: 'assets/images/webp/img_men.webp',
                            isSelected: controller.gender.value == 'male',
                            onTap: () {
                              controller.gender.value = 'male';
                              Analytics.onboardingGenderSelect('male');
                            },
                          ),
                          const SizedBox(width: 16),
                          GenderCard(
                            label: 'female',
                            icon: 'assets/images/webp/img_women.webp',
                            isSelected: controller.gender.value == 'female',
                            onTap: () {
                              controller.gender.value = 'female';
                              Analytics.onboardingGenderSelect('female');
                            },
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
                          Analytics.onboardingNext('gender');
                          controller.nextStep();
                          Get.toNamed(RouteName.onboardingHeight);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
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
