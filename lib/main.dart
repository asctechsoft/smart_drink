import 'package:dsp_base/comm_app.dart';
import 'package:dsp_base/app_localize.dart';
import 'package:dsp_base/convenience_imports.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'configs/pref_const.dart';
import 'configs/pref_defaults.dart';
import 'controller/user_profile_controller.dart';
import 'controller/today_controller.dart';
import 'controller/history_controller.dart';
import 'controller/settings_controller.dart';
import 'controller/reminder_controller.dart';
import 'values/app_theme.dart';
import 'values/app_pages.dart';
import 'values/route_name.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/storage/sqflite_web_helper.dart';

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
  late ThemeMode initialThemeMode;

  await commRunApp(
    () => DrinkWaterApp(initialThemeMode: initialThemeMode),
    onBindingInitialized: (widgetsBinding) async {
      // 0. Configure sqflite for web (no-op on native)
      await configureSqfliteForWeb();

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

      // 3. Load saved theme
      final savedTheme = PrefAssist.getString(
        PrefConst.themeMode,
        defaultValue: PrefDefaults.themeMode,
      );
      initialThemeMode = switch (savedTheme) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
    },
  );
}

class DrinkWaterApp extends StatelessWidget {
  final ThemeMode initialThemeMode;

  const DrinkWaterApp({super.key, required this.initialThemeMode});

  @override
  Widget build(BuildContext context) {
    return CommApp(
      title: 'drink_water'.tr,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: initialThemeMode,
      locale: CommLocalize.getAppLocale(),
      fallbackLocale: const Locale('en', 'US'),
      supportedLocales: CommLocalize.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: RouteName.splash,
      initialBinding: BindingsBuilder(() {
        Get.put(SettingsController(), permanent: true);
        Get.put(UserProfileController(), permanent: true);
        Get.put(TodayController(), permanent: true);
        Get.put(HistoryController(), permanent: true);
        Get.put(ReminderController(), permanent: true);
      }),
      getPages: AppPages.pages,
    );
  }
}
