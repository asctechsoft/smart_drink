import 'dart:ui';

import 'package:asc_common/asc_common.dart';

import 'pref_const.dart';

/// This app's language setup for [AscLocale]: one locale per
/// `lib/xml_strings/values*/` folder, persisted under [PrefConst] keys.
class AppLocaleConfig {
  AppLocaleConfig._();

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en', 'US'),
    Locale('vi', 'VN'),
    Locale('fr', 'FR'),
    Locale('it', 'IT'),
    Locale('de', 'DE'),
    Locale('es', 'ES'),
    Locale('ru', 'RU'),
    Locale('pt', 'PT'),
    Locale('tr', 'TR'),
    Locale('ar', 'SA'),
    Locale('id', 'ID'),
    Locale('fa', 'IR'),
    Locale('zh', 'CN'),
    Locale('zh', 'TW'),
    Locale('ja', 'JP'),
    Locale('ko', 'KR'),
  ];

  /// Call once at startup, before any [AscLocale] use.
  static void configure() => AscLocale.configure(
    supportedLocales: supportedLocales,
    languagePrefKey: PrefConst.language,
    followSystemPrefKey: PrefConst.followSystemLanguage,
  );
}
