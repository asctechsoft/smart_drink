package com.amobi.drinkwater.drink_water.widget

import android.content.Context
import com.amobi.drinkwater.drink_water.PrefAssist
import com.amobi.drinkwater.drink_water.PrefConst
import com.amobi.drinkwater.drink_water.R
import org.json.JSONArray
import java.util.Locale

/**
 * Helper to read widget data from SharedPreferences (written by Flutter).
 */
object WidgetDataHelper {

    data class RecentDrink(
        val name: String,
        val amount: String,
        val time: String,
        val type: String
    )

    fun getCurrentMl(context: Context): Int {
        return PrefAssist.getInt(context, PrefConst.ONGOING_CURRENT_ML, 0)
    }

    fun getGoalMl(context: Context): Int {
        return PrefAssist.getInt(context, PrefConst.ONGOING_GOAL_ML, 2000)
    }

    fun getRemainingMl(context: Context): Int {
        val goal = getGoalMl(context)
        val current = getCurrentMl(context)
        return (goal - current).coerceAtLeast(0)
    }

    fun getProgressPercent(context: Context): Int {
        val goal = getGoalMl(context)
        if (goal <= 0) return 0
        val current = getCurrentMl(context)
        return ((current.toFloat() / goal) * 100).toInt().coerceAtLeast(0)
    }

    fun isExceeded(context: Context): Boolean {
        val current = getCurrentMl(context)
        val goal = getGoalMl(context)
        return current > goal
    }

    /** Maximum ml the widget will accept (matches in-app limit). */
    const val MAX_INTAKE_ML = 8000

    fun getNextReminderTime(context: Context): String {
        return PrefAssist.getString(context, WIDGET_NEXT_REMINDER, "")
    }

    fun getRecentDrinks(context: Context): List<RecentDrink> {
        val json = PrefAssist.getString(context, PrefConst.WIDGET_RECENT_DRINKS, "")
        if (json.isEmpty()) return emptyList()
        return try {
            val array = JSONArray(json)
            val result = mutableListOf<RecentDrink>()
            for (i in 0 until array.length()) {
                val obj = array.getJSONObject(i)
                result.add(
                    RecentDrink(
                        name = obj.optString("name", ""),
                        amount = obj.optString("amount", ""),
                        time = obj.optString("time", ""),
                        type = obj.optString("type", "water")
                    )
                )
            }
            result
        } catch (_: Exception) {
            emptyList()
        }
    }

    fun getVolumeUnit(context: Context): String {
        return PrefAssist.getString(context, PrefConst.WIDGET_VOLUME_UNIT, "ml")
    }

    fun formatVolume(ml: Int, context: Context): String {
        val unit = getVolumeUnit(context)
        return if (unit == "oz") {
            val oz = ml * 0.033814
            val ozFormatted = String.format(Locale.US, "%.2f", oz).replace(Regex("\\.?0+$"), "")
            "$ozFormatted oz"
        } else {
            "$ml ml"
        }
    }

    fun formatVolumeShort(ml: Int, context: Context): String {
        val unit = getVolumeUnit(context)
        return if (unit == "oz") {
            val oz = ml * 0.033814
            String.format(Locale.US, "%.2f", oz).replace(Regex("\\.?0+$"), "")
        } else {
            "$ml"
        }
    }

    fun getUnitLabel(context: Context): String {
        return if (getVolumeUnit(context) == "oz") "oz" else "ml"
    }

    fun isGoalReached(context: Context): Boolean {
        val current = getCurrentMl(context)
        val goal = getGoalMl(context)
        return current >= goal
    }

    fun getIconBgForType(type: String): Int {
        return when (type) {
            "milk" -> R.drawable.widget_icon_bg_milk
            "coffee" -> R.drawable.widget_icon_bg_coffee
            "tea" -> R.drawable.widget_icon_bg_tea
            "juice" -> R.drawable.widget_icon_bg_juice
            "soup" -> R.drawable.widget_icon_bg_soup
            "beer" -> R.drawable.widget_icon_bg_beer
            "wine" -> R.drawable.widget_icon_bg_wine
            else -> R.drawable.widget_icon_bg_water
        }
    }

    fun getIconForType(type: String): Int {
        return when (type) {
            "milk" -> R.drawable.img_cup_milk
            "coffee" -> R.drawable.img_coffce
            "tea" -> R.drawable.img_cup_tea
            "juice" -> R.drawable.img_juice
            "soup" -> R.drawable.img_soup
            "beer" -> R.drawable.img_beer
            "wine" -> R.drawable.img_wine
            "strong_drinks" -> R.drawable.img_strong
            else -> R.drawable.img_cup_water
        }
    }

    fun getTimeFormat(context: Context): String {
        return PrefAssist.getString(context, "flutter.time_format", "system")
    }

    fun formatTime(context: Context): String {
        val formatSetting = getTimeFormat(context)
        val now = java.util.Date()
        
        val is24h = when (formatSetting) {
            "24h" -> true
            "12h" -> false
            else -> android.text.format.DateFormat.is24HourFormat(context)
        }

        val pattern = if (is24h) "HH:mm" else "hh:mm a"
        return java.text.SimpleDateFormat(pattern, java.util.Locale.US).format(now)
    }

    fun getLabel(context: Context, key: String, defaultValue: String): String {
        return PrefAssist.getString(context, "flutter.widget_label_$key", defaultValue)
    }

    // Specific label helpers
    fun getAddDrinkLabel(context: Context) = getLabel(context, "add_drink", context.getString(R.string.add_drink))
    fun getTodaysIntakeLabel(context: Context) = getLabel(context, "today_s_intake", context.getString(R.string.today_s_intake))
    fun getExceededGoalLabel(context: Context) = getLabel(context, "exceeded_your_goal", "Exceeded your goal")
    fun getGoalCompletedLabel(context: Context) = getLabel(context, "goal_completed", "Goal completed!")
    fun getNoRecordsTodayLabel(context: Context) = getLabel(context, "no_records_today", context.getString(R.string.no_records_today))
    fun getNoReminderSetLabel(context: Context) = getLabel(context, "no_reminder_set", context.getString(R.string.no_reminder_set))
    fun getHoursLabel(context: Context) = getLabel(context, "hours", context.getString(R.string.hours))
    fun getMinutesLabel(context: Context) = getLabel(context, "minutes", context.getString(R.string.minutes))
    fun getSecondsLabel(context: Context) = getLabel(context, "seconds", context.getString(R.string.seconds))
    fun getCustomLabel(context: Context) = getLabel(context, "custom", context.getString(R.string.custom))

    fun getRemainingLabel(context: Context, remainingAmount: String): String {
        val base = getLabel(context, "remaining", "Remaining %1\$s")
        return try {
            base.replace("%1\$s", remainingAmount).replace("@args1", remainingAmount)
        } catch (_: Exception) {
            "Remaining $remainingAmount"
        }
    }

    fun getNextReminderLabel(context: Context, time: String): String {
        val base = getLabel(context, "next_reminder", "Next reminder %1\$s")
        return try {
            base.replace("%1\$s", time).replace("@args1", time)
        } catch (_: Exception) {
            "Next reminder $time"
        }
    }

    // Widget-specific preference keys
    const val WIDGET_NEXT_REMINDER = "flutter.widget_next_reminder_time"
}
