import 'package:dsp_base/app_material.dart';
import 'package:waternudge/values/onboarding_theme.dart';
import 'package:get/get.dart';

/// Shared visual pieces for the "enhanced" wheel bottom sheets (time picker,
/// duration picker): column headers, glowing selection slot, gradient preview
/// and the info pill. Kept in one place so every picker sheet reads the same.
class WheelPickerChrome {
  const WheelPickerChrome._();

  static const double wheelHeight = 200;
  static const double slotHeight = 50;
  static const double selectedFontSize = 24;
  static const double unselectedFontSize = 13;

  /// Hint line under the sheet title.
  static Widget subtitle(BuildContext context, String key) {
    final ob = OnboardingTheme.of(context);
    return AppText(
      key.tr,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: ob.textSubtitle,
      ),
    );
  }

  static Widget columnHeader(BuildContext context, double width, String key) {
    final ob = OnboardingTheme.of(context);
    return SizedBox(
      width: width,
      child: Center(
        child: AppText(
          key.tr,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: ob.textAccent,
          ),
        ),
      ),
    );
  }

  /// Wheel wrapped with a glowing selection box centred behind it.
  static Widget glowSlot(BuildContext context, double width, Widget wheel) {
    final ob = OnboardingTheme.of(context);
    return SizedBox(
      width: width,
      height: wheelHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          IgnorePointer(
            child: Container(
              width: width,
              height: slotHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ob.textAccent, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: ob.textAccent.withValues(alpha: 0.5),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          wheel,
        ],
      ),
    );
  }

  /// Header stacked over its wheel so the labels stay column-aligned.
  static Widget labeledColumn(
    BuildContext context,
    double width,
    String headerKey,
    Widget wheel,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        columnHeader(context, width, headerKey),
        const SizedBox(height: 6),
        glowSlot(context, width, wheel),
      ],
    );
  }

  /// The ":" between two columns, nudged down onto the wheels' centre band.
  /// header (~20) + gap (6) + half wheel (100) - half glyph.
  static Widget separator(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 116),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          ':',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: ob.textPrimary,
          ),
        ),
      ),
    );
  }

  /// Big gradient read-out of the current selection.
  static Widget gradientPreview(
    BuildContext context,
    String text, {
    double fontSize = 32,
  }) {
    final ob = OnboardingTheme.of(context);
    return ShaderMask(
      shaderCallback: (bounds) =>
          LinearGradient(
            colors: [ob.buttonStart, ob.buttonEnd],
          ).createShader(bounds),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
    );
  }

  /// Rounded note pill under the preview.
  static Widget infoPill(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final ob = OnboardingTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ob.textAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ob.textAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: ob.textAccent),
          const SizedBox(width: 10),
          Flexible(
            child: AppText(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: ob.textPrimary.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// One wheel row. [distance] is the (looping-aware) offset from the centre.
  static Widget wheelItem(
    BuildContext context,
    String label,
    int distance, {
    double selectedSize = selectedFontSize,
    double unselectedSize = unselectedFontSize,
  }) {
    final ob = OnboardingTheme.of(context);
    Color itemColor = ob.textPrimary;
    if (distance == 1) {
      itemColor = ob.textPrimary.withValues(alpha: 0.5);
    } else if (distance >= 2) {
      itemColor = ob.textPrimary.withValues(alpha: 0.1);
    }
    return Center(
      child: AppText(
        label,
        style: TextStyle(
          fontSize: distance == 0 ? selectedSize : unselectedSize,
          fontWeight: FontWeight.w600,
          color: itemColor,
        ),
      ),
    );
  }
}
