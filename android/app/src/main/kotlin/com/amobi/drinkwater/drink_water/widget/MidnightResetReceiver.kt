package com.amobi.drinkwater.drink_water.widget

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.amobi.drinkwater.drink_water.PrefAssist
import com.amobi.drinkwater.drink_water.PrefConst
import java.util.Calendar

/**
 * Resets widget data at midnight so widgets show 0 ml for the new day
 * instead of stale data from the previous day.
 */
class MidnightResetReceiver : BroadcastReceiver() {

    companion object {
        const val ACTION_MIDNIGHT_RESET = "com.amobi.drinkwater.MIDNIGHT_RESET"

        fun schedule(context: Context) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

            val intent = Intent(context, MidnightResetReceiver::class.java).apply {
                action = ACTION_MIDNIGHT_RESET
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context, 9999, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            // Schedule for next midnight
            val midnight = Calendar.getInstance().apply {
                add(Calendar.DAY_OF_YEAR, 1)
                set(Calendar.HOUR_OF_DAY, 0)
                set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 5) // 5 seconds past midnight for safety
                set(Calendar.MILLISECOND, 0)
            }

            alarmManager.setAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                midnight.timeInMillis,
                pendingIntent
            )
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION_MIDNIGHT_RESET) return

        // Reset widget data for new day
        PrefAssist.setInt(context, PrefConst.ONGOING_CURRENT_ML, 0)
        PrefAssist.setString(context, PrefConst.WIDGET_RECENT_DRINKS, "")

        // Refresh all widgets to show 0
        WidgetUpdateHelper.refreshAllWidgets(context)

        // Re-schedule for next midnight
        schedule(context)
    }
}
