/// AdMob ad unit IDs — real IDs before shipping, `AscAdsConfig.isAdTestIds` swaps in Google's test IDs outside Product builds.
class AdsConfig {
  AdsConfig._();

  static const String bannerAdUnitId = 'ca-app-pub-2444258853804467/3293585545';
  static const String interstitialAdUnitId =
      'ca-app-pub-2444258853804467/6834209454';
  static const String appOpenAdUnitId =
      'ca-app-pub-2444258853804467/2293252653';
  static const String nativeAdUnitId = 'ca-app-pub-2444258853804467/9980170988';

  /// Interstitial shown after tapping "Start" on the Welcome screen — TODO: create a dedicated unit, currently reuses interstitialAdUnitId.
  static const String welcomeInterstitialAdUnitId =
      'ca-app-pub-2444258853804467/6834209454';

  /// Must match `MainActivity.NATIVE_AD_FACTORY_ID` — compact card layout shared by every "small" native ad placement.
  static const String nativeAdFactoryId = 'appOpenReplacement';

  /// Must match `MainActivity.FSN_NATIVE_AD_FACTORY_ID` — full-screen layout used by [FullScreenNativeAdScreen] ("FSN_1"/"FSN_2").
  static const String fsnNativeAdFactoryId = 'fsn_native_ad';

  /// Native ad on the first-run language picker before a language is picked ("lan1") — TODO: dedicated unit, currently reuses nativeAdUnitId.
  static const String languageBeforePickNativeAdUnitId =
      'ca-app-pub-2444258853804467/9980170988';

  /// Same placement as [languageBeforePickNativeAdUnitId], swapped in once a language is picked ("lan2") — TODO: dedicated unit, currently reuses nativeAdUnitId.
  static const String languageAfterPickNativeAdUnitId =
      'ca-app-pub-2444258853804467/9980170988';

  /// Full-screen Native Ad after the Gender step, before Height ("FSN_1") — TODO: dedicated unit, currently reuses nativeAdUnitId.
  static const String genderFullScreenNativeAdUnitId =
      'ca-app-pub-2444258853804467/9980170988';

  /// Full-screen Native Ad after the Daily Goal step, before Home ("FSN_2") — TODO: dedicated unit, currently reuses nativeAdUnitId.
  static const String dailyGoalFullScreenNativeAdUnitId =
      'ca-app-pub-2444258853804467/9980170988';

  /// Native ad in the "why are you leaving?" exit-survey sheet — TODO: dedicated unit, currently reuses nativeAdUnitId.
  static const String exitSurveyNativeAdUnitId =
      'ca-app-pub-2444258853804467/9980170988';
}
