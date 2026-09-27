import 'dart:async';

import 'package:asc_common/asc_common.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:waternudge/configs/app_figs.dart';

/// Google's User Messaging Platform (UMP) consent flow — required before
/// requesting any ad for a user in the EEA, UK, or Switzerland, and
/// increasingly enforced elsewhere too (US state privacy laws). Wraps
/// `google_mobile_ads`'s own `ConsentInformation`/`ConsentForm` directly
/// rather than `asc_common`'s `AscGdprNotifier` — that one is a Riverpod
/// `AsyncNotifier`, and this app is GetX-only with no `ProviderScope`
/// anywhere; pulling in Riverpod for one feature isn't worth it. Same
/// official SDK either way, just a plain static wrapper instead of a
/// Riverpod provider — matches this app's `AppFigs`/`AppModifier`/
/// `AppLocalize` pattern of porting only what's needed, directly.
class AppGdprConsent {
  AppGdprConsent._();

  /// Requests a consent info update and shows the consent form if UMP says
  /// this user needs one, resolving only once that's settled (obtained,
  /// declined, or not required at all). Call once at startup, before
  /// [MobileAds.instance.initialize] / any ad service's `load()` — every ad
  /// placement in this app also gates on [AscAdsConfig.isHideAd], which the
  /// caller should set from [canRequestAds] right after this resolves.
  static Future<void> gatherConsent() async {
    final completer = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(
        consentDebugSettings: AppFigs.isShowTestOption
            ? ConsentDebugSettings(
                debugGeography: DebugGeography.debugGeographyEea,
              )
            : null,
      ),
      () async {
        try {
          await ConsentForm.loadAndShowConsentFormIfRequired((formError) {
            if (formError != null) {
              debugPrint(
                'AppGdprConsent: form dismissed with error: ${formError.message}',
              );
            }
          });
        } catch (e) {
          debugPrint('AppGdprConsent: loadAndShowConsentFormIfRequired failed: $e');
        }
        if (!completer.isCompleted) completer.complete();
      },
      (error) {
        debugPrint(
          'AppGdprConsent: requestConsentInfoUpdate failed: ${error.message}',
        );
        if (!completer.isCompleted) completer.complete();
      },
    );
    return completer.future;
  }

  /// Whether the app is currently allowed to request ads at all — false
  /// only while a required consent form hasn't been resolved yet (e.g. it
  /// failed to load). Check this right after [gatherConsent].
  static Future<bool> canRequestAds() =>
      ConsentInformation.instance.canRequestAds();

  /// Whether this user needs a "manage ad consent" entry point in Settings
  /// at all — most users outside the EEA/UK/Switzerland never do.
  static Future<bool> isPrivacyOptionsRequired() async {
    final status = await ConsentInformation.instance
        .getPrivacyOptionsRequirementStatus();
    return status == PrivacyOptionsRequirementStatus.required;
  }

  /// Re-opens the consent choice — wire to a Settings row gated behind
  /// [isPrivacyOptionsRequired]. Returns the up-to-date [canRequestAds]
  /// result so the caller can refresh [AscAdsConfig.isHideAd].
  static Future<bool> showPrivacyOptionsForm() async {
    await ConsentForm.showPrivacyOptionsForm((formError) {
      if (formError != null) {
        debugPrint(
          'AppGdprConsent: privacy options form error: ${formError.message}',
        );
      }
    });
    return canRequestAds();
  }
}
