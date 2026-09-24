import 'dart:async';

import 'package:asc_common/asc_common.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart' show debugPrint, visibleForTesting;

typedef AnalyticsEventSink =
    void Function(String name, Map<String, Object>? parameters);
typedef AnalyticsPropSink = void Function(String name, String value);

/// Central analytics gateway for AquaMind.
///
/// Every event in the app funnels through here — screens and controllers never
/// touch [FirebaseAnalytics] directly. That buys four things at one place:
///
/// * **Name validation.** Firebase silently drops a malformed name; this asserts
///   loudly in dev and drops it in release rather than crashing a user.
/// * **String-only parameters.** GA4 custom dimensions only capture text. A
///   numeric parameter reports `(not set)` and quietly breaks every breakdown
///   built on it, so numbers are bucketed into low-cardinality strings first.
/// * **A swappable sink**, so host tests assert on event names without a
///   platform channel.
///
/// The full event list lives in `docs/analytics_spec.md`. GA4 has no rename —
/// changing a name here starts a new series and orphans the old one, so settle
/// names against that doc before shipping.
class Analytics {
  Analytics._();

  /// Firebase accepts 1–40 characters: a letter, then letters/digits/underscore.
  static final RegExp _validEventName = RegExp(r'^[A-Za-z][A-Za-z0-9_]{0,39}$');
  static const List<String> _reservedEventPrefixes = [
    'firebase_',
    'google_',
    'ga_',
  ];

  static final AscAnalytics _analytics = AscAnalytics(
    FirebaseAnalytics.instance,
  );

  static AnalyticsEventSink _eventSink = _sendToFirebase;
  static AnalyticsPropSink _propSink = _sendPropToFirebase;

  static void _log(String name, [Map<String, Object>? params]) {
    assert(
      isValidEventName(name),
      'Invalid Firebase Analytics event name: $name',
    );
    assert(
      _hasOnlyStringParams(params),
      'Analytics params must be String (GA4 custom dimensions drop numbers): '
      '$name -> $params',
    );
    if (!isValidEventName(name)) return;
    _eventSink(name, params);
  }

  static void _sendToFirebase(String name, Map<String, Object>? params) {
    unawaited(
      _analytics.log(AscAnalyticsEvent(name, params)).catchError((e) {
        debugPrint('Analytics.log($name) failed: $e');
      }),
    );
  }

  static void _sendPropToFirebase(String name, String value) {
    unawaited(
      _analytics.setUserProperty(name, value).catchError((e) {
        debugPrint('Analytics.setUserProperty($name) failed: $e');
      }),
    );
  }

  static void _setProp(String name, String value) => _propSink(name, value);

  /// Sends an event from the spec when no typed helper is warranted. Prefer a
  /// named helper below so the event list stays greppable.
  static void track(String name, [Map<String, Object>? parameters]) =>
      _log(name, parameters);

  /// Sets a user property from the spec when no typed helper is warranted.
  static void setProperty(String name, String value) => _setProp(name, value);

  @visibleForTesting
  static bool isValidEventName(String name) =>
      _validEventName.hasMatch(name) &&
      !_reservedEventPrefixes.any(name.startsWith);

  static bool _hasOnlyStringParams(Map<String, Object>? params) =>
      params == null || params.values.every((value) => value is String);

  /// Swaps both sinks so host tests never reach the Firebase platform channel.
  /// Pass [propSink] to assert on user properties too.
  @visibleForTesting
  static void setEventSinkForTest(
    AnalyticsEventSink eventSink, {
    AnalyticsPropSink? propSink,
  }) {
    _eventSink = eventSink;
    _propSink = propSink ?? (_, _) {};
  }

  @visibleForTesting
  static void resetEventSinkForTest() {
    _eventSink = _sendToFirebase;
    _propSink = _sendPropToFirebase;
  }

  // ============================== Bucket helpers ==============================
  // Every numeric fact reaches GA4 as one of these strings. Keep the band
  // labels stable: renaming a band splits its series just like renaming an
  // event does.

