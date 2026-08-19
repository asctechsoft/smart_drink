import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/values/app_colors.dart';

class OnboardingStepHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const OnboardingStepHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AppColumn(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.basic500,
            letterSpacing: 0.3,
          ),
        ),
        AppSpacerH8,
        AppText(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.basic500.withValues(alpha: 0.72),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
