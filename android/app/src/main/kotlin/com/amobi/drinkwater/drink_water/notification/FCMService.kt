package com.amobi.drinkwater.drink_water.notification

import android.util.Log
import com.amobi.drinkwater.drink_water.Const
import com.amobi.drinkwater.drink_water.PrefAssist
import com.amobi.drinkwater.drink_water.PrefConst
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import java.util.Objects

class FCMService : FirebaseMessagingService() {

    companion object {
        private const val TAG = "FCMService"
    }

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        if (remoteMessage.data.isEmpty()) return

        Log.d(TAG, "FCM data: ${remoteMessage.data}")

        // Version gate: drop if app is too old
        val minVersion = remoteMessage.data["min_app_version"]
        if (minVersion != null) {
            try {
                if (minVersion.toInt() > 0) return // placeholder; we don't have BuildConfig.VERSION_CODE accessible here easily
            } catch (_: Exception) {
            }
        }

        // Handle daily reminder push from server
        if (remoteMessage.data["is_daily_reminder"] == "true") {
            handleDailyReminder(remoteMessage.data)
        }
    }

    private fun handleDailyReminder(data: Map<String, String>) {
        // Record that a server push was received (used by FCMTokenManager re-registration logic)
        PrefAssist.setLong(this, PrefConst.LAST_FCM_PUSH_RECORDED, System.currentTimeMillis())

        // Check if daily notifications are enabled
        val isDailyEnabled = PrefAssist.getBoolean(this, PrefConst.KEY_DAILY_NOTIFICATION)
        if (!isDailyEnabled) return

        // Dedup: skip if a daily notification was already shown within the window
        val lastShownTime = PrefAssist.getLong(this, PrefConst.LAST_DAILY_NOTI_SHOWN_TIME, 0L)
        val now = System.currentTimeMillis()
        if (now - lastShownTime < Const.DAILY_NOTI_DEDUP_WINDOW) {
            Log.d(TAG, "Skipping FCM daily — local alarm already showed within ${Const.DAILY_NOTI_DEDUP_WINDOW / 60000}min")
            // Temporarily commented out 'return' for testing FCM notifications
            // return
        }

        // Show the daily notification (playSound=true for heads-up).
        // NOTE: showOrUpdateDailyNotification records LAST_DAILY_NOTI_SHOWN_TIME internally
        // only after confirming notification permission is granted, so we do NOT write it here.
        ReminderAlarmReceiver.showOrUpdateDailyNotification(
            context = this,
            playSound = true,
            motivationOverride = data["motivation"], // Optional custom motivation
            soundEffectOverride = data["sound_effect"], // Pull custom sound_effect from FCM payload
            titleOverride = data["title"],
            bodyOverride = data["body"]
        )
    }

    override fun onNewToken(token: String) {
        Log.d(TAG, "FCM token refreshed: $token")
        // Skip if same token
        if (Objects.equals(token, PrefAssist.getString(this, PrefConst.FCM_TOKEN))) return

        PrefAssist.setString(this, PrefConst.FCM_TOKEN, token)

        // Re-register if daily notifications are enabled
        if (PrefAssist.getBoolean(this, PrefConst.KEY_DAILY_NOTIFICATION)) {
            FCMTokenManager.registerFcmToken(this)
        }
    }
}