  /// Bands a single drink volume, in millilitres.
  static String volumeBucket(int ml) {
    if (ml <= 0) return '0';
    if (ml < 100) return '<100';
    if (ml < 200) return '100-199';
    if (ml < 300) return '200-299';
    if (ml < 500) return '300-499';
    if (ml < 750) return '500-749';
    if (ml < 1000) return '750-999';
    return '1000+';
  }

  /// Bands a daily goal or a daily total, in millilitres.
  static String goalBucket(int ml) {
    if (ml <= 0) return '0';
    if (ml < 1500) return '<1500';
    if (ml < 2000) return '1500-1999';
    if (ml < 2500) return '2000-2499';
    if (ml < 3000) return '2500-2999';
    if (ml < 4000) return '3000-3999';
    return '4000+';
  }

  /// Bands goal progress as a percentage of the daily goal.
  static String percentBucket(int currentMl, int goalMl) {
    if (goalMl <= 0) return 'unknown';
    final percent = currentMl * 100 ~/ goalMl;
    if (percent <= 0) return '0';
    if (percent < 25) return '1-24';
    if (percent < 50) return '25-49';
    if (percent < 75) return '50-74';
    if (percent < 100) return '75-99';
    if (percent < 150) return '100-149';
    return '150+';
  }

  /// Bands a count of days, drinks, or records.
  static String countBucket(int count) {
    if (count <= 0) return '0';
    if (count <= 3) return '1-3';
    if (count <= 7) return '4-7';
    if (count <= 14) return '8-14';
    if (count <= 30) return '15-30';
    if (count <= 60) return '31-60';
    if (count <= 100) return '61-100';
    return '100+';
  }

  static String _flag(bool value) => value ? '1' : '0';

  // ============================== User properties ==============================

  static void userLanguage(String languageCode) =>
      _setProp('language', languageCode);

  static void userTheme(String theme) => _setProp('theme', theme);

  static void userVolumeUnit(String unit) => _setProp('volume_unit', unit);

  static void userWeightUnit(String unit) => _setProp('weight_unit', unit);

  static void userGender(String gender) => _setProp('gender', gender);

  static void userDailyGoal(int goalMl) =>
      _setProp('daily_goal_bucket', goalBucket(goalMl));

  static void userReminderEnabled(bool enabled) =>
      _setProp('reminder_enabled', _flag(enabled));

  static void userReminderMode(String mode) => _setProp('reminder_mode', mode);

  static void userPermNotification(bool granted) =>
      _setProp('perm_notification', granted ? 'allow_1' : 'allow_0');

  static void userHealthConnectEnabled(bool enabled) =>
      _setProp('health_connect_enabled', _flag(enabled));

  static void userIsPremium(bool isPremium) =>
      _setProp('is_premium', _flag(isPremium));

  static void userIsLoggedIn(bool isLoggedIn) =>
      _setProp('is_logged_in', _flag(isLoggedIn));

  static void userStreak(int days) =>
      _setProp('streak_bucket', countBucket(days));

  static void userDrinkCount(int count) =>
      _setProp('drink_count_bucket', countBucket(count));

  static void userAvatar(String avatarId) => _setProp('avatar', avatarId);

  static void userOpenAppInDayN(int dayN) =>
      _setProp('user_open_app_in_day_n', 'day_$dayN');

  /// The A/B branch the guided tour assigned this install. Set once per session
  /// so every event in the session can be broken down by branch, not only the
  /// tour's own events.
  static void userTourVariant(String variant) =>
      _setProp('tour_variant', variant);

  // ============================== App lifecycle ==============================

  static void appOpen(String source, {required bool isFirstOpen}) =>
      _log(isFirstOpen ? 'app_first_open' : 'app_open', {'source': source});

  static void splashView() => _log('splash_view');

  static void splashEnd({required bool onboarded}) =>
      _log('splash_end', {'destination': onboarded ? 'home' : 'onboarding'});

  // ============================== Onboarding ==============================

  /// [step] is the spec's screen slug — `language`, `welcome`, `gender`, …
  static void onboardingView(String step) =>
      _log('onboarding_view', {'step': step});

  static void onboardingNext(String step) =>
      _log('onboarding_next_tap', {'step': step});

  static void onboardingBack(String step) =>
      _log('onboarding_back_tap', {'step': step});

  static void onboardingGenderSelect(String gender) =>
      _log('onboarding_gender_select', {'gender': gender});

