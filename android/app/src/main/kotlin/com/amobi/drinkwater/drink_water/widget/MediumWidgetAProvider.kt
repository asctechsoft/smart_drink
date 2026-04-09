package com.amobi.drinkwater.drink_water.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import com.amobi.drinkwater.drink_water.MainActivity
import com.amobi.drinkwater.drink_water.R
import java.util.Calendar

class MediumWidgetAProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (widgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, widgetId)
        }
        startCountdownService(context)
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        startCountdownService(context)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        context.stopService(Intent(context, WidgetCountdownService::class.java))
    }

    private fun startCountdownService(context: Context) {
        try {
            context.startService(Intent(context, WidgetCountdownService::class.java))
        } catch (_: Exception) {}
    }

    companion object {
        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            widgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.widget_medium_a)

            val percent = WidgetDataHelper.getProgressPercent(context)
            val nextReminder = WidgetDataHelper.getNextReminderTime(context)

            views.setTextViewText(R.id.tv_percentage, "$percent%")
            views.setTextViewText(R.id.tv_label_hours, WidgetDataHelper.getHoursLabel(context))
            views.setTextViewText(R.id.tv_label_minutes, WidgetDataHelper.getMinutesLabel(context))
            views.setTextViewText(R.id.tv_label_seconds, WidgetDataHelper.getSecondsLabel(context))

            if (nextReminder.isNotEmpty()) {
                views.setTextViewText(R.id.tv_next_reminder, WidgetDataHelper.getNextReminderLabel(context, nextReminder))
            } else {
                views.setTextViewText(R.id.tv_next_reminder, WidgetDataHelper.getNoReminderSetLabel(context))
            }

            // Compute countdown to next reminder
            if (nextReminder.isNotEmpty()) {
                val parts = nextReminder.split(":")
                if (parts.size == 2) {
                    val hour = parts[0].toIntOrNull()
                    val minute = parts[1].toIntOrNull()
                    if (hour != null && minute != null &&
                        hour in 0..23 && minute in 0..59) {
                        val now = Calendar.getInstance()
                        val target = Calendar.getInstance().apply {
                            set(Calendar.HOUR_OF_DAY, hour)
                            set(Calendar.MINUTE, minute)
                            set(Calendar.SECOND, 0)
                            set(Calendar.MILLISECOND, 0)
                        }
                        if (target.before(now)) {
                            target.add(Calendar.DAY_OF_YEAR, 1)
                        }
                        val diffMs = target.timeInMillis - now.timeInMillis
                        val totalSec = (diffMs / 1000).toInt().coerceAtLeast(0)
                        val h = totalSec / 3600
                        val m = (totalSec % 3600) / 60
                        val s = totalSec % 60

                        val hStr = h.toString().padStart(2, '0')
                        val mStr = m.toString().padStart(2, '0')
                        val sStr = s.toString().padStart(2, '0')

                        views.setTextViewText(R.id.tv_hour_1, hStr.substring(0, 1))
                        views.setTextViewText(R.id.tv_hour_2, hStr.substring(1, 2))
                        views.setTextViewText(R.id.tv_min_1, mStr.substring(0, 1))
                        views.setTextViewText(R.id.tv_min_2, mStr.substring(1, 2))
                        views.setTextViewText(R.id.tv_sec_1, sStr.substring(0, 1))
                        views.setTextViewText(R.id.tv_sec_2, sStr.substring(1, 2))
                    }
                }
            }

            // Open app on whole widget tap
            val openIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val openPi = PendingIntent.getActivity(
                context, widgetId, openIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, openPi)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
