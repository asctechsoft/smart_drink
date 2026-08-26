package com.amobi.drinkwater.drink_water.notification

import android.app.ForegroundServiceStartNotAllowedException
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.ServiceCompat
import com.amobi.drinkwater.drink_water.Const
import com.amobi.drinkwater.drink_water.PrefAssist
import com.amobi.drinkwater.drink_water.PrefConst

class WaterTrackingService : Service() {

    companion object {
        private const val TAG = "WaterTrackingService"
        const val ACTION_START = "com.amobi.drinkwater.ACTION_START_SERVICE"
        const val ACTION_STOP = "com.amobi.drinkwater.ACTION_STOP_SERVICE"
        const val ACTION_UPDATE_ONGOING = "com.amobi.drinkwater.ACTION_UPDATE_ONGOING"

        fun start(context: Context) {
            val intent = Intent(context, WaterTrackingService::class.java).apply {
                action = ACTION_START
            }
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(intent)
                } else {
                    context.startService(intent)
                }
            } catch (e: Exception) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
                    e is ForegroundServiceStartNotAllowedException
                ) {
                    Log.w(TAG, "Cannot start foreground service from background", e)
                } else {
                    throw e
                }
            }
        }

        fun stop(context: Context) {
            val intent = Intent(context, WaterTrackingService::class.java).apply {
                action = ACTION_STOP
            }
            context.startService(intent)
        }

        fun updateOngoing(context: Context) {
            val intent = Intent(context, WaterTrackingService::class.java).apply {
                action = ACTION_UPDATE_ONGOING
            }
            try {
                context.startService(intent)
            } catch (_: Exception) {
                // Service not running
            }
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onTaskRemoved(rootIntent: Intent?) {
        super.onTaskRemoved(rootIntent)
        // When the user swipes the app from recents, re-post the notification
        // so it stays visible as long as the sticky setting is enabled.
        val isOngoing = PrefAssist.getBoolean(this, PrefConst.KEY_NOTIFICATION_ONGOING)
        if (isOngoing) {
            startForegroundWithNotification()
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                startForegroundWithNotification()
            }
            ACTION_STOP -> {
                ServiceCompat.stopForeground(this, ServiceCompat.STOP_FOREGROUND_REMOVE)
                stopSelf()
            }
            ACTION_UPDATE_ONGOING -> {
                updateForegroundNotification()
            }
            else -> {
                // Service restarted by system (START_STICKY) with null intent
                startForegroundWithNotification()
            }
        }
        return START_STICKY
    }

    private fun startForegroundWithNotification() {
        NotificationCenter.createNotificationChannels(this)
        val notification = NotificationCenter.buildOngoingNotification(this)
        try {
            ServiceCompat.startForeground(
                this,
                Const.ONGOING_NOTIFICATION_ID,
                notification,
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_HEALTH
                else 0
            )
        } catch (e: Exception) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
                e is ForegroundServiceStartNotAllowedException
            ) {
                Log.w(TAG, "Cannot promote to foreground from background", e)
                stopSelf()
            } else {
                throw e
            }
        }
    }

    private fun updateForegroundNotification() {
        val notification = NotificationCenter.buildOngoingNotification(this)
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.notify(Const.ONGOING_NOTIFICATION_ID, notification)
    }
}
