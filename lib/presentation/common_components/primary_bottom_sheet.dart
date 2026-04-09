import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/presentation/common_components/bottom_safe_area.dart';
import 'package:smartdrinkai/presentation/common_components/primary_button.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class PrimaryBottomSheet extends StatelessWidget {
  final String title;
  final Widget content;
  final String buttonText;
  final VoidCallback? onButtonPressed;
  final bool showSubmitButton;
  final double? buttonWidth;

  const PrimaryBottomSheet({
    super.key,
    required this.title,
    required this.content,
    this.buttonText = 'submit',
    this.onButtonPressed,
    this.showSubmitButton = true,
    this.buttonWidth,
  });

  /// Static helper to show the sheet for consistent styling
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    String buttonText = 'submit',
    VoidCallback? onButtonPressed,
    bool showSubmitButton = true,
    double? buttonWidth,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PrimaryBottomSheet(
        title: title,
        content: content,
        buttonText: buttonText,
        onButtonPressed: onButtonPressed,
        showSubmitButton: showSubmitButton,
        buttonWidth: buttonWidth,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return AppColumn(
      mainAxisSize: MainAxisSize.min,
      modifier: Modifier.background(
        color: ob.bgBottomSheet,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ).padding(horizontal: 24, vertical: 12),
      children: [
        _dragHandle(context),
        _sheetTitle(context),
        AppSpacerH24,
        content,
        if (showSubmitButton) ...[
          AppSpacerH24,
          PrimaryButton(
            width: buttonWidth ?? double.infinity,
            text: buttonText.tr,
            onPressed: onButtonPressed ?? () => Navigator.pop(context),
            useGradient: true,
          ),
        ],
        AppSpacerH24,
        const BottomSafeArea(),
      ],
    );
  }

  Widget _dragHandle(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: ob.bgDrag,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _sheetTitle(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return AppText(
      title.tr,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: ob.textPrimary,
      ),
    );
  }
}

