import 'dart:io';

import 'package:dsp_base/advertisements.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternudge/configs/ads_config.dart';

/// The Native Ad shown after the splash hands off to Home for a returning
/// user (Android only — [NativeAdController] no-ops on iOS, which keeps
/// using the App Open ad instead; see `splash_screen.dart`).
///
/// Call [preload] once at app startup so the ad is ready by the time
/// [show] is called; [show] is a no-op until it's actually loaded, so it
/// never pops up an empty sheet.
class AppReopenNativeAd {
  AppReopenNativeAd._();

  static const String _tag = 'app_reopen';

  /// Matches how `NativeAdController.newInstance`/`getInstance` derive the
  /// GetX tag internally — kept in one place so the preload and lookup can
  /// never drift apart.
  static String get _getxTag =>
      '${AdsConfig.nativeAdUnitId}${AdsConfig.nativeAdFactoryId}$_tag';

  static void preload() {
    if (!Platform.isAndroid) return;
    NativeAdController.newInstance(
      adUnitId: AdsConfig.nativeAdUnitId,
      factoryId: AdsConfig.nativeAdFactoryId,
      tag: _tag,
      adHeight: 120,
    ).requestAd();
  }

  static void show(BuildContext context) {
    if (!Platform.isAndroid) return;
    if (!Get.isRegistered<NativeAdController>(tag: _getxTag)) return;

    final controller = NativeAdController.getInstance(
      adUnitId: AdsConfig.nativeAdUnitId,
      factoryId: AdsConfig.nativeAdFactoryId,
      tag: _tag,
    );
    if (!controller.isAdLoaded.value) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _NativeAdSheet(controller: controller),
    );
  }
}

class _NativeAdSheet extends StatelessWidget {
  const _NativeAdSheet({required this.controller});

  final NativeAdController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A2556),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            clipBehavior: Clip.none,
            children: [
              controller.renderAd(),
              Positioned(
                top: -4,
                right: -4,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
