package com.amobi.drinkwater.drink_water.notification

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import androidx.core.app.NotificationManagerCompat
import com.amobi.drinkwater.drink_water.Const
import com.amobi.drinkwater.drink_water.MainActivity
import com.amobi.drinkwater.drink_water.PrefAssist
import com.amobi.drinkwater.drink_water.PrefConst
import com.amobi.drinkwater.drink_water.widget.WidgetActionReceiver
import com.amobi.drinkwater.drink_water.widget.WidgetDataHelper
import com.amobi.drinkwater.drink_water.widget.WidgetUpdateHelper

class NotificationClickHandler : BroadcastReceiver() {

    companion object {
        const val ACTION_CLOSE_ONGOING = "com.amobi.drinkwater.ACTION_CLOSE_ONGOING"
        const val ACTION_ADD_WATER = "com.amobi.drinkwater.ACTION_ADD_WATER"
        const val ACTION_REFRESH = "com.amobi.drinkwater.ACTION_REFRESH"
        const val ACTION_OPEN_APP = "com.amobi.drinkwater.ACTION_OPEN_APP"

        private const val DEFAULT_ADD_AMOUNT = 250
    }

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            ACTION_CLOSE_ONGOING -> {
                NotificationCenter.stopOngoingNotification(context)
            }

            ACTION_ADD_WATER -> {
                // Check if goal already reached (8000 ml global limit)
                val currentMl = PrefAssist.getInt(context, PrefConst.ONGOING_CURRENT_ML, 0)
                if (currentMl >= WidgetDataHelper.MAX_INTAKE_ML) return

                // Cap the amount to add so total doesn't exceed 8000 ml
                val amountToAdd = DEFAULT_ADD_AMOUNT.coerceAtMost(WidgetDataHelper.MAX_INTAKE_ML - currentMl)
                if (amountToAdd <= 0) return

                // Accumulate pending add-water (handles multiple taps before app resumes)
                val existingPending = if (PrefAssist.getBoolean(context, PrefConst.PENDING_ADD_WATER)) {
                    PrefAssist.getInt(context, PrefConst.PENDING_ADD_WATER_AMOUNT, 0)
                } else {
                    0
                }
                PrefAssist.setBoolean(context, PrefConst.PENDING_ADD_WATER, true)
                PrefAssist.setInt(
                    context, PrefConst.PENDING_ADD_WATER_AMOUNT, existingPending + amountToAdd
                )

                // Track individual drinks for separate history records
                try {
                    val jsonStr = PrefAssist.getString(context, PrefConst.PENDING_ADD_WATER_JSON, "[]")
                    val array = if (jsonStr.isEmpty() || jsonStr == "[]") {
                        org.json.JSONArray()
                    } else {
                        try {
                            org.json.JSONArray(jsonStr)
                        } catch (_: Exception) {
                            org.json.JSONArray()
                        }
                    }

                    val drinkObj = org.json.JSONObject().apply {
                        put("amount", amountToAdd)
                        put("type", "water")
                        put("timestamp", System.currentTimeMillis())
                    }
                    array.put(drinkObj)
                    PrefAssist.setString(context, PrefConst.PENDING_ADD_WATER_JSON, array.toString())
                } catch (_: Exception) { }

                // Update the ongoing notification data immediately
                PrefAssist.setInt(
                    context, PrefConst.ONGOING_CURRENT_ML, currentMl + amountToAdd
                )

                // Update widget recent drinks list
                WidgetActionReceiver.prependRecentDrink(
                    context, "Water", "$amountToAdd ml", "water"
                )

                // Refresh ongoing notification display
                Handler(Looper.getMainLooper()).postDelayed({
                    NotificationCenter.updateOngoingDisplay(context)
                }, 500L)

                // Refresh daily notification to show updated progress
                val unit = PrefAssist.getString(context, PrefConst.WIDGET_VOLUME_UNIT, "ml")
                val addedDisplay = if (unit == "oz") "${(DEFAULT_ADD_AMOUNT * 0.033814).toInt()} oz" else "$DEFAULT_ADD_AMOUNT ml"
                ReminderAlarmReceiver.showOrUpdateDailyNotification(
                    context,
                    playSound = false,
                    motivationOverride = "✅ Added $addedDisplay!"
                )

                // Refresh home screen widgets too
                WidgetUpdateHelper.refreshAllWidgets(context)
            }

            ACTION_REFRESH -> {
                Handler(Looper.getMainLooper()).postDelayed({
                    NotificationCenter.updateOngoingDisplay(context)
                }, (500..1500).random().toLong())
            }

            ACTION_OPEN_APP -> {
                val launchIntent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                context.startActivity(launchIntent)
                // Dismiss the daily notification when user opens the app
                NotificationManagerCompat.from(context).cancel(Const.DAILY_NOTIFICATION_ID)
            }
        }
    }
}
