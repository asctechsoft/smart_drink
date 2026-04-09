import 'package:flutter/material.dart';

class AppColors {
  // Primary water-blue palette
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryContainer = Color(0xFFBBDEFB);

  // Accent
  static const Color accent = Color(0xFF03A9F4);
  static const Color accentLight = Color(0xFFB3E5FC);

  // Background
  static const Color backgroundLight = Color(0xFFF5F9FF);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2C2C2C);

  // Text
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFF9E9E9E);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);

  // Progress ring
  static const Color progressBackground = Color(0xFFE3F2FD);
  static const Color progressFill = Color(0xFF2196F3);

  // Drink type colors
  static const Color water = Color(0xFF2196F3);
  static const Color tea = Color(0xFF8BC34A);
  static const Color coffee = Color(0xFF795548);
  static const Color juice = Color(0xFFFF9800);
  static const Color milk = Color(0xFFFFF9C4);
  static const Color beer = Color(0xFFFFB300);
  static const Color soup = Color(0xFFFF7043);

  // Onboarding dark theme
  static const Color onboardingGradientStart = Color(0xFF000428);
  static const Color onboardingGradientEnd = Color(0xFF004E92);
  static const Color onboardingAccent = Color(0xFF00E0FF);
  static const Color onboardingButtonStart = Color(0xFF0094FF);
  static const Color onboardingButtonEnd = Color(0xFF00E0FF);
  static const Color onboardingButtonBorder = Color(
    0x4000E0FF,
  ); // rgba(0,224,255,0.25)
  static const Color onboardingCardBg = Color(0x80000428); // rgba(0,4,40,0.5)
  static const Color onboardingCardBorderSelected = Color(0xFF00E0FF);
  static const Color onboardingCardBorderUnselected = Color(
    0x2600E0FF,
  ); // rgba(0,224,255,0.15)
  static const Color onboardingProgressActive = Color(0xFF00E0FF);
  static const Color onboardingProgressInactive = Color(
    0x1AFFFFFF,
  ); // rgba(255,255,255,0.1)
  static const Color onboardingTextSecondary = Color(
    0xB3FFFFFF,
  ); // rgba(255,255,255,0.7)

  // Onboarding light theme
  static const Color onboardingLightGradientStart = Color(0xFFA1C4FD);
  static const Color onboardingLightGradientEnd = Color(0xFFC2E9FB);
  static const Color onboardingLightAccent = Color(0xFF0070CC);
  static const Color onboardingLightButtonStart = Color(0xFF00A1FB);
  static const Color onboardingLightButtonEnd = Color(0xFF0063FF);
  static const Color onboardingLightButtonBorder = Color(
    0x400094FF,
  ); // rgba(0,148,255,0.25)
  static const Color onboardingLightCardBg = Color(
    0x40FFFFFF,
  ); // rgba(255,255,255,0.25)
  static const Color onboardingLightCardBorderSelected = Color(0xFF0070CC);
  static const Color onboardingLightCardBorderUnselected = Color(
    0x260070CC,
  ); // rgba(0,112,204,0.15)
  static const Color onboardingLightProgressActive = Color(0xFF0070CC);
  static const Color onboardingLightProgressInactive = Color(
    0x1A000428,
  ); // rgba(0,4,40,0.1)
  static const Color onboardingLightTextPrimary = Color(0xFF000428);
  static const Color onboardingLightTextSecondary = Color(
    0xB3000428,
  ); // rgba(0,4,40,0.7)
  static const Color onboardingLightSheetBg = Color(0xFFD6E8FC);

  static const Color backgroundLightSheetBg = Color(0xFF000428);

  static const Color primary500Dark = Color(0xFF00E0FF);
  static const Color primary400Dark = Color(0xFF3AE6FF);
  static const Color primary300Dark = Color(0xFF75EBFF);
  static const Color primary200Dark = Color(0xFFAFF1FF);
  static const Color primary100Dark = Color(0xFFE9F6FF);

  static const Color primary500Light = Color(0xFF3E8DFD);
  static const Color primary400Light = Color(0xFF5C9EFD);
  static const Color primary300Light = Color(0xFF97C0FE);
  static const Color primary200Light = Color(0xFFD2E2FF);
  static const Color primary100Light = Color(0xFFF0F3FF);

  static const Color primary500 = Color(0xFF00E0FF);
  static Color primary400 = Color(0xFF00E0FF).withValues(alpha: 0.75);
  static Color primary300 = Color(0xFF00E0FF).withValues(alpha: 0.5);
  static Color primary200 = Color(0xFF00E0FF).withValues(alpha: 0.25);
  static Color primary100 = Color(0xFF00E0FF).withValues(alpha: 0.1);

  static const Color neutral500 = Color(0xFF000428);
  static Color neutral400 = Color(0xFF000428).withValues(alpha: 0.75);
  static Color neutral300 = Color(0xFF000428).withValues(alpha: 0.5);
  static Color neutral200 = Color(0xFF000428).withValues(alpha: 0.25);
  static Color neutral100 = Color(0xFF000428).withValues(alpha: 0.1);

  static const Color basic500 = Color(0xFFFFFFFF);
  static Color basic400 = Color(0xFFFFFFFF).withValues(alpha: 0.75);
  static Color basic300 = Color(0xFFFFFFFF).withValues(alpha: 0.5);
  static Color basic200 = Color(0xFFFFFFFF).withValues(alpha: 0.25);
  static Color basic100 = Color(0xFFFFFFFF).withValues(alpha: 0.1);

  static const Color success500 = Color(0xFF007E00);
  static const Color success400 = Color(0xFF1AB101);
  static const Color success300 = Color(0xFF76D067);
  static const Color success200 = Color(0xFFA3E099);
  static const Color success100 = Color(0xFFD1EFCC);

  // info
  static const Color info500 = Color(0xFF1091D1);
  static const Color info400 = Color(0xFF29ABEB);
  static const Color info300 = Color(0xFF69C4F1);
  static const Color info200 = Color(0xFFA9DDF7);
  static const Color info100 = Color(0xFFD4EEFB);

  // Danger
  static const Color danger500 = Color(0xFFCA1E10);
  static const Color danger400 = Color(0xFFFD5143);
  static const Color danger300 = Color(0xFFFD7469);
  static const Color danger200 = Color(0xFFFEA8A1);
  static const Color danger100 = Color(0xFFFFDCD9);

  // warning
  static const Color warning500 = Color(0xFFFACA1F);
  static const Color warning400 = Color(0xFFFACF35);
  static const Color warning300 = Color(0xFFFBDA62);
  static const Color warning200 = Color(0xFFFCE48F);
  static const Color warning100 = Color(0xFFFEF4D2);

  static const Color bgHeaderIAP = Color(0xFF1B4577);

  static const LinearGradient gradientBgDark = LinearGradient(
    colors: [Color(0xFF000428), Color(0xFF004E92)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient gradientBgLight = LinearGradient(
    colors: [Color(0xFFA1C4FD), Color(0xFFC2E9FB)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Color bottomSheetBgDark = Color(0xFF002E64);
  static const Color bottomSheetBgLight = Color(0xFFD5E8FF);

  static const LinearGradient gradientButtonDark = LinearGradient(
    colors: [Color(0xFF000428), Color(0xFF004E92)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient gradientButton1 = LinearGradient(
    colors: [Color(0xFF0094FF), Color(0xFF00E0FF)],
    begin: Alignment(-0.9, -1.0),
    end: Alignment(0.9, 1.0),
  );

  static const LinearGradient gradientButton2 = LinearGradient(
    colors: [Color(0xFF00A1FB), Color(0xFF0063FF)],
    begin: Alignment(-0.7, -1.0),
    end: Alignment(0.7, 1.0),
  );

  static const LinearGradient gradientWidgetA = LinearGradient(
    colors: [Color(0xFF000428), Color(0xFF113C72)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const LinearGradient gradientWidgetB = LinearGradient(
    colors: [Color(0xFF42A5F5), Color(0xFF0F85E4)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient gradientWidgetC = LinearGradient(
    colors: [Color(0xFF000428), Color(0xFF004E92)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static LinearGradient gradientTime = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF).withValues(alpha: 0.1)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient gradientWidgetD = LinearGradient(
    colors: [Color(0xFF2788F6), Color(0xFF10519C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient gradientWidgetE = LinearGradient(
    colors: [Color(0xFF000428), Color(0xFF19457B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient gradientImage = LinearGradient(
    colors: [Color(0xFFFFFFFF).withValues(alpha: 0.8), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient gradientIAPDark = LinearGradient(
    colors: [Color(0xFF0094FF), Color(0xFF00E0FF)],
    begin: Alignment(-1, 0.7),
    end: Alignment(1, -0.7),
  );

  static LinearGradient gradientIAPLight = LinearGradient(
    colors: [Color(0xFF00A1FB), Color(0xFF0063FF)],
    begin: Alignment(-1, 0.7),
    end: Alignment(1, -0.7),
  );

  static const Color waterWave1Dark = Color(0xFF014389);
  static const Color waterWave2Dark = Color(0xFF005099);
  static const Color waterWave3Dark = Color(0xFF005C9D);

  static const Color waterWave3Light = Color(0xFF5DBCFF);
  static const Color waterWave2Light = Color(0xFF82C5FF);
  static const Color waterWave1Light = Color(0xFF8CC4FF);
}

