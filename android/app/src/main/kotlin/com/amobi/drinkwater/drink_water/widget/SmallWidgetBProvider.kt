package com.amobi.drinkwater.drink_water.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import com.amobi.drinkwater.drink_water.MainActivity
import com.amobi.drinkwater.drink_water.R

class SmallWidgetBProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (widgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, widgetId)
        }
    }

    companion object {
        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            widgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.widget_small_b)

            val currentMl = WidgetDataHelper.getCurrentMl(context)
            val goalMl = WidgetDataHelper.getGoalMl(context)
            val remaining = WidgetDataHelper.getRemainingMl(context)
            val percent = WidgetDataHelper.getProgressPercent(context)

            views.setTextViewText(R.id.tv_amount, WidgetDataHelper.formatVolume(currentMl, context))
            if (WidgetDataHelper.isExceeded(context)) {
                views.setTextViewText(R.id.tv_remaining, WidgetDataHelper.getExceededGoalLabel(context))
            } else if (WidgetDataHelper.isGoalReached(context)) {
                views.setTextViewText(R.id.tv_remaining, WidgetDataHelper.getGoalCompletedLabel(context))
            } else {
                val remainingStr = WidgetDataHelper.formatVolume(remaining, context)
                views.setTextViewText(R.id.tv_remaining, WidgetDataHelper.getRemainingLabel(context, remainingStr))
            }
            views.setTextViewText(R.id.btn_add_drink, WidgetDataHelper.getAddDrinkLabel(context))
            views.setTextViewText(R.id.tv_percentage, "$percent%")
            views.setProgressBar(R.id.progress_bar, 100, percent.coerceAtMost(100), false)

            // Open app on tap (root catches taps on non-button areas)
            val openIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val openPi = PendingIntent.getActivity(
                context, widgetId, openIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, openPi)

            // Quick-add button: Add 250ml
            val addIntent = Intent(context, WidgetActionReceiver::class.java).apply {
                action = WidgetActionReceiver.ACTION_QUICK_ADD
                putExtra(WidgetActionReceiver.EXTRA_AMOUNT, 250)
            }
            val addPi = PendingIntent.getBroadcast(
                context, widgetId, addIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.btn_add_drink, addPi)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
