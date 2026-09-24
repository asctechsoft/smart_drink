import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart';
import 'package:waternudge/configs/pref_const.dart';

/// App-owned replacement for dsp_base's `CommLocalize`.
///
/// `.tr` / `.trParams` themselves are GetX's own `Trans` extension on
/// `String`, backed by `Get.translations` / `Get.locale` — untouched by this
/// class. All this owns is *what's* in `Get.translations` (parsed from this
/// app's `lib/xml_strings/values*/strings.xml`, Android-style XML) and which
/// `Get.locale` is active.
///
/// The XML→GetX conversion matters: `%1$s`/`%2$s`/... (Android's positional
/// placeholders, as authored in the XML) are rewritten to `@args1`/`@args2`/
/// ... (GetX's `trParams` placeholder syntax) at load time — this is what
/// makes every `.trParams({'args1': ...})` call in the app work. A naive XML
/// parser would leave `%1$s` untouched and silently break every one of them.
class AppLocalize {
  AppLocalize._();

  static const String _root = 'lib/xml_strings';
  static const String _fileName = 'strings.xml';

  static final Map<String, Map<String, String>> _translations = {};

  /// Cached from [PrefConst.language] so [getConfiguredLocale] /
  /// [getAppLocale] can stay synchronous (both are read from non-async
  /// contexts — a widget `build()`, a field initializer). Warmed by the
  /// first [setAppLocale] call, which `main.dart` always makes during
  /// startup before anything else reads it.
  static Locale? _configuredLocale;

  /// The locales the app offers — one per `lib/xml_strings/values*/` folder.
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

  /// Loads `en_US` (the fallback) plus whichever locale the device or the
  /// already-configured app language needs, into GetX's global translation
  /// table. Call once at startup, before the app builds — mirrors the one
  /// real call site this ever had (`lib/main.dart`).
  static Future<void> loadTranslations() async {
    final deviceLanguageCode = getSystemLocale()?.languageCode ?? '';
    final appLanguageCode = getAppLocale().languageCode;

    for (final locale in supportedLocales) {
      final localeName = locale.toString();
      if (localeName != 'en_US' &&
          locale.languageCode != deviceLanguageCode &&
          locale.languageCode != appLanguageCode) {
        continue;
      }
      await _ensureLoaded(locale);
    }
    Get.addTranslations(_translations);
  }

  /// Persists [locale], loads its strings if they weren't already (covers a
  /// locale picked by hand that wasn't the device/app pair [loadTranslations]
  /// preloaded), then activates it.
  ///
  /// Deliberately `Get.locale = locale; Get.appUpdate();`, never
  /// `Get.updateLocale()` — that calls `forceAppUpdate()`, a full engine
  /// reassemble that remounts `GetMaterialApp` from its `initialRoute` and
  /// drops the navigator stack. Setting `Get.locale` + `appUpdate()` rebuilds
  /// the root builder in place (same Element, same Navigator State),
  /// refreshing every `.tr` string without touching the route stack.
  static Future<void> setAppLocale(Locale locale) async {
    _configuredLocale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefConst.language, _localeKey(locale));

    await _ensureLoaded(locale);
    Get.addTranslations(_translations);

    Get.locale = locale;
    Get.appUpdate();
  }

  static Future<void> _ensureLoaded(Locale locale) async {
    final localeName = locale.toString();
    if (_translations.containsKey(localeName)) return;
    try {
      _translations[localeName] = await _loadXml(_filePath(locale));
    } catch (e) {
      debugPrint('AppLocalize: failed to load $localeName: $e');
    }
  }

  static Locale? getConfiguredLocale() => _configuredLocale;

  /// The actual system locale from the platform — more reliable than
  /// `Get.deviceLocale`, which can return the wrong value on some devices.
  static Locale? getSystemLocale() {
    try {
      final locales = WidgetsBinding.instance.platformDispatcher.locales;
      if (locales.isNotEmpty) return locales.first;
    } catch (e) {
      debugPrint('AppLocalize: getSystemLocale failed: $e');
    }
    return Get.deviceLocale;
  }

  static Locale getAppLocale() =>
      _configuredLocale ??
      Get.locale ??
      getSystemLocale() ??
      const Locale('en', 'US');

  /// English display name for a locale, e.g. "Vietnamese (Vietnam)" — the
  /// secondary line under [LanguageNames.nativeName]'s endonym.
  static String getLocaleName(Locale locale) {
    const names = <String, String>{
      'en': 'English (United States)',
      'vi': 'Vietnamese (Vietnam)',
      'fr': 'French (France)',
      'it': 'Italian (Italy)',
      'de': 'German (Germany)',
      'es': 'Spanish (Spain)',
      'ru': 'Russian (Russia)',
      'pt': 'Portuguese (Portugal)',
      'tr': 'Turkish (Turkey)',
      'ar': 'Arabic (Saudi Arabia)',
      'id': 'Indonesian (Indonesia)',
      'fa': 'Persian (Iran)',
      'ja': 'Japanese (Japan)',
      'ko': 'Korean (South Korea)',
    };
    if (locale.languageCode == 'zh') {
      return locale.countryCode == 'TW'
          ? 'Chinese (Traditional)'
          : 'Chinese (Simplified)';
    }
    return names[locale.languageCode] ?? locale.toString();
  }

  static String _localeKey(Locale l) =>
      l.countryCode != null && l.countryCode!.isNotEmpty
      ? '${l.languageCode}_${l.countryCode}'
      : l.languageCode;

  static String _filePath(Locale locale) {
    final folder = locale.languageCode == 'en'
        ? 'values'
        : locale.toString() == 'zh_TW'
        ? 'values-zh-rTW'
        : locale.toString() == 'zh_CN' || locale.languageCode == 'zh'
        ? 'values-zh-rCN'
        : 'values-${locale.languageCode}';
    return '$_root/$folder/$_fileName';
  }

  static Future<Map<String, String>> _loadXml(String path) async {
    final xmlString = await rootBundle.loadString(path);
    final document = XmlDocument.parse(xmlString);
    final translations = <String, String>{};
    for (final node in document.findAllElements('string')) {
      final key = node.getAttribute('name');
      if (key == null) continue;
      assert(
        !translations.containsKey(key),
        'Duplicated localization key "$key" in $path',
      );
      translations[key] = node.innerText
          .replaceAll('\\"', '"')
          .replaceAll("\\'", "'")
          .replaceAll(r'\r\n', '\n')
          .replaceAll(r'\n', '\n')
          .replaceAll(r'\t', '\t')
          .replaceAll('%1\$s', '@args1')
          .replaceAll('%2\$s', '@args2')
          .replaceAll('%3\$s', '@args3')
          .replaceAll('%4\$s', '@args4')
          .replaceAll('%5\$s', '@args5')
          .replaceAll('%6\$s', '@args6')
          .replaceAll('%7\$s', '@args7')
          .replaceAll('%8\$s', '@args8');
    }
    return translations;
  }
}
