import 'package:dsp_base/comm_app.dart';
import 'package:dsp_base/app_localize.dart';
import 'package:dsp_base/convenience_imports.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'configs/pref_const.dart';
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

void _ensureLocaleConfigured() {
  // 1. Try to load saved language first
  final savedLanguage = PrefAssist.getString(PrefConst.language);
  if (savedLanguage.isNotEmpty) {
    final parts = savedLanguage.split('_');
    final Locale savedLocale;
    if (parts.length == 2) {
      savedLocale = Locale(parts[0], parts[1]);
    } else {
      savedLocale = Locale(parts[0]);
    }

    // Check if the saved locale is among supported locales
    final isSupported = CommLocalize.supportedLocales.any(
      (l) =>
          l.languageCode == savedLocale.languageCode &&
          (l.countryCode ?? '') == (savedLocale.countryCode ?? ''),
    );

    if (isSupported) {
      CommLocalize.setAppLocale(savedLocale);
      return;
    }
  }

  // 2. If no saved language, use system language
  final systemLocale = CommLocalize.getSystemLocale();
  final langCode = systemLocale?.languageCode ?? "en";

  // Find the best supported locale whose language code matches the device.
  final bestMatch =
      CommLocalize.supportedLocales.cast<Locale?>().firstWhere(
        (l) => l!.languageCode == langCode,
        orElse: () => null,
      ) ??
      const Locale("en", "US");

  CommLocalize.setAppLocale(bestMatch);

  // 3. Save the initially detected language
  final key = bestMatch.countryCode != null && bestMatch.countryCode!.isNotEmpty
      ? '${bestMatch.languageCode}_${bestMatch.countryCode}'
      : bestMatch.languageCode;
  PrefAssist.setString(PrefConst.language, key);
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

      // Draw behind the status and navigation bars so the app's gradient
      // background runs edge to edge. Screens rely on SafeArea for insets.
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      // 1. Firebase Initialization
      try {
        await Firebase.initializeApp();
      } catch (e) {
        debugPrint("Firebase initialization failed: $e");
      }

      // 1.5 Initialize intl date formatting
      await initializeDateFormatting();

      _ensureLocaleConfigured();

      // 2. Initialize translations
      await CommLocalize.loadTranslations("lib/xml_strings", "strings.xml");

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
      locale: CommLocalize.getAppLocale(),
      fallbackLocale: const Locale('en', 'US'),
      supportedLocales: CommLocalize.supportedLocales,
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
