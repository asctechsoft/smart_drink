import 'package:flutter/widgets.dart';

/// Endonyms for the app's supported locales — the language's own name, as shown
/// on the primary line of a language row. Names are kept plain (no country
/// suffix); the English name from `CommLocalize.getLocaleName` disambiguates
/// regional variants on the secondary line.
class LanguageNames {
  LanguageNames._();

  static const Map<String, String> _native = {
    'en_US': 'English',
    'vi_VN': 'Tiếng Việt',
    'fr_FR': 'Français',
    'it_IT': 'Italiano',
    'de_DE': 'Deutsch',
    'es_ES': 'Español',
    'ru_RU': 'Русский',
    'pt_PT': 'Português',
    'tr_TR': 'Türkçe',
    'ar_SA': 'العربية',
    'id_ID': 'Bahasa Indonesia',
    'fa_IR': 'فارسی',
    'zh_CN': '简体中文',
    'zh_TW': '繁體中文',
    'ja_JP': '日本語',
    'ko_KR': '한국어',
  };

  /// The locale's endonym, falling back to the language code when unmapped.
  static String nativeName(Locale locale) =>
      _native[locale.toString()] ??
      _native[locale.languageCode] ??
      locale.languageCode.toUpperCase();
}
