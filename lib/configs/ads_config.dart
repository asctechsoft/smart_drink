/// AdMob ad unit IDs.
///
/// These placeholders only ever reach a Product build — outside it,
/// `AdvertsConfig.instance.isAdTestIds` swaps every request to Google's
/// public test IDs automatically, so leaving them unset is safe during
/// development. Replace with the real IDs from the AdMob console before
/// shipping a Product build, or ads will simply fail to load.
class AdsConfig {
  AdsConfig._();

  static const String bannerAdUnitId =
      'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String interstitialAdUnitId =
      'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String appOpenAdUnitId =
      'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String nativeAdUnitId =
      'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  /// Must match `MainActivity.NATIVE_AD_FACTORY_ID` (Android only —
  /// `NativeAdController` no-ops on iOS; see AppOpenReplacementAd, which
  /// falls back to the App Open ad there instead).
  static const String nativeAdFactoryId = 'appOpenReplacement';
}
