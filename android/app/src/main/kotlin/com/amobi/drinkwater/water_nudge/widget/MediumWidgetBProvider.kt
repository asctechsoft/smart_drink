package com.amobi.drinkwater.drink_water.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews
import com.amobi.drinkwater.drink_water.MainActivity
import com.amobi.drinkwater.drink_water.PrefAssist
import com.amobi.drinkwater.drink_water.PrefConst
import com.amobi.drinkwater.drink_water.R

class MediumWidgetBProvider : AppWidgetProvider() {

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
        private val QUICK_ADD_AMOUNTS = listOf(150, 200, 300, 500, 700)

        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            widgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.widget_medium_b)

            val currentMl = WidgetDataHelper.getCurrentMl(context)
            val goalMl = WidgetDataHelper.getGoalMl(context)
            val percent = WidgetDataHelper.getProgressPercent(context)

            views.setTextViewText(R.id.tv_percentage, "$percent%")
            views.setTextViewText(R.id.tv_current_ml, WidgetDataHelper.formatVolume(currentMl, context))
            views.setTextViewText(R.id.tv_goal_ml, " / ${WidgetDataHelper.formatVolume(goalMl, context)}")
            views.setTextViewText(R.id.tv_label_today_intake, WidgetDataHelper.getTodaysIntakeLabel(context))

            // Draw progress circle
            val progress = currentMl.toFloat() / goalMl.coerceAtLeast(1)
            val ringBitmap = WidgetDrawHelper.drawCircleProgress(context, progress, 65, 6f)
            views.setImageViewBitmap(R.id.iv_progress_ring_percentage, ringBitmap)

            // Show goal status text
            val isExceeded = WidgetDataHelper.isExceeded(context)
            val isGoalReached = WidgetDataHelper.isGoalReached(context)
            if (isExceeded) {
                views.setViewVisibility(R.id.tv_status, View.VISIBLE)
                views.setTextViewText(R.id.tv_status, WidgetDataHelper.getExceededGoalLabel(context))
            } else if (isGoalReached) {
                views.setViewVisibility(R.id.tv_status, View.VISIBLE)
                views.setTextViewText(R.id.tv_status, WidgetDataHelper.getGoalCompletedLabel(context))
            } else {
                views.setViewVisibility(R.id.tv_status, View.GONE)
            }

            // Quick-add button pending intents
            val maxReached = currentMl >= WidgetDataHelper.MAX_INTAKE_ML
            val quickAddButtons = mapOf(
                R.id.btn_150 to 150,
                R.id.btn_200 to 200,
                R.id.btn_300 to 300,
                R.id.btn_500 to 500,
                R.id.btn_700 to 700,
            )

            // Update button labels to reflect the user's volume unit
            for ((btnId, amount) in quickAddButtons) {
                views.setTextViewText(btnId, WidgetDataHelper.formatVolume(amount, context))
            }

            for ((btnId, amount) in quickAddButtons) {
                if (maxReached) {
                    views.setInt(btnId, "setBackgroundResource", R.drawable.widget_quick_add_bg_disabled)
                    views.setTextColor(btnId, context.getColor(R.color.widget_text_disabled))
                    views.setFloat(btnId, "setAlpha", 0.5f) // Corrected for RemoteViews
                } else {
                    views.setInt(btnId, "setBackgroundResource", R.drawable.widget_quick_add_bg)
                    views.setTextColor(btnId, context.getColor(R.color.clr_white))
                    views.setFloat(btnId, "setAlpha", 1.0f) // Restore full opacity
                    val intent = Intent(context, WidgetActionReceiver::class.java).apply {
                        action = WidgetActionReceiver.ACTION_QUICK_ADD
                        putExtra(WidgetActionReceiver.EXTRA_AMOUNT, amount)
                    }
                    val pi = PendingIntent.getBroadcast(
                        context, btnId, intent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    views.setOnClickPendingIntent(btnId, pi)
                }
            }

            // Style the Custom button consistently
            views.setTextViewText(R.id.btn_custom, WidgetDataHelper.getCustomLabel(context))
            if (maxReached) {
                views.setInt(R.id.btn_custom, "setBackgroundResource", R.drawable.widget_quick_add_bg_disabled)
                views.setTextColor(R.id.btn_custom, context.getColor(R.color.widget_text_disabled))
                views.setFloat(R.id.btn_custom, "setAlpha", 0.5f)
            } else {
                views.setInt(R.id.btn_custom, "setBackgroundResource", R.drawable.widget_quick_add_bg)
                views.setTextColor(R.id.btn_custom, context.getColor(R.color.clr_white))
                views.setFloat(R.id.btn_custom, "setAlpha", 1.0f)
            }

            // Open app on tap (root catches taps on non-button areas)
            val openIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val openPi = PendingIntent.getActivity(
                context, widgetId, openIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, openPi)
            views.setOnClickPendingIntent(R.id.btn_custom, openPi)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
