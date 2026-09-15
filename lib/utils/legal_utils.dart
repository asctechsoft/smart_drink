import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waternudge/configs/legal_config.dart';
import 'package:waternudge/utils/toast_utils.dart';

/// Opens the hosted privacy policy.
class LegalUtils {
  const LegalUtils._();

  /// Sends the user to the policy page in their browser.
  ///
  /// The policy lives on the web only — there is no in-app copy to fall back
  /// to, precisely so there is one wording to keep in step with the store
  /// listing. When no browser can take the URL the user is told, rather than
  /// left with a tap that appears to do nothing.
  static Future<void> openPrivacyPolicy() async {
    try {
      final opened = await launchUrl(
        Uri.parse(LegalConfig.privacyPolicyUrl),
        mode: LaunchMode.externalApplication,
      );
      if (opened) return;
    } catch (e) {
      debugPrint('LegalUtils.openPrivacyPolicy failed: $e');
    }

    final context = Get.context;
    if (context != null && context.mounted) {
      ToastUtils.showToast(context, 'open_link_failed'.tr);
    }
  }
}
