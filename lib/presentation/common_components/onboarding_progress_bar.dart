import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';

class OnboardingProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;

  const OnboardingProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final activeColor = ob.switchActive;
    final inactiveColor = ob.bgOptionSelected;
    final foregroundColor = ob.textPrimary;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Center: dots
        Align(
          alignment: Alignment.center,
          child: AppRow(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalSteps, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Container(
                  width: 28,
                  height: 8,
                  decoration: BoxDecoration(
                    color: index < currentStep ? activeColor : inactiveColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
        ),
        // Left: back button - Adjusted to 4px because AppIcon has built-in 12px padding (clickZone 48 - size 24) / 2
        // So 4px padding + 12px built-in = 16px visual gap
        if (onBack != null)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 4),
              child: AppIcon(
                'assets/images/svg/ic_back_left.svg',
                tint: foregroundColor,
                autoMirror: true,
                size: 24,
                onClick: onBack,
              ),
            ),
          ),
        // Right: step count text - 16px gap
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(end: 16),
            child: AppText(
              '$currentStep/$totalSteps',
              style: TextStyle(
                color: foregroundColor,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

