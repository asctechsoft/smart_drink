import 'dart:async';

import 'package:dsp_base/dsp_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'configs/app_figs.dart';
import 'configs/pref_const.dart';
import 'presentation/common_components/app_reopen_native_ad.dart';
import 'services/app_ads.dart';
import 'services/app_localize.dart';
import 'controller/user_profile_controller.dart';
import 'controller/today_controller.dart';
import 'controller/history_controller.dart';
import 'controller/settings_controller.dart';
import 'controller/reminder_controller.dart';
import 'controller/avatar_controller.dart';
import 'tour/tour_controller.dart';
import 'tour/tour_overlay.dart';
import 'utils/route_analytics.dart';
import 'values/app_theme.dart';
import 'values/app_pages.dart';
import 'values/route_name.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> _ensureLocaleConfigured() async {
  final prefs = await SharedPreferences.getInstance();

  // "System Default" was picked — the saved language key is just a display
  // cache of what that last resolved to, not a real pin. Always re-detect,
  // in case the device's own language changed since the last cold start.
  final followSystem = prefs.getBool(PrefConst.followSystemLanguage) ?? false;

  if (!followSystem) {
    // Try to load an explicitly-pinned saved language first.
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
  }

  // No pin (or explicitly following system) — use the device's language.
  // setAppLocale persists the choice itself — no separate pref write needed.
  await AppLocalize.setAppLocale(
    AppLocalize.bestSupportedMatchFor(AppLocalize.getSystemLocale()),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runZonedGuarded(
    () async {
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

      // 1. Firebase (core + App Check + Crashlytics), Remote Config, then the
      // GDPR/UMP consent flow and AdMob — all registered with GetX and run in
      // order by DspBase.start; it never throws.
      //
      // App Check uses the debug provider in debug builds — register the
      // token it logs in the Firebase console before enforcing. Consent folds
      // "forbids requesting ads" into `DspAdsConfig.isHideAd`, which every ad
      // placement gates on, so ads must be started before any ad service's
      // load()/preload.
      //
      // `alpha` is the "NoAds Debug" launch config (see .vscode/launch.json);
      // `alpha`/`dev` use Google's test ad unit IDs (dev would otherwise load
      // the real placeholder IDs from AdsConfig and silently fail); a test
      // device is registered so a dev device never trips AdMob's abnormal
      // real-ad-request flagging.
      await DspBase.start(
        remoteConfigDefaults: const {TourController.rcVariantKey: ''},
        hideAds: AppFigs.isAlpha,
        useTestAdIds: AppFigs.isAlpha || AppFigs.isDev,
        registerTestAdDevice: AppFigs.isShowTestOption,
        debugEeaConsent: AppFigs.isShowTestOption,
      );

      // Preload now so it's ready by the time the splash screen (~900ms)
      // hands off to Home — SplashScreen looks these back up to show them.
      // Only fires for returning users (see SplashScreen._navigate);
      // first-time installs go through onboarding instead, never through
      // this path.
      //
      // Android shows the Native Ad below (custom-styled, blends into the
      // app); iOS falls back to this App Open ad.
      AppAds.openAd.load();
      AppReopenNativeAd.preload();

      // 1.5 Initialize intl date formatting
      await initializeDateFormatting();

      await _ensureLocaleConfigured();

      // 2. Initialize translations
      await AppLocalize.loadTranslations();

      // 3. Pin this install's guided-tour A/B branch. Sticky, and a no-op on
      // the Product release build — see TourController.assignLocalVariant.
      await TourController.assignLocalVariant();

      runApp(const WaterNudgeApp());
    },
    (error, stack) {
      if (DspFirebaseService.isCoreReady) {
        DspCrashlytics.recordError(error, stack, fatal: true);
      }
    },
  );
}

class WaterNudgeApp extends StatelessWidget {
  const WaterNudgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Aqua Mind',
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
