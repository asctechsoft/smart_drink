package com.amobi.drinkwater.drink_water

object PrefConst {
    // Flutter shared_preferences keys (accessed with flutter. prefix via PrefAssist)
    const val KEY_NOTIFICATION_ONGOING = "flutter.notification_ongoing_enabled"
    const val KEY_DAILY_NOTIFICATION = "flutter.notification_daily_enabled"
    const val KEY_DAILY_NOTIFICATION_MORNING = "flutter.notification_daily_morning"
    const val KEY_DAILY_NOTIFICATION_AFTERNOON = "flutter.notification_daily_afternoon"
    const val KEY_DAILY_NOTIFICATION_NIGHT = "flutter.notification_daily_night"
    const val KEY_DAILY_HOUR_MORNING = "flutter.notification_daily_hour_morning"
    const val KEY_DAILY_HOUR_AFTERNOON = "flutter.notification_daily_hour_afternoon"
    const val KEY_DAILY_HOUR_NIGHT = "flutter.notification_daily_hour_night"
    const val IS_FULL_SCREEN_INTENT_ENABLED = "flutter.is_full_screen_intent_enabled"
    const val KEY_VIBRATE_ENABLED = "flutter.vibrate_enabled"

    // Ongoing notification data (written by Flutter, read by native)
    const val ONGOING_CURRENT_ML = "flutter.ongoing_current_ml"
    const val ONGOING_GOAL_ML = "flutter.ongoing_goal_ml"
    const val ONGOING_LAST_DRINK_TEXT = "flutter.ongoing_last_drink_text"

    // Throttle keys
    const val KEY_TIME_CALLED_DAILY_NOTIFICATION_MORNING = "time_called_daily_morning"
    const val KEY_TIME_CALLED_DAILY_NOTIFICATION_AFTERNOON = "time_called_daily_afternoon"
    const val KEY_TIME_CALLED_DAILY_NOTIFICATION_NIGHT = "time_called_daily_night"

    // Widget recent drinks JSON (written by Flutter, read by widget providers)
    const val WIDGET_RECENT_DRINKS = "flutter.widget_recent_drinks"

    // Volume unit for widget display (written by Flutter, read by widgets)
    const val WIDGET_VOLUME_UNIT = "flutter.widget_volume_unit"

    // Dynamic reminder schedule storage
    const val KEY_REMINDER_SCHEDULES_JSON = "flutter.reminder_schedules_json"
    const val KEY_REMINDER_ALARM_COUNT = "reminder_alarm_count"

    // Add water pending flag (native writes, Flutter reads)
    const val PENDING_ADD_WATER = "flutter.pending_add_water"
    const val PENDING_ADD_WATER_AMOUNT = "flutter.pending_add_water_amount"
    const val PENDING_ADD_WATER_JSON = "flutter.pending_add_water_json"

    // FCM token registration
    const val FCM_TOKEN = "flutter.fcm_token"
    const val IS_FCM_TOKEN_REG_FAILED = "fcm_token_reg_failed"
    const val LAST_FCM_PUSH_RECORDED = "fcm_last_push_recorded"
    const val FCM_TOKEN_UPDATE_TIMESTAMP = "fcm_token_update_timestamp"
    const val FCM_TOKEN_RE_UPDATE_TIME = 21 * 24 * 60 * 60 * 1000L  // 21 days

    // Dedup: last time a daily notification was actually shown
    const val LAST_DAILY_NOTI_SHOWN_TIME = "last_daily_noti_shown_time"
}
