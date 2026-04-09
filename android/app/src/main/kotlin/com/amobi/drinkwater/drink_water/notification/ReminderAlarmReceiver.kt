package com.amobi.drinkwater.drink_water.notification

import android.Manifest
import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
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
import java.util.Calendar

class ReminderAlarmReceiver : BroadcastReceiver() {

    companion object {
        const val EXTRA_SLOT_ID = "slot_id"
        const val EXTRA_HOUR = "extra_hour"
        const val EXTRA_MINUTE = "extra_minute"
        private const val THROTTLE_KEY_PREFIX = "throttle_slot_"

        private val MOTIVATION_RES_IDS = listOf(
            R.string.motivation_1,
            R.string.motivation_2,
            R.string.motivation_3,
            R.string.motivation_4,
            R.string.motivation_5
        )

        /**
         * Show or update the daily reminder notification.
         *
         * @param playSound  true for initial show (with sound/vibration), false for silent updates
         * @param motivationOverride  custom motivation text; null picks a random one
         */
        fun showOrUpdateDailyNotification(
            context: Context,
            playSound: Boolean,
            motivationOverride: String?,
            soundEffectOverride: String? = null,
            titleOverride: String? = null,
            bodyOverride: String? = null
        ) {
            val currentMl = PrefAssist.getInt(context, PrefConst.ONGOING_CURRENT_ML, 0)
            val goalMl = PrefAssist.getInt(context, PrefConst.ONGOING_GOAL_ML, 2000)
            val percent = if (goalMl > 0) (currentMl * 100 / goalMl) else 0
            val localizedContext = PrefAssist.getLocalizedContext(context)
            val motivation = bodyOverride ?: (motivationOverride ?: localizedContext.getString(MOTIVATION_RES_IDS.random()))
            val titleText = titleOverride ?: localizedContext.getString(R.string.time_to_drink_water)

            val unit = PrefAssist.getString(context, PrefConst.WIDGET_VOLUME_UNIT, "ml")
            val currentDisplay =
                if (unit == "oz") "${Math.round(currentMl * 0.033814)}" else "$currentMl"
            val goalDisplay =
                if (unit == "oz") "${Math.round(goalMl * 0.033814)}" else "$goalMl"
            val unitLabel = if (unit == "oz") localizedContext.getString(R.string.oz) else localizedContext.getString(R.string.ml)

            // Small RemoteViews
            val smallView =
                RemoteViews(context.packageName, R.layout.noti_daily_small).apply {
                    setTextViewText(R.id.tv_title, titleText)
                    setTextViewText(
                        R.id.tv_progress,
                        "$currentDisplay/$goalDisplay $unitLabel"
                    )
                }

            // Add Water PendingIntent (broadcast → NotificationClickHandler)
            val addIntent =
                Intent(context, NotificationClickHandler::class.java).apply {
                    action = NotificationClickHandler.ACTION_ADD_WATER
                }
            val addPending = PendingIntent.getBroadcast(
                context, 10, addIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
            )

            // Large RemoteViews
            val largeView =
                RemoteViews(context.packageName, R.layout.noti_daily_large).apply {
                    setTextViewText(R.id.tv_title, titleText)
                    setTextViewText(R.id.tv_motivation, motivation)
                }

            // Content intent
            val contentIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val contentPending = PendingIntent.getActivity(
                context, 3, contentIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val channelId: String
            val builder: NotificationCompat.Builder

            val soundEffectName = soundEffectOverride ?: PrefAssist.getString(context, "flutter.sound_effect", "universfield_notification")

            if (playSound) {
                val soundResId = context.resources.getIdentifier(soundEffectName, "raw", context.packageName)
                val soundUri = if (soundResId != 0) {
                    Uri.parse("android.resource://${context.packageName}/$soundResId")
                } else {
                    android.media.RingtoneManager.getDefaultUri(android.media.RingtoneManager.TYPE_NOTIFICATION)
                }

                val vibrateEnabled = PrefAssist.getBoolean(context, PrefConst.KEY_VIBRATE_ENABLED, true)
                channelId = NotificationCenter.getDailyChannelId(context, soundEffectName, vibrateEnabled)

                builder = NotificationCompat.Builder(context, channelId)
                    .setSound(soundUri)
                    .setPriority(NotificationCompat.PRIORITY_HIGH)
            } else {
                // Silent update — use low-importance ongoing channel to avoid re-alerting
                channelId = NotificationCenter.getDailyChannelId(context, soundEffectName, false)
                builder = NotificationCompat.Builder(context, channelId)
                    .setSilent(true)
                    .setPriority(NotificationCompat.PRIORITY_LOW)
                    .setOnlyAlertOnce(true)
            }

            builder
                .setSmallIcon(R.drawable.ic_water_drop)
                .setCustomContentView(smallView)
                .setCustomBigContentView(largeView)
                .setStyle(NotificationCompat.DecoratedCustomViewStyle())
                .setAutoCancel(false)
                .setContentIntent(contentPending)

            // Full-screen intent only on first show
            if (playSound) {
                val isFullScreen = PrefAssist.getBoolean(
                    context, PrefConst.IS_FULL_SCREEN_INTENT_ENABLED, true
                )
                if (isFullScreen) {
                    val fullScreenIntent =
                        Intent(context, DailyFullScreenActivity::class.java).apply {
                            flags =
                                Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                        }
                    val fullScreenPending = PendingIntent.getActivity(
                        context, 4, fullScreenIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    builder.setFullScreenIntent(fullScreenPending, true)
                }
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                if (ActivityCompat.checkSelfPermission(
                        context, Manifest.permission.POST_NOTIFICATIONS
                    ) != PackageManager.PERMISSION_GRANTED
                ) return
            }

            // Record dedup timestamp so FCM won't double-show
            if (playSound) {
                PrefAssist.setLong(
                    context, PrefConst.LAST_DAILY_NOTI_SHOWN_TIME,
                    System.currentTimeMillis()
                )
            }

            NotificationManagerCompat.from(context)
                .notify(Const.DAILY_NOTIFICATION_ID, builder.build())
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        val slotId = intent.getIntExtra(EXTRA_SLOT_ID, -1)
        val hour = intent.getIntExtra(EXTRA_HOUR, -1)
        val minute = intent.getIntExtra(EXTRA_MINUTE, 0)
        if (slotId == -1 || hour == -1) return

        // Per-slot throttle: 23h50m to prevent double-fire without suppressing next-day
        val throttleKey = "${THROTTLE_KEY_PREFIX}${hour}_${minute}"
        val lastCalled = PrefAssist.getLong(context, throttleKey, 0L)
        if (System.currentTimeMillis() - lastCalled < Const.MILLIS_THROTTLE) {
            rescheduleThisAlarm(context, slotId, hour, minute)
            return
        }

        // Dedup: skip if a notification was already shown recently (by FCM or another alarm)
        val lastShown = PrefAssist.getLong(context, PrefConst.LAST_DAILY_NOTI_SHOWN_TIME, 0L)
        if (System.currentTimeMillis() - lastShown < Const.DAILY_NOTI_DEDUP_WINDOW) {
            rescheduleThisAlarm(context, slotId, hour, minute)
            return
        }

        PrefAssist.setLong(context, throttleKey, System.currentTimeMillis())
        showOrUpdateDailyNotification(context, playSound = true, motivationOverride = null)

        // Re-schedule only this alarm for next day
        rescheduleThisAlarm(context, slotId, hour, minute)
    }

    private fun rescheduleThisAlarm(context: Context, slotId: Int, hour: Int, minute: Int) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val calendar = Calendar.getInstance().apply {
            add(Calendar.DAY_OF_YEAR, 1)
            set(Calendar.HOUR_OF_DAY, hour)
            set(Calendar.MINUTE, minute)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }

        val alarmIntent = Intent(context, ReminderAlarmReceiver::class.java).apply {
            putExtra(EXTRA_SLOT_ID, slotId)
            putExtra(EXTRA_HOUR, hour)
            putExtra(EXTRA_MINUTE, minute)
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context, slotId, alarmIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (alarmManager.canScheduleExactAlarms()) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP, calendar.timeInMillis, pendingIntent
                )
            } else {
                alarmManager.setAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP, calendar.timeInMillis, pendingIntent
                )
            }
        } else {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP, calendar.timeInMillis, pendingIntent
            )
        }
    }
}
