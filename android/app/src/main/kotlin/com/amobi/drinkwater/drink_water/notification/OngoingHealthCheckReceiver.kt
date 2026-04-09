package com.amobi.drinkwater.drink_water.notification

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import com.amobi.drinkwater.drink_water.Const
import com.amobi.drinkwater.drink_water.PrefAssist
import com.amobi.drinkwater.drink_water.PrefConst

/**
 * Periodic health-check receiver that ensures the ongoing notification
 * stays visible when the sticky setting is enabled.
 *
 * Some Android OEM skins and Android 14+ allow users to clear ongoing
 * notifications. This receiver fires every [INTERVAL_MS] (15 minutes)
 * and re-starts the foreground service if needed.
 */
class OngoingHealthCheckReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "OngoingHealthCheck"
        private const val INTERVAL_MS = 15 * 60 * 1000L // 15 minutes

        /**
         * Schedule repeating health-check alarm.
         * Safe to call multiple times — cancels any existing alarm first.
         */
        fun schedule(context: Context) {
            val alarmManager =
                context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

            val pendingIntent = buildPendingIntent(context)
            // Cancel existing alarm first to avoid duplicates
            alarmManager.cancel(pendingIntent)

            val triggerAt = System.currentTimeMillis() + INTERVAL_MS

            alarmManager.setRepeating(
                AlarmManager.RTC_WAKEUP,
                triggerAt,
                INTERVAL_MS,
                pendingIntent
            )
            Log.d(TAG, "Health-check alarm scheduled (every 15 min)")
        }

        /** Cancel the health-check alarm. */
        fun cancel(context: Context) {
            val alarmManager =
                context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            alarmManager.cancel(buildPendingIntent(context))
            Log.d(TAG, "Health-check alarm cancelled")
        }

        private fun buildPendingIntent(context: Context): PendingIntent {
            val intent = Intent(context, OngoingHealthCheckReceiver::class.java)
            return PendingIntent.getBroadcast(
                context,
                Const.ONGOING_HEALTH_CHECK_REQUEST_CODE,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }
    }

    override fun onReceive(context: Context, intent: Intent?) {
        val isOngoingEnabled =
            PrefAssist.getBoolean(context, PrefConst.KEY_NOTIFICATION_ONGOING)

        if (!isOngoingEnabled) {
            // Setting was turned off — stop checking
            cancel(context)
            return
        }

        // Re-start the foreground service. If it's already running this is
        // essentially a no-op (service receives ACTION_START again and
        // re-posts the notification).
        Log.d(TAG, "Health-check firing — ensuring ongoing notification is visible")
        try {
            WaterTrackingService.start(context)
        } catch (e: Exception) {
            Log.w(TAG, "Could not restart ongoing service", e)
        }
    }
}
