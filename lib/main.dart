import 'package:dsp_base/advertisements.dart';
import 'package:dsp_base/comm_app.dart';
import 'package:dsp_base/convenience_imports.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'configs/ads_config.dart';
import 'configs/pref_const.dart';
import 'presentation/common_components/app_reopen_native_ad.dart';
import 'services/app_localize.dart';
import 'controller/user_profile_controller.dart';
import 'controller/today_controller.dart';
import 'controller/history_controller.dart';
import 'controller/settings_controller.dart';
import 'controller/reminder_controller.dart';
import 'controller/avatar_controller.dart';
import 'controller/auth_controller.dart';
import 'tour/tour_controller.dart';
import 'tour/tour_overlay.dart';
import 'utils/route_analytics.dart';
import 'values/app_theme.dart';
import 'values/app_pages.dart';
import 'values/route_name.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<void> _ensureLocaleConfigured() async {
  final prefs = await SharedPreferences.getInstance();

  // 1. Try to load saved language first
  final savedLanguage = prefs.getString(PrefConst.language) ?? '';
  if (savedLanguage.isNotEmpty) {
    final parts = savedLanguage.split('_');
    final Locale savedLocale;
    if (parts.length == 2) {
      savedLocale = Locale(parts[0], parts[1]);
    } else {
      savedLocale = Locale(parts[0]);
    }

    // Check if the saved locale is among supported locales
    final isSupported = AppLocalize.supportedLocales.any(
      (l) =>
          l.languageCode == savedLocale.languageCode &&
          (l.countryCode ?? '') == (savedLocale.countryCode ?? ''),
    );

    if (isSupported) {
      await AppLocalize.setAppLocale(savedLocale);
      return;
    }
  }

  // 2. If no saved language, use system language
  final systemLocale = AppLocalize.getSystemLocale();
  final langCode = systemLocale?.languageCode ?? "en";

  // Find the best supported locale whose language code matches the device.
  final bestMatch =
      AppLocalize.supportedLocales.cast<Locale?>().firstWhere(
        (l) => l!.languageCode == langCode,
        orElse: () => null,
      ) ??
      const Locale("en", "US");

  // setAppLocale persists the choice itself — no separate pref write needed.
  await AppLocalize.setAppLocale(bestMatch);
}

Future<void> main() async {
  await commRunApp(
    () => const WaterNudgeApp(),
    onBindingInitialized: (widgetsBinding) async {
      // Lock orientation to portrait only
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // Hide the system navigation bar entirely (status bar stays) so the
      // banner ad can sit flush against the true bottom edge instead of
      // stacking on top of the device's own nav buttons. Screens rely on
      // SafeArea for the remaining (top) inset.
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.top],
      );
      // A swipe from the bottom edge reveals the nav bar again temporarily
      // (standard Android immersive behaviour) — re-hide it once the user's
      // done with it instead of leaving it stuck on screen.
      SystemChrome.setSystemUIChangeCallback((systemOverlaysAreVisible) async {
        if (!systemOverlaysAreVisible) return;
        await Future.delayed(const Duration(seconds: 2));
        await SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: [SystemUiOverlay.top],
        );
      });

      // 1. Firebase Initialization
      try {
        await Firebase.initializeApp();
      } catch (e) {
        debugPrint("Firebase initialization failed: $e");
      }

      // 1.4 AdMob — must run before any BannerAdController/
      // InterstitialAdController request(), or the request silently fails.
      //
      // dsp_base only swaps in Google's test ad unit IDs under the `alpha`
      // flavor by default; `dev` is this app's everyday debug flavor and
      // would otherwise try to load the real (placeholder) ad unit IDs from
      // AdsConfig and silently fail. Widen it here rather than in dsp_base,
      // which other apps share.
      AdvertsConfig.instance.isAdTestIds = CommFigs.IS_ALPHA || CommFigs.IS_DEV;
      try {
        await MobileAds.instance.initialize();
      } catch (e) {
        debugPrint("MobileAds initialization failed: $e");
      }

      // Preload now so it's ready by the time the splash screen (~900ms)
      // hands off to Home — SplashScreen looks these back up to show them.
      // Only fires for returning users (see SplashScreen._navigate);
      // first-time installs go through onboarding instead, never through
      // this path.
      //
      // Android shows the Native Ad below (custom-styled, blends into the
      // app); iOS falls back to this App Open ad — NativeAdController is
      // Android-only in dsp_base.
      OpenAdController.newInstance(
        adUnitId: AdsConfig.appOpenAdUnitId,
      ).requestOpenAd();
      AppReopenNativeAd.preload();

      // 1.5 Initialize intl date formatting
      await initializeDateFormatting();

      await _ensureLocaleConfigured();

      // 2. Initialize translations
      await AppLocalize.loadTranslations();

      // 3. Pin this install's guided-tour A/B branch. Sticky, and a no-op on
      // the Product release build — see TourController.assignLocalVariant.
      await TourController.assignLocalVariant();
    },
  );
}

class WaterNudgeApp extends StatelessWidget {
  const WaterNudgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CommApp(
      title: 'AquaMind',
      debugShowCheckedModeBanner: false,
      // The app has one look: every screen sits on the dark gradient and the
      // foreground palette is fixed dark-on-dark. Both slots get the dark
      // theme and the mode is pinned, so flipping the phone between light and
      // dark cannot repaint Material defaults (dialogs, fields, switches).
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      locale: AppLocalize.getAppLocale(),
      fallbackLocale: const Locale('en', 'US'),
      supportedLocales: AppLocalize.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: RouteName.splash,
      routingCallback: RouteAnalytics.onRouting,
      // Above the navigator, so it can spotlight a widget on any route
      // without each screen hosting an overlay of its own.
      builder: (context, child) =>
          TourOverlay(child: child ?? const SizedBox.shrink()),
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController(), permanent: true);
        Get.put(SettingsController(), permanent: true);
        Get.put(UserProfileController(), permanent: true);
        Get.put(TodayController(), permanent: true);
        Get.put(HistoryController(), permanent: true);
        Get.put(ReminderController(), permanent: true);
        Get.put(AvatarController(), permanent: true);
        Get.put(TourController(), permanent: true);
      }),
      getPages: AppPages.pages,
    );
  }
}
