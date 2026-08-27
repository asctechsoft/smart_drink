package com.amobi.drinkwater.water_nudge.notification

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
import com.amobi.drinkwater.water_nudge.Const
import com.amobi.drinkwater.water_nudge.MainActivity
import com.amobi.drinkwater.water_nudge.PrefAssist
import com.amobi.drinkwater.water_nudge.PrefConst
import com.amobi.drinkwater.water_nudge.R
import com.amobi.drinkwater.water_nudge.widget.WidgetDrawHelper
import java.util.Calendar

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

        val currentMl = PrefAssist.getInt(context, PrefConst.ONGOING_CURRENT_ML, 0)
        val goalMl = PrefAssist.getInt(context, PrefConst.ONGOING_GOAL_ML, 2000)
        val percent = if (goalMl > 0) (currentMl * 100 / goalMl) else 0

        val unit = PrefAssist.getString(context, PrefConst.WIDGET_VOLUME_UNIT, "ml")
        val currentDisplay = if (unit == "oz") "${(currentMl * 0.033814).toInt()}" else "$currentMl"
        val goalDisplay = if (unit == "oz") "${(goalMl * 0.033814).toInt()}" else "$goalMl"
        val unitLabel = if (unit == "oz") localizedContext.getString(R.string.oz) else localizedContext.getString(R.string.ml)

        val remainingMl = (goalMl - currentMl).coerceAtLeast(0)
        val remainingDisplay = if (unit == "oz") "${(remainingMl * 0.033814).toInt()}" else "$remainingMl"
        val remainingText =
            localizedContext.getString(R.string.noti_remaining_today, remainingDisplay, unitLabel)
        val goalText = "/ $goalDisplay $unitLabel"

        // Content intent — open app (lands on the Today/home screen).
        val contentIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val contentPending = PendingIntent.getActivity(
            context, 0, contentIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Small RemoteViews (collapsed)
        val smallView = RemoteViews(context.packageName, R.layout.noti_ongoing_small).apply {
            setTextViewText(R.id.tv_amount, currentDisplay)
            setTextViewText(R.id.tv_goal, goalText)
            setTextViewText(R.id.tv_remaining, remainingText)
            setTextViewText(R.id.tv_btn_drink_small, localizedContext.getString(R.string.noti_drink))
            // Tapping "Drink" opens the app on the Today screen.
            setOnClickPendingIntent(R.id.btn_drink_small, contentPending)
        }

        // Progress bar drawn as a bitmap so we can add the bright head dot.
        // Drawn at full screen width; the ImageView uses scaleType=fitCenter, which
        // scales uniformly (never stretches), so the head dot stays a true circle
        // regardless of the view's actual width.
        val dm = context.resources.displayMetrics
        val progressBitmap = WidgetDrawHelper.drawLinearProgress(
            context, percent.coerceIn(0, 100) / 100f, dm.widthPixels
        )

        // Large RemoteViews (expanded)
        val largeView = RemoteViews(context.packageName, R.layout.noti_ongoing_large).apply {
            setTextViewText(R.id.tv_amount, currentDisplay)
            setTextViewText(R.id.tv_goal, goalText)
            setTextViewText(R.id.tv_remaining, remainingText)
            setImageViewBitmap(R.id.iv_progress, progressBitmap)
            setTextViewText(R.id.tv_percent, "${percent.coerceIn(0, 100)}%")
            setTextViewText(R.id.tv_btn_drink, localizedContext.getString(R.string.noti_drink))
            // Tapping "Drink" opens the app on the Today screen.
            setOnClickPendingIntent(R.id.btn_drink, contentPending)
        }

        return NotificationCompat.Builder(context, Const.ONGOING_CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_logo)
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
