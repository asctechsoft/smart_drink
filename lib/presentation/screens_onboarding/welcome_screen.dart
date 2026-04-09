import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/presentation/common_components/primary_button.dart';
import 'package:smartdrinkai/presentation/common_components/water_wave_background.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:smartdrinkai/values/route_name.dart';
import 'package:get/get.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return WaterWaveBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: AppColumn(
            modifier: Modifier.paddingAll(24),
            children: [
              AppSpacerH44,
              AppIcon('assets/images/webp/img_water.webp', size: 300),
              AppText(
                "im_here_to_help_you".tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ob.textPrimary,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacerH4,
              AppText(
                'i_need_a_bit_of_information'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: ob.textPrimary,
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

