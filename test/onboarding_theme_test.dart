import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waternudge/values/app_colors.dart';
import 'package:waternudge/values/onboarding_theme.dart';

/// The app paints one fixed gradient on every screen, so foreground colors must
/// stay readable on it whatever the platform brightness is.
void main() {
  Future<OnboardingTheme> themeUnder(
    WidgetTester tester,
    Brightness brightness,
  ) async {
    late OnboardingTheme resolved;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: brightness),
        home: Builder(
          builder: (context) {
            resolved = OnboardingTheme.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return resolved;
  }

  testWidgets('palette does not flip with platform brightness', (tester) async {
    final light = await themeUnder(tester, Brightness.light);
    final dark = await themeUnder(tester, Brightness.dark);

    expect(light.isLight, isFalse);
    expect(dark.isLight, isFalse);
    expect(light.textPrimary, dark.textPrimary);
  });

  testWidgets('body text is white and values are cyan on the gradient', (
    tester,
  ) async {
    final ob = await themeUnder(tester, Brightness.light);

    expect(ob.textPrimary, AppColors.basic500);
    expect(ob.textAccent, AppColors.onboardingAccent);
    expect(ob.switchActive, AppColors.primary500Dark);
  });

  testWidgets('cards and nav sit on translucent navy, not white', (
    tester,
  ) async {
    final ob = await themeUnder(tester, Brightness.light);

    for (final color in [ob.bgDrinkItem, ob.bgBottomNavBar, ob.bgOnboarding]) {
      // The dark palette builds these from neutral500/basic100, both of which
      // are far from opaque white.
      expect(color, isNot(AppColors.basic500));
    }
    expect(ob.bgBottomSheet, AppColors.bottomSheetBgDark);
  });
}
