package com.amobi.drinkwater.drink_water.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import com.amobi.drinkwater.drink_water.MainActivity
import com.amobi.drinkwater.drink_water.R

class SmallWidgetAProvider : AppWidgetProvider() {

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
            val views = RemoteViews(context.packageName, R.layout.widget_small_a)

            val currentMl = WidgetDataHelper.getCurrentMl(context)
            val goalMl = WidgetDataHelper.getGoalMl(context)

            views.setTextViewText(R.id.tv_current_ml, WidgetDataHelper.formatVolumeShort(currentMl, context))
            val unitLabel = WidgetDataHelper.getUnitLabel(context)
            views.setTextViewText(R.id.tv_goal, "/ ${WidgetDataHelper.formatVolumeShort(goalMl, context)} $unitLabel")
            
            // Localized button
            views.setTextViewText(R.id.btn_add_drink, WidgetDataHelper.getAddDrinkLabel(context))

            // Draw progress ring
            val progress = currentMl.toFloat() / goalMl.coerceAtLeast(1)
            val ringBitmap = WidgetDrawHelper.drawProgressRing(context, progress, 100)
            views.setImageViewBitmap(R.id.iv_progress_ring, ringBitmap)

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
