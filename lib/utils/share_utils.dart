import 'dart:io' show Platform;

import 'package:dsp_base/app_material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

class ShareUtils {
  ShareUtils._();

  /// App Store numeric id, used to build the iOS store link.
  ///
  /// Empty until the app is published: with no id there is no valid App Store
  /// URL to send, so [shareApp] falls back to the Play Store link rather than
  /// sharing a dead one.
  static const String iosAppId = '';

  /// Opens the system share sheet with an invite to install the app.
  ///
  /// [context] anchors the sheet: on iPad the share popover needs a source
  /// rect, and UIKit throws instead of presenting when it has none.
  static Future<void> shareApp(BuildContext context) async {
    // Read from the installed bundle rather than hardcoding, so build flavours
    // with an `applicationIdSuffix` still share a link that resolves.
    final info = await PackageInfo.fromPlatform();
    final message =
        '${'settings_share_message'.tr}\n${_storeLink(info.packageName)}';

    if (!context.mounted) return;

    await SharePlus.instance.share(
      ShareParams(
        text: message,
        // Only used by targets that have a subject line, e.g. email.
        subject: info.appName,
        sharePositionOrigin: _originOf(context),
      ),
    );
  }

  static String _storeLink(String packageName) {
    if (Platform.isIOS && iosAppId.isNotEmpty) {
      return 'https://apps.apple.com/app/id$iosAppId';
    }
    return 'https://play.google.com/store/apps/details?id=$packageName';
  }

  /// Global rect of the widget that triggered the share, or null when it has no
  /// size yet — iOS is the only platform that reads this.
  static Rect? _originOf(BuildContext context) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }
}
