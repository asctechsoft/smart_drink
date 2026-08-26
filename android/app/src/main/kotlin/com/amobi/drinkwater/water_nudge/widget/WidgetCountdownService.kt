package com.amobi.drinkwater.drink_water.widget

import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Handler
import android.os.IBinder
import android.os.Looper

/**
 * A background service that updates widgets every second for the countdown timer.
 * Only active when the screen is on to save battery.
 */
class WidgetCountdownService : Service() {

    private val handler = Handler(Looper.getMainLooper())
    private var isScreenOn = true

    private val screenReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                Intent.ACTION_SCREEN_ON -> {
                    isScreenOn = true
                    startUpdating()
                }
                Intent.ACTION_SCREEN_OFF -> {
                    isScreenOn = false
                    stopUpdating()
                }
            }
        }
    }

    private val updateRunnable = object : Runnable {
        override fun run() {
            if (isScreenOn) {
                WidgetUpdateHelper.refreshAllWidgets(this@WidgetCountdownService)
                handler.postDelayed(this, 1000)
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_ON)
            addAction(Intent.ACTION_SCREEN_OFF)
        }
        registerReceiver(screenReceiver, filter)
        startUpdating()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(screenReceiver)
        stopUpdating()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun startUpdating() {
        handler.removeCallbacks(updateRunnable)
        handler.post(updateRunnable)
    }

    private fun stopUpdating() {
        handler.removeCallbacks(updateRunnable)
    }
}
