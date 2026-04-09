import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Resolves onboarding colors based on the current brightness.
class OnboardingTheme {
  final bool isLight;
  const OnboardingTheme._(this.isLight);

  factory OnboardingTheme.of(BuildContext context) {
    return OnboardingTheme._(Theme.of(context).brightness == Brightness.light);
  }

  Color get accent =>
      isLight ? AppColors.primary500Light : AppColors.primary500;

  Color get textPrimary => isLight ? AppColors.neutral500 : AppColors.basic500;

  Color get textSecondary =>
      isLight ? AppColors.neutral300 : AppColors.basic300;

  Color get sheetBg =>
      isLight ? AppColors.bottomSheetBgLight : AppColors.bottomSheetBgDark;

  Color get divider => isLight
      ? AppColors.onboardingLightTextPrimary.withValues(alpha: 0.1)
      : Colors.white.withValues(alpha: 0.1);

  Color get cardBorderSelected => isLight
      ? AppColors.onboardingLightCardBorderSelected
      : AppColors.onboardingCardBorderSelected;

  Color get cardBorderUnselected => isLight
      ? AppColors.onboardingLightCardBorderUnselected
      : AppColors.onboardingCardBorderUnselected;

  //   Color get switchTrack =>
  //       isLight ? AppColors.onboardingLightAccent : AppColors.onboardingAccent;

  Color get buttonStart => isLight
      ? AppColors.onboardingLightButtonStart
      : AppColors.onboardingButtonStart;

  Color get buttonEnd => isLight
      ? AppColors.onboardingLightButtonEnd
      : AppColors.onboardingButtonEnd;

  Color get buttonBorder => isLight
      ? AppColors.onboardingLightButtonBorder
      : AppColors.onboardingButtonBorder;

  Color get scaffoldBg => isLight
      ? AppColors.onboardingLightGradientStart
      : AppColors.onboardingGradientStart;

  Color get bgOption => isLight ? AppColors.basic300 : AppColors.neutral300;

  Color get bgTimeCycle => isLight ? AppColors.basic300 : AppColors.basic100;

  Color get bgOptionSelected =>
      isLight ? AppColors.neutral100 : AppColors.basic100;

  Color get bgOnboarding => isLight ? AppColors.basic200 : AppColors.basic100;

  /// Subtitle dưới section title: "Based on your sleep and meal schedule"
  Color get textSubtitle =>
      isLight ? AppColors.onboardingLightTextSecondary : AppColors.basic300;

  /// Giá trị nổi bật cyan: "06:00 AM"
  Color get textAccent =>
      isLight ? AppColors.onboardingLightAccent : AppColors.onboardingAccent;

  Color get bgBottomNavBar =>
      isLight ? AppColors.basic200 : AppColors.neutral200;

  Color get textBottomNavBar =>
      isLight ? Color(0xFF52557A).withValues(alpha: 0.75) : AppColors.basic300;

  Color get textActiveBottomNavBar =>
      isLight ? AppColors.primary500Light : AppColors.primary500Dark;

  Color get switchActive =>
      isLight ? AppColors.primary500Light : AppColors.primary500Dark;

  Color get switchTrack =>
      isLight ? AppColors.neutral200 : AppColors.neutral300;

  Color get bgToggle => isLight ? AppColors.basic300 : AppColors.neutral300;
  Color get borderToggle => isLight
      ? AppColors.primary500Light.withValues(alpha: 0.15)
      : AppColors.basic500.withValues(alpha: 0.15);
  Color get textToggleActive =>
      isLight ? AppColors.basic500 : AppColors.neutral500;

  Color get textrReminder =>
      isLight ? AppColors.danger500 : AppColors.danger300;

  Color get textrReminderCountdown =>
      isLight ? AppColors.neutral300 : AppColors.basic300;

  Color get bgButtonStart => isLight
      ? AppColors.onboardingLightButtonStart
      : AppColors.onboardingButtonStart;

  Color get bgButtonEnd => isLight
      ? AppColors.onboardingLightButtonEnd
      : AppColors.onboardingButtonEnd;

  Color get borderOption =>
      isLight ? AppColors.primary200Light : AppColors.primary200;
  // Today
  Color get bgReminderPill =>
      isLight ? AppColors.basic300 : AppColors.neutral300;
  Color get borderReminderPill => isLight
      ? AppColors.primary500Light.withValues(alpha: 0.15)
      : AppColors.primary500Dark.withValues(alpha: 0.15);
  Color get textReminderIcon =>
      isLight ? AppColors.danger500 : AppColors.danger300;

  Color get bgDrag => isLight ? AppColors.neutral200 : AppColors.basic200;

  Color get bgBottomSheet =>
      isLight ? AppColors.bottomSheetBgLight : AppColors.bottomSheetBgDark;
  Color get bgToast =>
      isLight ? AppColors.basic500 : AppColors.bottomSheetBgDark;

  Color get iconPill =>
      isLight ? AppColors.primary500Light : AppColors.basic500;

  Color get bgDrinkItem => isLight ? AppColors.basic300 : AppColors.neutral300;

  Color get textPercentDrinkItem =>
      isLight ? AppColors.neutral400 : AppColors.basic400;

  Color get iconAmountWater =>
      isLight ? AppColors.neutral500 : AppColors.basic500;

  Gradient get gradientChart =>
      isLight ? AppColors.gradientButton1 : AppColors.gradientButton2;

  Color get bgHeaderIAP => isLight ? AppColors.basic500 : AppColors.bgHeaderIAP;

  LinearGradient get gradientIAP =>
      isLight ? AppColors.gradientIAPLight : AppColors.gradientIAPDark;

  Color get bgCardIAP => isLight ? AppColors.basic200 : AppColors.basic200;
  Color get bgReminderOption =>
      isLight ? AppColors.basic200 : AppColors.neutral300;

  Color get borderTab => isLight
      ? AppColors.primary500Light.withValues(alpha: 0.25)
      : AppColors.primary500Dark.withValues(alpha: 0.15);

  Color get borderTabHistory => isLight
      ? AppColors.primary500Dark.withValues(alpha: 0.35)
      : AppColors.primary500Dark.withValues(alpha: 0.15);

  Color get waterWave1 => isLight
      ? AppColors.waterWave1Light.withValues(alpha: 0.2)
      : AppColors.waterWave1Dark.withValues(alpha: 0.2);
  Color get waterWave2 => isLight
      ? AppColors.waterWave2Light.withValues(alpha: 0.5)
      : AppColors.waterWave2Dark.withValues(alpha: 0.2);
  Color get waterWave3 => isLight
      ? AppColors.waterWave3Light.withValues(alpha: 0.5)
      : AppColors.waterWave3Dark.withValues(alpha: 0.25);
}

