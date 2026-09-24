import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    return Column(
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
                    child: _BackIconButton(onTap: onBack!),
                  ),
                ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 44),
          child: _StepTrack(currentStep: currentStep, totalSteps: totalSteps),
        ),
      ],
    );
  }
}

/// The back chevron — mirrored under RTL, wrapped in a tap target matching
/// dsp_base's `AppIcon`'s old `clickZone` (48dp) around a 24dp glyph.
class _BackIconButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackIconButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    Widget icon = SvgPicture.asset(
      'assets/images/svg/ic_back_left.svg',
      width: 24,
      height: 24,
      colorFilter: const ColorFilter.mode(
        AppColors.basic500,
        BlendMode.srcIn,
      ),
    );
    if (Directionality.of(context) == TextDirection.rtl) {
      icon = Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..scale(-1.0, 1, 1),
        child: icon,
      );
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(padding: const EdgeInsets.all(12), child: icon),
      ),
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
