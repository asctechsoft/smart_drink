package com.amobi.drinkwater.drink_water.notification

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.amobi.drinkwater.drink_water.PrefAssist
import com.amobi.drinkwater.drink_water.PrefConst
import com.amobi.drinkwater.drink_water.widget.MidnightResetReceiver

class AppRestartedReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED &&
            intent.action != Intent.ACTION_MY_PACKAGE_REPLACED
        ) return

        NotificationCenter.createNotificationChannels(context)

        val isOngoing = PrefAssist.getBoolean(context, PrefConst.KEY_NOTIFICATION_ONGOING)
        if (isOngoing) {
            NotificationCenter.startOngoingNotification(context)
            // Restore health-check alarm so notification persists across reboots
            OngoingHealthCheckReceiver.schedule(context)
        }

        val isDaily = PrefAssist.getBoolean(context, PrefConst.KEY_DAILY_NOTIFICATION)
        if (isDaily) {
            NotificationCenter.scheduleDailyNotification(context)
        }

        // Retry FCM registration if previous attempt failed
        if (PrefAssist.getBoolean(context, PrefConst.IS_FCM_TOKEN_REG_FAILED)) {
            FCMTokenManager.registerFcmToken(context)
        }

        // Re-schedule midnight widget reset after boot/update
        MidnightResetReceiver.schedule(context)
    }
}
