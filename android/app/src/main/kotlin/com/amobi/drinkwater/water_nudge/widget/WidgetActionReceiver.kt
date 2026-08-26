package com.amobi.drinkwater.drink_water.widget

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.amobi.drinkwater.drink_water.PrefAssist
import com.amobi.drinkwater.drink_water.PrefConst
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Handles quick-add actions from widget buttons.
 * Writes the pending add-water amount to SharedPreferences,
 * then Flutter reads it on next resume via checkPendingAddWater.
 */
class WidgetActionReceiver : BroadcastReceiver() {

    companion object {
        const val ACTION_QUICK_ADD = "com.amobi.drinkwater.WIDGET_QUICK_ADD"
        const val EXTRA_AMOUNT = "extra_amount"

        /**
         * Prepend a new drink to the WIDGET_RECENT_DRINKS JSON, keeping max 2 entries.
         * Reusable from NotificationClickHandler as well.
         */
        fun prependRecentDrink(context: Context, name: String, amount: String, type: String) {
            val timeStr = WidgetDataHelper.formatTime(context)
            val newObj = JSONObject().apply {
                put("name", name)
                put("amount", amount)
                put("time", timeStr)
                put("type", type)
            }

            val existingJson = PrefAssist.getString(context, PrefConst.WIDGET_RECENT_DRINKS, "")
            val newArray = JSONArray()
            newArray.put(newObj)

            // Keep the first entry from the old list (so we have max 2)
            if (existingJson.isNotEmpty()) {
                try {
                    val oldArray = JSONArray(existingJson)
                    if (oldArray.length() > 0) {
                        newArray.put(oldArray.getJSONObject(0))
                    }
                } catch (_: Exception) { }
            }

            PrefAssist.setString(context, PrefConst.WIDGET_RECENT_DRINKS, newArray.toString())
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION_QUICK_ADD) return

        val amount = intent.getIntExtra(EXTRA_AMOUNT, 150)

        // Check if max intake reached (8000 ml)
        val currentMl = PrefAssist.getInt(context, PrefConst.ONGOING_CURRENT_ML, 0)
        if (currentMl >= WidgetDataHelper.MAX_INTAKE_ML) {
            return
        }

        // Cap the amount to add so the total doesn't exceed MAX_INTAKE_ML
        val amountToAdd = amount.coerceAtMost(WidgetDataHelper.MAX_INTAKE_ML - currentMl)
        if (amountToAdd <= 0) return

        // Accumulate pending add-water for Flutter to pick up
        val existingPending = if (PrefAssist.getBoolean(context, PrefConst.PENDING_ADD_WATER)) {
            PrefAssist.getInt(context, PrefConst.PENDING_ADD_WATER_AMOUNT, 0)
        } else {
            0
        }
        PrefAssist.setBoolean(context, PrefConst.PENDING_ADD_WATER, true)
        PrefAssist.setInt(context, PrefConst.PENDING_ADD_WATER_AMOUNT, existingPending + amountToAdd)

        // Also track individual drink amounts in a JSON array for separate history records
        try {
            val jsonStr = PrefAssist.getString(context, PrefConst.PENDING_ADD_WATER_JSON, "[]")
            val array = if (jsonStr.isEmpty() || jsonStr == "[]") {
                JSONArray()
            } else {
                try {
                    JSONArray(jsonStr)
                } catch (_: Exception) {
                    JSONArray()
                }
            }
            
            val drinkObj = JSONObject().apply {
                put("amount", amountToAdd)
                put("type", "water")
                put("timestamp", System.currentTimeMillis())
            }
            array.put(drinkObj)
            PrefAssist.setString(context, PrefConst.PENDING_ADD_WATER_JSON, array.toString())
        } catch (_: Exception) {
            // Last resort: if JSON fails, ensure Flutter at least gets the flag + sum
        }

        // Also update current amount immediately for responsive widget UI
        PrefAssist.setInt(context, PrefConst.ONGOING_CURRENT_ML, currentMl + amountToAdd)

        // Prepend new drink entry to WIDGET_RECENT_DRINKS
        val displayAmount = WidgetDataHelper.formatVolume(amountToAdd, context)
        prependRecentDrink(context, "Water", displayAmount, "water")

        // Refresh all widget types
        WidgetUpdateHelper.refreshAllWidgets(context)
    }
}
