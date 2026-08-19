import 'package:smartdrinkai/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OnboardingBackground extends StatelessWidget {
  final Widget child;

  const OnboardingBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    // Transparent system bars keep the gradient unbroken behind the status bar
    // and navigation bar; the gradient is dark enough for light icons.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        // Android otherwise paints an opaque scrim behind the buttons, which
        // shows as a light band cutting off the gradient.
        systemNavigationBarContrastEnforced: false,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isLight
              ? AppColors.gradientBgLight
              : AppColors.gradientBgDark,
        ),
        child: child,
      ),
    );
  }
}
