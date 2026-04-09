import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';

class PrimaryDialog extends StatelessWidget {
  final String? title;
  final Widget content;
  final EdgeInsets? padding;

  const PrimaryDialog({
    super.key,
    this.title,
    required this.content,
    this.padding,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget content,
    EdgeInsets? padding,
  }) {
    return showDialog<T>(
      context: context,
      builder: (ctx) =>
          PrimaryDialog(title: title, content: content, padding: padding),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 12,
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: padding ?? const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: ob.bgBottomSheet,
          borderRadius: BorderRadius.circular(24),
        ),
        child: AppColumn(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null && title!.isNotEmpty) ...[
              AppText(
                title!,
                style: TextStyle(
                  color: ob.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const AppSpacerH(24),
            ],
            content,
          ],
        ),
      ),
    );
  }
}

