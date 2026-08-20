import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/presentation/common_components/onboarding_background.dart';
import 'package:smartdrinkai/presentation/common_components/primary_button.dart';
import 'package:smartdrinkai/values/app_colors.dart';
import 'package:smartdrinkai/values/route_name.dart';
import 'package:get/get.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: AppColumn(
            modifier: Modifier.paddingAll(24),
            children: [
              AppSpacerH44,
              AppIcon('assets/images/webp/logo_app_v2.webp', size: 300),
              AppText(
                "im_here_to_help_you".tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.basic500,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacerH4,
              AppText(
                'i_need_a_bit_of_information'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.basic500.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              PrimaryButton(
                width: double.infinity,
                text: "lets_go".tr,
                onPressed: () => Get.toNamed(RouteName.onboardingGender),
                useGradient: true,
              ),
              AppSpacerH20,
            ],
          ),
        ),
      ),
    );
  }
}
