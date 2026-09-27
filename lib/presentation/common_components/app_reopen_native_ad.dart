import 'dart:io';

import 'package:asc_common/asc_common.dart';
import 'package:flutter/material.dart';
import 'package:waternudge/configs/ads_config.dart';

/// The Native Ad shown after the splash hands off to Home for a returning
/// user (Android only — the app's native ad factory, registered in
/// `MainActivity.kt`, isn't wired up on iOS, which keeps using the App Open
/// ad instead; see `splash_screen.dart`).
///
/// Call [preload] once at app startup so the ad is ready by the time
/// [show] is called; [show] is a no-op until it's actually loaded, so it
/// never pops up an empty sheet.
class AppReopenNativeAd {
  AppReopenNativeAd._();

  static final _service = AscNativeAdService(
    adUnitId: AdsConfig.nativeAdUnitId,
    factoryId: AdsConfig.nativeAdFactoryId,
  );

  static void preload() {
    if (!Platform.isAndroid) return;
    _service.load();
  }

  static void show(BuildContext context) {
    if (!Platform.isAndroid) return;
    if (!_service.isLoaded) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _NativeAdSheet(service: _service),
    );
  }
}

class _NativeAdSheet extends StatelessWidget {
  const _NativeAdSheet({required this.service});

  final AscNativeAdService service;

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
              service.render(height: 120),
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
