import 'package:device_region/device_region.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waternudge/configs/pref_const.dart';
import 'package:waternudge/services/app_localize.dart';
import 'package:waternudge/utils/analytics.dart';
import 'package:waternudge/utils/loading_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'settings_controller.dart';

class LanguagesController extends GetxController {
  final Rx<Locale> currentAppLocale = AppLocalize.getAppLocale().obs;
  final Rx<Locale?> regionSuggestedLocale = Rx<Locale?>(null);

  static const int _maxLocaleHistorySize = 3;

  /// In-memory cache of the persisted MRU history, so [getSuggestedLocales]
  /// (called synchronously from a widget `build()`) never has to await a
  /// pref read. Loaded once in [onInit]; kept in sync by
  /// [_pushLocaleToHistory] on every language change.
  String _historyRaw = '';

  @override
  void onInit() {
    super.onInit();
    _loadHistoryCache();
    _loadRegionSuggestedLocale();
  }

  Future<void> _loadHistoryCache() async {
    final prefs = await SharedPreferences.getInstance();
    _historyRaw = prefs.getString(PrefConst.languageSelectionHistory) ?? '';
  }

  Future<void> _loadRegionSuggestedLocale() async {
    try {
      final countryCode = await DeviceRegion.getSIMCountryCode();
      if (countryCode == null || countryCode.length != 2) return;
      const supported = AppLocalize.supportedLocales;
      final deviceLocale = AppLocalize.getSystemLocale();
      final upper = countryCode.toUpperCase();
      final matching = supported
          .where((l) => (l.countryCode ?? '').toUpperCase() == upper)
          .toList();
      if (matching.isEmpty) return;
      var pick = matching.first;
      if (deviceLocale != null && matching.length > 1) {
        for (final l in matching) {
          if (l.languageCode == deviceLocale.languageCode) {
            pick = l;
            break;
          }
        }
      }
      regionSuggestedLocale.value = pick;
    } catch (e) {
      debugPrint('LanguagesController: region detection failed: $e');
    }
  }

  Future<void> changeLanguage(Locale locale) async {
    // Show loading overlay
    LoadingUtils.show();

    // Small delay to allow the loading dialog to render before the heavy UI blocking task
    await Future.delayed(const Duration(milliseconds: 150));

    await AppLocalize.setAppLocale(locale);
    currentAppLocale.value = locale;
    await _pushLocaleToHistory(locale);

    // AppLocalize.setAppLocale already persisted PrefConst.language.
    final key = _localeToKey(locale);

    // Sync with SettingsController so the settings screen updates reactively
    if (Get.isRegistered<SettingsController>()) {
      Get.find<SettingsController>().language.value = key;
    }

    Analytics.languageSelect(key);
    Analytics.userLanguage(key);

    // Dismiss loading overlay
    LoadingUtils.hide();
  }

  Future<void> _pushLocaleToHistory(Locale locale) async {
    const supported = AppLocalize.supportedLocales;
    if (!supported.any((l) => _localeEquals(l, locale))) return;
    final key = _localeToKey(locale);
    final list = _historyRaw.isEmpty
        ? <String>[]
        : _historyRaw.split(',').where((s) => s.isNotEmpty).toList();
    list.remove(key);
    list.insert(0, key);
    final trimmed = list.take(_maxLocaleHistorySize).toList();
    _historyRaw = trimmed.join(',');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefConst.languageSelectionHistory, _historyRaw);
  }

  static bool _localeEquals(Locale a, Locale b) =>
      a.languageCode == b.languageCode &&
      (a.countryCode ?? '') == (b.countryCode ?? '');

  static String _localeToKey(Locale l) =>
      l.countryCode != null && l.countryCode!.isNotEmpty
      ? '${l.languageCode}_${l.countryCode}'
      : l.languageCode;

  static Locale? _keyToLocale(String key, List<Locale> supported) {
    if (key.contains('_')) {
      final parts = key.split('_');
      if (parts.length == 2) {
        for (final l in supported) {
          if (l.languageCode == parts[0] && (l.countryCode ?? '') == parts[1]) {
            return l;
          }
        }
        return null;
      }
    }
    for (final l in supported) {
      if (l.languageCode == key) return l;
    }
    return null;
  }

  List<Locale> getSuggestedLocales() {
    const english = Locale('en', 'US');
    const supported = AppLocalize.supportedLocales;
    final deviceLocale = AppLocalize.getSystemLocale();
    final historyKeys = _historyRaw.isEmpty
        ? <String>[]
        : _historyRaw.split(',').where((s) => s.isNotEmpty).toList();
    final fromHistory = historyKeys
        .map((k) => _keyToLocale(k, supported))
        .whereType<Locale>()
        .toList();

    final seen = <String>{};
    final result = <Locale>[];
    void add(Locale? l) {
      if (l == null || result.length >= 3) return;
      if (!supported.any((s) => _localeEquals(s, l))) return;
      final k = _localeToKey(l);
      if (seen.contains(k)) return;
      seen.add(k);
      result.add(l);
    }

    // Priority 1: History (newest picking first)
    for (final l in fromHistory) {
      add(l);
    }

    // Priority 2: System locale (device language)
    add(deviceLocale);

    // Priority 3: Region suggested language
    add(regionSuggestedLocale.value);

    // Priority 4: Default fallback (English)
    add(english);

    return result;
  }
}

