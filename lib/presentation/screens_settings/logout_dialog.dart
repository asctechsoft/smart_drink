import 'package:dsp_base/app_material.dart';
import 'package:waternudge/controller/auth_controller.dart';
import 'package:waternudge/presentation/common_components/primary_button.dart';
import 'package:waternudge/presentation/common_components/primary_dialog.dart';
import 'package:waternudge/values/onboarding_theme.dart';
import 'package:get/get.dart';

/// Confirm dialog shown before signing the user out.
Future<void> showLogoutConfirmDialog(BuildContext context) {
  return PrimaryDialog.show(
    context: context,
    content: const _LogoutDialogContent(),
  );
}

class _LogoutDialogContent extends StatelessWidget {
  const _LogoutDialogContent();

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return AppColumn(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFEF5350).withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.logout_rounded,
            size: 30,
            color: Color(0xFFEF5350),
          ),
        ),
        const AppSpacerH(20),
        AppText(
          'logout_confirm_title'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: ob.textPrimary,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        ),
        const AppSpacerH(10),
        AppText(
          'logout_confirm_message'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: ob.textSecondary,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
        const AppSpacerH(24),
        PrimaryButton(
          text: 'settings_logout'.tr,
          useGradient: true,
          width: double.infinity,
          height: 48,
          onPressed: () {
            Navigator.of(context).pop();
            AuthController.to.signOut();
          },
        ),
        const AppSpacerH(12),
        PrimaryButton(
          text: 'cancel'.tr,
          outlined: true,
          width: double.infinity,
          height: 48,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
