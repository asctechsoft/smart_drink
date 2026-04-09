import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/onboarding_controller.dart';
import 'package:smartdrinkai/presentation/common_components/gender_card.dart';
import 'package:smartdrinkai/presentation/common_components/onboarding_progress_bar.dart';
import 'package:smartdrinkai/presentation/common_components/primary_button.dart';
import 'package:smartdrinkai/presentation/common_components/water_wave_background.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:smartdrinkai/values/route_name.dart';
import 'package:get/get.dart';

class GenderScreen extends StatelessWidget {
  const GenderScreen({super.key});

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
            currentStep: 1,
            totalSteps: 4,
            onBack: () => Get.back(),
          ),
        ),
        body: SafeArea(
          child: AppColumn(
            modifier: Modifier.paddingAll(24),
            children: [
              AppText(
                'select_your_gender'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ob.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              AppSpacerH(80),
              Obx(
                () => AppRow(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GenderCard(
                      label: 'male',
                      icon: 'assets/images/webp/ic_male.webp',
                      isSelected: controller.gender.value == 'male',
                      onTap: () => controller.gender.value = 'male',
                    ),
                    AppSpacerW20,
                    GenderCard(
                      label: 'female',
                      icon: 'assets/images/webp/ic_female.webp',
                      isSelected: controller.gender.value == 'female',
                      onTap: () => controller.gender.value = 'female',
                    ),
                  ],
                ),
              ),
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
      ),
    );
  }
}

