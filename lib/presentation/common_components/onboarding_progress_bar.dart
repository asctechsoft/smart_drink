import 'package:dsp_base/app_material.dart';
import 'package:waternudge/values/app_colors.dart';

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
    return AppColumn(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 48,
          width: double.infinity,
          child: onBack == null
              ? null
              : Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 4),
                    child: AppIcon(
                      'assets/images/svg/ic_back_left.svg',
                      tint: AppColors.basic500,
                      autoMirror: true,
                      size: 24,
                      onClick: onBack,
                    ),
                  ),
                ),
        ),
        AppSpacerH8,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 44),
          child: _StepTrack(currentStep: currentStep, totalSteps: totalSteps),
        ),
      ],
    );
  }
}

class _StepTrack extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepTrack({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < totalSteps; i++) {
      children.add(
        _StepDot(reached: i < currentStep, isCurrent: i == currentStep - 1),
      );
      if (i < totalSteps - 1) {
        children.add(Expanded(child: _StepLine(active: i < currentStep - 1)));
      }
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}

class _StepDot extends StatelessWidget {
  final bool reached;
  final bool isCurrent;

  const _StepDot({required this.reached, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final size = isCurrent ? 12.0 : 9.0;
    return SizedBox(
      width: 16,
      height: 16,
      child: Center(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: reached
                ? AppColors.basic500
                : AppColors.basic500.withValues(alpha: 0.28),
            boxShadow: reached
                ? [
                    BoxShadow(
                      color: AppColors.basic500.withValues(
                        alpha: isCurrent ? 0.9 : 0.5,
                      ),
                      blurRadius: isCurrent ? 14 : 8,
                      spreadRadius: isCurrent ? 2 : 0,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool active;

  const _StepLine({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: active ? 3 : 2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: active
            ? AppColors.basic500
            : AppColors.basic500.withValues(alpha: 0.22),
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppColors.basic500.withValues(alpha: 0.65),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
    );
  }
}
