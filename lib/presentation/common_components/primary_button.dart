import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/values/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool enabled;
  final double? width;
  final double? height;
  final bool useGradient;
  final Color? solidColor;
  final bool outlined;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final Widget? leading;
  final Widget? trailing;
  final List<Widget>? backgroundDecorations;
  final bool autoSizeText;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.enabled = true,
    this.width,
    this.height = 52,
    this.useGradient = false,
    this.solidColor,
    this.outlined = false,
    this.textStyle,
    this.padding,
    this.leading,
    this.trailing,
    this.backgroundDecorations,
    this.autoSizeText = true,
  });

  @override
  Widget build(BuildContext context) {
    if (useGradient) {
      final isLight = Theme.of(context).brightness == Brightness.light;
      final gradientStart = isLight
          ? AppColors.onboardingLightButtonStart
          : AppColors.onboardingButtonStart;
      final gradientEnd = isLight
          ? AppColors.onboardingLightButtonEnd
          : AppColors.onboardingButtonEnd;
      final disabledColor = isLight
          ? AppColors.onboardingLightAccent.withValues(alpha: 0.3)
          : AppColors.onboardingAccent.withValues(alpha: 0.3);
      final borderColor = isLight
          ? AppColors.primary500Light.withValues(alpha: 0.25)
          : AppColors.primary500Dark.withValues(alpha: 0.25);

      return Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: SizedBox(
          width: width,
          height: height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: enabled
                  ? LinearGradient(
                      begin: const Alignment(-1, 0.7),
                      end: const Alignment(1, -0.7),
                      colors: [gradientStart, gradientEnd],
                    )
                  : null,
              color: enabled ? null : disabledColor,
              borderRadius: BorderRadius.circular(100),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.passthrough,
                children: [
                  if (backgroundDecorations != null) ...backgroundDecorations!,
                  MaterialButton(
                    onPressed: enabled ? onPressed : null,
                    minWidth: width ?? 0,
                    height: height,
                    padding: padding,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (leading != null) ...[leading!, AppSpacerW8],
                        _buildText(
                          text,
                          textStyle ??
                              const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                        ),
                        if (trailing != null) ...[AppSpacerW8, trailing!],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Outlined mode (Cancel style)
    if (outlined) {
      final isLight = Theme.of(context).brightness == Brightness.light;
      final accentColor = isLight
          ? AppColors.primary500Light
          : AppColors.primary500Dark;
      return SizedBox(
        width: width,
        height: height,
        child: OutlinedButton(
          onPressed: enabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            padding: padding,
            foregroundColor: accentColor,
            side: BorderSide(color: accentColor, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          child: Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leading != null) ...[leading!, AppSpacerW8],
                _buildText(
                  text,
                  textStyle ??
                      TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                ),
                if (trailing != null) ...[AppSpacerW8, trailing!],
              ],
            ),
          ),
        ),
      );
    }

    final bgColor = solidColor ?? AppColors.primary;
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: AppColors.danger300.withValues(alpha: 0.25),
          width: 2,
        ),
      ),
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(100),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.passthrough,
              children: [
                if (backgroundDecorations != null) ...backgroundDecorations!,
                MaterialButton(
                  onPressed: enabled ? onPressed : null,
                  minWidth: width ?? 0,
                  height: height,
                  padding: padding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (leading != null) ...[leading!, AppSpacerW8],
                      _buildText(
                        text,
                        textStyle ??
                            const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                      ),
                      if (trailing != null) ...[AppSpacerW8, trailing!],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildText(String text, TextStyle style) {
    if (autoSizeText) {
      return Flexible(
        child: AppTextAutoResize(
          text,
          style: style,
          maxLines: 1,
          minFontSize: 10,
          textAlign: TextAlign.center,
        ),
      );
    }
    return AppText(text, style: style);
  }
}

