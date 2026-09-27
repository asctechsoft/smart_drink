import 'package:asc_common/asc_common.dart';
import 'package:waternudge/configs/ads_config.dart';

/// Shared App Open ad instance - preloaded once at startup (`main.dart`) and
/// shown later from `SplashScreen`, which is a separate widget instance and
/// so can't just hold its own copy the way `TodayScreen` holds its
/// interstitial.
class AppAds {
  AppAds._();

  static final openAd = AscAppOpenAdService(adUnitId: AdsConfig.appOpenAdUnitId);
}
