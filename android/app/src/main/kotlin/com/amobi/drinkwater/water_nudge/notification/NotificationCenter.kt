package com.amobi.drinkwater.drink_water.notification

import android.Manifest
import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import android.widget.RemoteViews
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.amobi.drinkwater.drink_water.Const
import com.amobi.drinkwater.drink_water.MainActivity
import com.amobi.drinkwater.drink_water.PrefAssist
import com.amobi.drinkwater.drink_water.PrefConst
import com.amobi.drinkwater.drink_water.R
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale

object NotificationCenter {
    private const val TIMER_BETWEEN_UPDATE = 300
    private var lastValidUpdateTime = 0L

    private fun isAllowUpdate(customTime: Int = TIMER_BETWEEN_UPDATE): Boolean =
        if (System.currentTimeMillis() - lastValidUpdateTime > customTime) {
            lastValidUpdateTime = System.currentTimeMillis()
            true
        } else {
            false
        }

    // --- Notification Channels ---

    fun createNotificationChannels(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        val localizedContext = PrefAssist.getLocalizedContext(context)

        // Ongoing channel - low importance, silent
        val ongoingChannel = NotificationChannel(
            Const.ONGOING_CHANNEL_ID,
            localizedContext.getString(R.string.water_tracking),
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = localizedContext.getString(R.string.ongoing_desc)
            setSound(null, null)
            enableVibration(false)
        }
        notificationManager.createNotificationChannel(ongoingChannel)

        // Delete old daily channels to ensure updated settings are applied
        // (Android ignores vibration/sound changes on existing channels)
        notificationManager.deleteNotificationChannel(Const.DAILY_CHANNEL_ID)
        notificationManager.deleteNotificationChannel(Const.DAILY_CHANNEL_SILENT_ID)

        // Daily channel - high importance, with vibration
        val soundUri = Uri.parse(
            "android.resource://${context.packageName}/${R.raw.one_second_of_silent}"
        )
        val audioAttrs = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_NOTIFICATION)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()

        val dailyChannel = NotificationChannel(
            Const.DAILY_CHANNEL_ID,
            "Drink Reminders",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Daily water drink reminders"
            setSound(soundUri, audioAttrs)
            enableVibration(true)
            vibrationPattern = longArrayOf(0, 300, 200, 300)
        }
        notificationManager.createNotificationChannel(dailyChannel)

