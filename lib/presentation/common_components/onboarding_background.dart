import 'package:smartdrinkai/values/app_colors.dart';
import 'package:flutter/material.dart';

class OnboardingBackground extends StatelessWidget {
  final Widget child;

  const OnboardingBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: isLight
            ? AppColors.gradientBgLight
            : AppColors.gradientBgDark,
      ),
      child: child,
    );
  }
}

