import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:asc_common/asc_common.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'configs/app_figs.dart';
import 'configs/pref_const.dart';
import 'presentation/common_components/app_reopen_native_ad.dart';
import 'services/app_ads.dart';
import 'services/app_gdpr_consent.dart';
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
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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

      // 1. Firebase Initialization
      try {
        await Firebase.initializeApp();
      } catch (e) {
        debugPrint("Firebase initialization failed: $e");
      }

      if (Firebase.apps.isNotEmpty) {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
          true,
        );
        FlutterError.onError = (details) {
          FlutterError.presentError(details);
          FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        };
        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
        Isolate.current.addErrorListener(
          RawReceivePort((pair) async {
            final List<dynamic> errorAndStacktrace = pair;
            await FirebaseCrashlytics.instance.recordError(
              errorAndStacktrace.first,
              errorAndStacktrace.last,
              fatal: true,
            );
          }).sendPort,
        );
      }

      // 1.4 AdMob — must run before any ad service's load()/preload, or the
      // request silently fails.
      //
      // Only the `alpha` flavor swapped in Google's test ad unit IDs by
      // default; `dev` is this app's everyday debug flavor and would
      // otherwise try to load the real (placeholder) ad unit IDs from
      // AdsConfig and silently fail.
      AscAdsConfig.isAdTestIds = AppFigs.isAlpha || AppFigs.isDev;

      // GDPR/UMP consent — must resolve before any ad is requested. Shows
      // the consent form itself for users in the EEA/UK/Switzerland; a
      // no-op everywhere else. `canRequestAds()` is false only in the rare
      // case a required form never got resolved (e.g. failed to load) —
      // folded into isHideAd so every ad placement in the app (they all
      // already gate on it) skips loading until that's sorted out, instead
      // of needing its own separate check.
      await AppGdprConsent.gatherConsent();
      final canRequestAds = await AppGdprConsent.canRequestAds();

      // `alpha` is the "NoAds Debug" launch config (see .vscode/launch.json)
      // — every other flavor (dev/product/claude) keeps showing ads.
      AscAdsConfig.isHideAd = AppFigs.isAlpha || !canRequestAds;
      try {
        await MobileAds.instance.initialize();
        // Marks this device as an AdMob test device even when a real ad
        // unit id is requested — avoids Google flagging the account for
        // abnormal real-ad-request volume from a dev device.
        if (AppFigs.isShowTestOption) {
          MobileAds.instance.updateRequestConfiguration(
            RequestConfiguration(
              testDeviceIds: [await AscAdsConfig.getAdMobTestDeviceId()],
            ),
          );
        }
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
      if (Firebase.apps.isNotEmpty) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
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
