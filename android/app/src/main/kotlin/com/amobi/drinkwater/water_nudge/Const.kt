package com.amobi.drinkwater.drink_water

object Const {
    const val ONGOING_NOTIFICATION_ID = 629688
    const val DAILY_NOTIFICATION_ID = 16699

    const val ONGOING_CHANNEL_ID = "OngoingNotifyChannel"
    const val DAILY_CHANNEL_ID = "DailyNotifyChannel"
    const val DAILY_CHANNEL_SILENT_ID = "DailyNotifyChannelSilent"

    const val NOTIF_ID_MORNING = 1
    const val NOTIF_ID_AFTERNOON = 2
    const val NOTIF_ID_NIGHT = 3

    const val DEFAULT_HOUR_MORNING = 8
    const val DEFAULT_HOUR_AFTERNOON = 13
    const val DEFAULT_HOUR_NIGHT = 21

    const val MILLIS_MINUTE = 60 * 1000L
    const val MILLIS_HOUR = 60 * MILLIS_MINUTE
    const val MILLIS_DAY = 24 * MILLIS_HOUR

    const val KEY_NOTIF_HOUR_MORNING = "key_notif_hour_morning"
    const val KEY_NOTIF_MINUTE_MORNING = "key_notif_minute_morning"
    const val KEY_NOTIF_HOUR_AFTERNOON = "key_notif_hour_afternoon"
    const val KEY_NOTIF_MINUTE_AFTERNOON = "key_notif_minute_afternoon"
    const val KEY_NOTIF_HOUR_NIGHT = "key_notif_hour_night"
    const val KEY_NOTIF_MINUTE_NIGHT = "key_notif_minute_night"

    // Dynamic alarm scheduling
    const val DYNAMIC_ALARM_BASE_REQUEST_CODE = 300
    const val MAX_REMINDER_ALARMS = 500
    const val THROTTLE_MINUTES = 1430 // 23h50m — prevents double-fire without suppressing next-day
    const val MILLIS_THROTTLE = THROTTLE_MINUTES * MILLIS_MINUTE

    // Health-check alarm for ongoing notification persistence
    const val ONGOING_HEALTH_CHECK_REQUEST_CODE = 500

    // FCM registration
    const val REREG_FCM_TOKEN_TIME = 3 * MILLIS_DAY       // re-register if no push for 3 days
    const val DAILY_NOTI_DEDUP_WINDOW = 10 * MILLIS_MINUTE // skip if shown within 10 min

    // Firestore collection for FCM tokens
    const val FIRESTORE_FCM_COLLECTION = "dw_fcm_tokens"
}
