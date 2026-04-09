package com.amobi.drinkwater.drink_water.notification

import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import android.widget.Button
import android.widget.ProgressBar
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.amobi.drinkwater.drink_water.MainActivity
import com.amobi.drinkwater.drink_water.PrefAssist
import com.amobi.drinkwater.drink_water.PrefConst
import com.amobi.drinkwater.drink_water.R
import java.lang.ref.WeakReference

class DailyFullScreenActivity : AppCompatActivity() {

    companion object {
        var instance: WeakReference<DailyFullScreenActivity> = WeakReference(null)
        private const val DEFAULT_ADD_AMOUNT = 250

        private val MOTIVATION_MESSAGES = listOf(
            "Time to hydrate!",
            "Your body needs water!",
            "Stay refreshed!",
            "Keep your hydration going!",
            "Water is your superpower!"
        )
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        instance = WeakReference(this)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                        WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            )
        }

        setContentView(R.layout.activity_daily_fullscreen)

        val currentMl = PrefAssist.getInt(this, PrefConst.ONGOING_CURRENT_ML, 0)
        val goalMl = PrefAssist.getInt(this, PrefConst.ONGOING_GOAL_ML, 2000)
        val percent = if (goalMl > 0) (currentMl * 100 / goalMl) else 0

        findViewById<ProgressBar>(R.id.pb_circular).progress = percent.coerceIn(0, 100)
        findViewById<TextView>(R.id.tv_current_goal).text = "$currentMl / $goalMl ml"
        findViewById<TextView>(R.id.tv_motivation).text = MOTIVATION_MESSAGES.random()

        findViewById<Button>(R.id.btn_add_water).setOnClickListener {
            PrefAssist.setBoolean(this, PrefConst.PENDING_ADD_WATER, true)
            PrefAssist.setInt(this, PrefConst.PENDING_ADD_WATER_AMOUNT, DEFAULT_ADD_AMOUNT)
            val newMl = currentMl + DEFAULT_ADD_AMOUNT
            PrefAssist.setInt(this, PrefConst.ONGOING_CURRENT_ML, newMl)
            NotificationCenter.updateOngoingDisplay(this)
            finish()
        }

        findViewById<Button>(R.id.btn_open_app).setOnClickListener {
            val launchIntent = Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            startActivity(launchIntent)
            finish()
        }

        findViewById<Button>(R.id.btn_dismiss).setOnClickListener {
            finish()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        if (instance.get() == this) {
            instance = WeakReference(null)
        }
    }
}