  static void onboardingHeightSet(String unit) =>
      _log('onboarding_height_set', {'unit': unit});

  static void onboardingWeightSet(String unit) =>
      _log('onboarding_weight_set', {'unit': unit});

  static void onboardingWeatherSelect(String condition) =>
      _log('onboarding_weather_select', {'condition': condition});

  static void onboardingWakeupSet() => _log('onboarding_wakeup_set');

  static void onboardingBedtimeSet() => _log('onboarding_bedtime_set');

  static void onboardingNapToggle(bool enabled) =>
      _log('onboarding_nap_toggle', {'enabled': _flag(enabled)});

  static void onboardingGoalView(int goalMl) =>
      _log('onboarding_goal_view', {'goal_bucket': goalBucket(goalMl)});

  static void onboardingComplete(int goalMl) =>
      _log('onboarding_complete', {'goal_bucket': goalBucket(goalMl)});

  static void notificationPermissionView() =>
      _log('noti_permission_first_view');

  static void notificationPermissionResult({required bool granted}) => _log(
    granted ? 'noti_permission_first_accept' : 'noti_permission_first_deny',
  );

  // ============================== Navigation ==============================

  /// [tab] is `today`, `history`, `reminders` or `settings`.
  static void navTap(String tab) => _log('nav_${tab}_tap');

  // ============================== Today ==============================

  static void todayView() => _log('today_view');

  static void drinkAddTap(String source) =>
      _log('drink_add_tap', {'source': source});

  static void drinkAddSuccess({
    required String drinkType,
    required int amountMl,
    required int totalMl,
    required int goalMl,
    required String source,
  }) => _log('drink_add_success', {
    'drink_type': drinkType,
    'amount_bucket': volumeBucket(amountMl),
    'progress_bucket': percentBucket(totalMl, goalMl),
    'source': source,
  });

  static void drinkTypeSelect(String drinkType) =>
      _log('drink_type_select', {'drink_type': drinkType});

  static void drinkAmountSelect(int amountMl) =>
      _log('drink_amount_select', {'amount_bucket': volumeBucket(amountMl)});

  static void drinkGoalReached(int goalMl) =>
      _log('drink_goal_reached', {'goal_bucket': goalBucket(goalMl)});

  static void todayQuickActionTap(String action) =>
      _log('today_quick_action_tap', {'action': action});

  static void addDrinkScreenView() => _log('add_drink_view');

  // ============================== History ==============================

  static void historyView() => _log('history_view');

  /// [period] is `day`, `week`, `month` or `year`.
  static void historyPeriodSelect(String period) =>
      _log('history_period_select', {'period': period});

  /// [direction] is `previous` or `next`.
  static void historyPeriodChange(String direction, String period) =>
      _log('history_period_change', {'direction': direction, 'period': period});

  static void historyBackToToday() => _log('history_back_to_today');

  static void historyRecordEdit() => _log('history_record_edit');

  static void historyRecordDelete() => _log('history_record_delete');

  // ============================== Streak ==============================

  static void streakView() => _log('streak_view');

  static void streakMonthChange(String direction) =>
      _log('streak_month_change', {'direction': direction});

  // ============================== Reminder ==============================

  static void reminderView() => _log('reminder_view');

  static void reminderToggle(bool enabled) =>
      _log('reminder_toggle', {'enabled': _flag(enabled)});

  /// [mode] is `standard`, `interval` or `custom`.
  static void reminderModeSelect(String mode) =>
      _log('reminder_mode_select', {'mode': mode});

  static void reminderIntervalSelect(int minutes) =>
      _log('reminder_interval_select', {'minutes': '$minutes'});

  static void reminderSlotAdd() => _log('reminder_slot_add');

  static void reminderSlotEdit() => _log('reminder_slot_edit');

  static void reminderSlotDelete() => _log('reminder_slot_delete');

  static void reminderSlotToggle(bool enabled) =>
      _log('reminder_slot_toggle', {'enabled': _flag(enabled)});

  static void reminderRepeatDaysChange(int dayCount) =>
      _log('reminder_repeat_days_change', {'day_count': '$dayCount'});

  static void reminderSleepTimeSet(String which) =>
      _log('reminder_sleep_time_set', {'which': which});

