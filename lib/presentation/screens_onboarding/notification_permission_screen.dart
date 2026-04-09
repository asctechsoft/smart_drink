import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/onboarding_controller.dart';
import 'package:smartdrinkai/presentation/common_components/primary_button.dart';
import 'package:smartdrinkai/presentation/common_components/primary_dialog.dart';
import 'package:smartdrinkai/services/native/notification_channel.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:get/get.dart';

/// Shows a notification permission dialog.
/// Calls [onComplete] after permission is granted or dismissed.
void showNotificationPermissionDialog(
  BuildContext context, {
  required VoidCallback onComplete,
}) {
  var completed = false;
  void complete() {
    if (!completed) {
      completed = true;
      onComplete();
    }
  }

  PrimaryDialog.show<void>(
    context: context,
    title: 'you_ll_get_reminder_on_time'.tr,
    content: _NotificationPermissionContent(
      onDone: () {
        Navigator.of(context).pop();
      },
    ),
  ).then((_) => complete());
}

class _NotificationPermissionContent extends StatelessWidget {
  final VoidCallback onDone;

  const _NotificationPermissionContent({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return AppColumn(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon('assets/images/webp/img_notification.webp', size: 200),
        const AppSpacerH(24),
        PrimaryButton(
          text: 'allow'.tr,
          width: 160,
          useGradient: true,
          onPressed: () async {
            try {
              await NotificationChannel.requestPermission();
            } catch (_) {
              // Proceed regardless
            }
            onDone();
          },
        ),
      ],
    );
  }
}

/// Keep this as a standalone screen in case it's referenced from routes.
class NotificationPermissionScreen extends StatelessWidget {
  const NotificationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    final ob = OnboardingTheme.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showNotificationPermissionDialog(
        context,
        onComplete: () => controller.completeOnboarding(),
      );
    });
    return Scaffold(
      backgroundColor: ob.scaffoldBg,
      body: const SizedBox.shrink(),
    );
  }
}