        // Daily channel (silent) - high importance, no vibration
        val dailySilentChannel = NotificationChannel(
            Const.DAILY_CHANNEL_SILENT_ID,
            "Drink Reminders (Silent)",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Daily water drink reminders without vibration"
            setSound(soundUri, audioAttrs)
            enableVibration(false)
        }
        notificationManager.createNotificationChannel(dailySilentChannel)
    }

    // Dynamic Channel for Custom Sounds
    fun getDailyChannelId(context: Context, soundEffectName: String, vibrateEnabled: Boolean): String {
        val localizedContext = PrefAssist.getLocalizedContext(context)
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return if (vibrateEnabled) Const.DAILY_CHANNEL_ID else Const.DAILY_CHANNEL_SILENT_ID
        }

        val channelId = "Daily_${soundEffectName}_vibrate_${vibrateEnabled}"
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        
        if (notificationManager.getNotificationChannel(channelId) == null) {
            val soundResId = context.resources.getIdentifier(soundEffectName, "raw", context.packageName)
            
            // If the sound isn't found, fallback to system default sound
            val soundUri = if (soundResId != 0) {
                Uri.parse("android.resource://${context.packageName}/$soundResId")
            } else {
                android.media.RingtoneManager.getDefaultUri(android.media.RingtoneManager.TYPE_NOTIFICATION)
            }

            val audioAttrs = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()

            val channel = NotificationChannel(
                channelId,
                localizedContext.getString(R.string.drink_reminders),
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = localizedContext.getString(R.string.daily_desc)
                setSound(soundUri, audioAttrs)
                enableVibration(vibrateEnabled)
                if (vibrateEnabled) {
                    vibrationPattern = longArrayOf(0, 300, 200, 300)
                }
            }
            notificationManager.createNotificationChannel(channel)
        }
        return channelId
    }

    // --- Ongoing Notification (Foreground Service) ---

    fun startOngoingNotification(context: Context) {
        if (!isAllowUpdate()) return
        WaterTrackingService.start(context)
        // Schedule periodic health-check to re-show notification if dismissed
        OngoingHealthCheckReceiver.schedule(context)
    }

    fun stopOngoingNotification(context: Context) {
        WaterTrackingService.stop(context)
        // Cancel health-check since ongoing notification is intentionally stopped
        OngoingHealthCheckReceiver.cancel(context)
    }

    fun updateOngoingDisplay(context: Context) {
        WaterTrackingService.updateOngoing(context)
    }

    fun buildOngoingNotification(context: Context): Notification {
        val localizedContext = PrefAssist.getLocalizedContext(context)
        val appLocale = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            localizedContext.resources.configuration.locales[0]
        } else {
            @Suppress("DEPRECATION")
            localizedContext.resources.configuration.locale
        }

        val currentMl = PrefAssist.getInt(context, PrefConst.ONGOING_CURRENT_ML, 0)
        val goalMl = PrefAssist.getInt(context, PrefConst.ONGOING_GOAL_ML, 2000)
        val percent = if (goalMl > 0) (currentMl * 100 / goalMl) else 0
        val timeText = SimpleDateFormat("hh:mm a", appLocale)
            .format(Calendar.getInstance().time)

        val unit = PrefAssist.getString(context, PrefConst.WIDGET_VOLUME_UNIT, "ml")
        val currentDisplay = if (unit == "oz") "${(currentMl * 0.033814).toInt()}" else "$currentMl"
        val goalDisplay = if (unit == "oz") "${(goalMl * 0.033814).toInt()}" else "$goalMl"
        val unitLabel = if (unit == "oz") localizedContext.getString(R.string.oz) else localizedContext.getString(R.string.ml)

        // Small RemoteViews (collapsed)
        val smallView = RemoteViews(context.packageName, R.layout.noti_ongoing_small).apply {
            setTextViewText(R.id.tv_title, localizedContext.getString(R.string.time_to_drink_water))
            setTextViewText(R.id.tv_btn_add_water_small, localizedContext.getString(R.string.add_drink))

            // Add Drink button on collapsed view
            val addSmallIntent = Intent(context, NotificationClickHandler::class.java).apply {
                action = NotificationClickHandler.ACTION_ADD_WATER
            }
            val addSmallPending = PendingIntent.getBroadcast(
                context, 2, addSmallIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            setOnClickPendingIntent(R.id.btn_add_water_small, addSmallPending)
        }

        // Large RemoteViews (expanded dark card)
        val largeView = RemoteViews(context.packageName, R.layout.noti_ongoing_large).apply {
            setTextViewText(R.id.tv_time, timeText)
            setTextViewText(R.id.tv_heading, localizedContext.getString(R.string.its_time_to_drink))
            setTextViewText(R.id.tv_sub_heading, localizedContext.getString(R.string.some_water))
            setTextViewText(R.id.tv_btn_add_water, localizedContext.getString(R.string.add_drink))
            setProgressBar(R.id.pb_progress, 100, percent.coerceIn(0, 100), false)
            setTextViewText(R.id.tv_progress_text, "$currentDisplay / $goalDisplay $unitLabel")

            // Add Drink button
            val addIntent = Intent(context, NotificationClickHandler::class.java).apply {
                action = NotificationClickHandler.ACTION_ADD_WATER
            }
            val addPending = PendingIntent.getBroadcast(
                context, 1, addIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            setOnClickPendingIntent(R.id.btn_add_water, addPending)
        }

        // Content intent - open app
        val contentIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val contentPending = PendingIntent.getActivity(
            context, 0, contentIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(context, Const.ONGOING_CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_water_drop)
            .setCustomContentView(smallView)
            .setCustomBigContentView(largeView)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setOngoing(true)
            .setSilent(true)
            .setContentIntent(contentPending)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    // --- Daily Reminder Alarms ---

    fun scheduleDailyNotification(context: Context) {
        scheduleDynamicAlarms(context)
    }

    fun cancelDailyNotification(context: Context) {
        cancelAllDynamicAlarms(context)
        NotificationManagerCompat.from(context).cancel(Const.DAILY_NOTIFICATION_ID)
    }

    /**
     * Schedule N alarms from the JSON schedule list stored in SharedPreferences.
     * Each entry is {"hour": H, "minute": M}. Supports full minute precision.
     */
    fun scheduleDynamicAlarms(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val json = PrefAssist.getString(
            context, PrefConst.KEY_REMINDER_SCHEDULES_JSON, "[]"
        )

        val schedules = try {
            org.json.JSONArray(json)
        } catch (e: Exception) {
            org.json.JSONArray()
        }

        val count = schedules.length().coerceAtMost(Const.MAX_REMINDER_ALARMS)

        // Cancel all previous alarms first
        cancelAllDynamicAlarms(context)

        for (i in 0 until count) {
            val obj = schedules.optJSONObject(i) ?: continue
            val hour = obj.optInt("hour", 8)
            val minute = obj.optInt("minute", 0)
            val slotId = Const.DYNAMIC_ALARM_BASE_REQUEST_CODE + i

            val intent = Intent(context, ReminderAlarmReceiver::class.java).apply {
                putExtra(ReminderAlarmReceiver.EXTRA_SLOT_ID, slotId)
                putExtra(ReminderAlarmReceiver.EXTRA_HOUR, hour)
                putExtra(ReminderAlarmReceiver.EXTRA_MINUTE, minute)
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context, slotId, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val triggerTime = getNextTriggerTime(hour, minute)
            scheduleAlarm(alarmManager, triggerTime, pendingIntent)
        }

        PrefAssist.setInt(context, PrefConst.KEY_REMINDER_ALARM_COUNT, count)
    }

    /**
     * Cancel all dynamic alarms and legacy 3-slot alarms.
     */
    fun cancelAllDynamicAlarms(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        // Cancel dynamic alarms
        val oldCount = PrefAssist.getInt(context, PrefConst.KEY_REMINDER_ALARM_COUNT, 0)
        for (i in 0 until oldCount) {
            val slotId = Const.DYNAMIC_ALARM_BASE_REQUEST_CODE + i
            val intent = Intent(context, ReminderAlarmReceiver::class.java)
            val pi = PendingIntent.getBroadcast(
                context, slotId, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            alarmManager.cancel(pi)
        }

        // Cancel legacy 3-slot alarms for backward compat
        for (legacySlotId in listOf(
            Const.NOTIF_ID_MORNING, Const.NOTIF_ID_AFTERNOON, Const.NOTIF_ID_NIGHT
        )) {
            val intent = Intent(context, ReminderAlarmReceiver::class.java)
            val pi = PendingIntent.getBroadcast(
                context, 100 + legacySlotId, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            alarmManager.cancel(pi)
        }
    }

    private fun scheduleAlarm(
        alarmManager: AlarmManager,
        triggerTime: Long,
        pendingIntent: PendingIntent
    ) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (alarmManager.canScheduleExactAlarms()) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP, triggerTime, pendingIntent
                )
            } else {
                alarmManager.setAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP, triggerTime, pendingIntent
                )
            }
        } else {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP, triggerTime, pendingIntent
            )
        }
    }

    private fun getNextTriggerTime(hour: Int, minute: Int = 0): Long {
        val calendar = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, hour)
            set(Calendar.MINUTE, minute)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        // If the time has already passed today, schedule for tomorrow
        if (calendar.timeInMillis <= System.currentTimeMillis()) {
            calendar.add(Calendar.DAY_OF_YEAR, 1)
        }
        return calendar.timeInMillis
    }
}