  static void reminderSoundSelect(String sound) =>
      _log('reminder_sound_select', {'sound': sound});

  static void reminderSave(String mode, int slotCount) => _log('reminder_save', {
    'mode': mode,
    'slot_count_bucket': countBucket(slotCount),
  });

  static void reminderNotiOpen() => _log('reminder_noti_open');

  // ============================== Settings ==============================

  static void settingsView() => _log('settings_view');

  /// [row] is the spec's settings-row slug — `theme`, `language`, `unit`, …
  static void settingsRowTap(String row) =>
      _log('settings_row_tap', {'row': row});

  static void settingsThemeSelect(String theme) =>
      _log('settings_theme_select', {'theme': theme});

  /// Fired from `LanguagesController.changeLanguage`, the single funnel both
  /// the onboarding language picker and the settings language sheet call —
  /// so the event covers both entry points without a `source` param.
  static void languageSelect(String language) =>
      _log('language_select', {'language': language});

  static void settingsUnitSelect(String kind, String unit) =>
      _log('settings_unit_select', {'kind': kind, 'unit': unit});

  /// A profile field saved from a settings sheet — gender, weather, height,
  /// weight, wake-up time, bedtime, nap window. [field] and [value] are fixed
  /// slugs from app code, mirroring the row slug used by [settingsRowTap].
  static void settingsFieldSave(String field, String value) =>
      _log('settings_field_save', {'field': field, 'value': value});

  static void settingsSoundToggle(bool enabled) =>
      _log('settings_sound_toggle', {'enabled': _flag(enabled)});

  static void settingsVibrateToggle(bool enabled) =>
      _log('settings_vibrate_toggle', {'enabled': _flag(enabled)});

  static void settingsGoalEdit(int goalMl) =>
      _log('settings_goal_edit', {'goal_bucket': goalBucket(goalMl)});

  static void settingsHealthConnectToggle({
    required bool enabled,
    required bool success,
  }) => _log('settings_health_connect_toggle', {
    'enabled': _flag(enabled),
    'success': _flag(success),
  });

  static void settingsShareTap() => _log('settings_share_tap');

  static void settingsRateTap() => _log('settings_rate_tap');

  static void settingsRateSubmit(int stars) =>
      _log('settings_rate_submit', {'stars': '$stars'});

  static void widgetPreviewView() => _log('widget_preview_view');

  static void feedbackView() => _log('feedback_view');

  static void feedbackSubmit({required bool hasText}) =>
      _log('feedback_submit', {'has_text': _flag(hasText)});

  // ============================== Avatar ==============================

  static void avatarView() => _log('avatar_view');

  static void avatarSelect(String avatarId) =>
      _log('avatar_select', {'avatar': avatarId});

  static void avatarSave(String avatarId) =>
      _log('avatar_save', {'avatar': avatarId});

  // ============================== AI chat ==============================

  static void chatView(String source) => _log('chat_view', {'source': source});

  static void chatSend({required bool isSuggestion, required int quotaLeft}) =>
      _log('chat_send', {
        'is_suggestion': _flag(isSuggestion),
        'quota_left': '$quotaLeft',
      });

  static void chatResponseSuccess() => _log('chat_response_success');

  /// [reason] is a fixed slug from app code, never a raw server message.
  static void chatResponseFail(String reason) =>
      _log('chat_response_fail', {'reason': reason});

  static void chatRetry() => _log('chat_retry');

  static void chatNew() => _log('chat_new');

  static void chatQuotaExhausted() => _log('chat_quota_exhausted');

  // ============================== Premium / IAP ==============================

  static void premiumView(String source) =>
      _log('premium_view', {'source': source});

  static void premiumPurchaseTap(String productId) =>
      _log('premium_purchase_tap', {'product_id': productId});

  static void premiumPurchaseSuccess(String productId) =>
      _log('premium_purchase_success', {'product_id': productId});

  // ============================== Auth ==============================

  static void loginTap(String method) => _log('login_tap', {'method': method});

  static void loginSuccess(String method) =>
      _log('login_success', {'method': method});

  static void loginFail(String method) =>
      _log('login_fail', {'method': method});

  static void logout() => _log('logout');
}
