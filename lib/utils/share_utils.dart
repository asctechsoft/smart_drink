import 'package:asc_common/asc_common.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShareUtils {
  ShareUtils._();

  /// App Store numeric id, used to build the iOS store link.
  ///
  /// Empty until the app is published: with no id there is no valid App Store
  /// URL to send, so [AscShare.shareApp] falls back to the Play Store link
  /// rather than sharing a dead one.
  static const String iosAppId = '';

  /// Opens the system share sheet with an invite to install the app.
  static Future<void> shareApp(BuildContext context) => AscShare.shareApp(
    context,
    message: 'settings_share_message'.tr,
    iosAppId: iosAppId,
  );
}
