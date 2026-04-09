package com.amobi.drinkwater.drink_water.notification

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.core.app.ActivityCompat
import com.amobi.drinkwater.drink_water.Const
import com.amobi.drinkwater.drink_water.PrefAssist
import com.amobi.drinkwater.drink_water.PrefConst
import com.google.firebase.Firebase
import com.google.firebase.firestore.firestore
import com.google.firebase.messaging.FirebaseMessaging
import java.util.Calendar
import java.util.TimeZone

object FCMTokenManager {

    private const val TAG = "FCMTokenManager"

    /**
     * Fetch FCM token from Firebase SDK and cache in SharedPreferences.
     * Called from MainActivity on each start (throttled by caller).
     */
    fun fetchAndRegisterToken(context: Context) {
        val cachedToken = PrefAssist.getString(context, PrefConst.FCM_TOKEN)

        if (cachedToken.isEmpty()) {
            // No cached token — fetch from Firebase
            FirebaseMessaging.getInstance().token.addOnSuccessListener { token ->
                Log.d(TAG, "FCM token fetched: $token")
                PrefAssist.setString(context, PrefConst.FCM_TOKEN, token)
                onTokenAvailable(context)
            }.addOnFailureListener { e ->
                Log.e(TAG, "Failed to fetch FCM token", e)
            }
        } else {
            onTokenAvailable(context)
        }
    }

    /**
     * Decide whether to register/re-register the token to Firestore.
     */
    private fun onTokenAvailable(context: Context) {
        val now = System.currentTimeMillis()

        // Re-register if:
        // 1. Previous registration failed
        // 2. No push received for 3 days (server might have lost the token)
        // 3. Token not updated for 21 days (periodic refresh)
        val regFailed = PrefAssist.getBoolean(context, PrefConst.IS_FCM_TOKEN_REG_FAILED)
        val lastPush = PrefAssist.getLong(context, PrefConst.LAST_FCM_PUSH_RECORDED, 0L)
        val lastUpdate = PrefAssist.getLong(context, PrefConst.FCM_TOKEN_UPDATE_TIMESTAMP, 0L)
        val isDailyEnabled = PrefAssist.getBoolean(context, PrefConst.KEY_DAILY_NOTIFICATION)

        if (regFailed ||
            (isDailyEnabled && lastPush > 0 && now - lastPush > Const.REREG_FCM_TOKEN_TIME) ||
            (now - lastUpdate > PrefConst.FCM_TOKEN_RE_UPDATE_TIME)
        ) {
            registerFcmToken(context)
        }
    }

    /**
     * Register (or update) the FCM token document in Firestore.
     * Stores all reminder schedules + timezone so the server bot can
     * send push notifications at the correct local times.
     */
    fun registerFcmToken(context: Context) {
        PrefAssist.setBoolean(context, PrefConst.IS_FCM_TOKEN_REG_FAILED, true)

        val token = PrefAssist.getString(context, PrefConst.FCM_TOKEN)
        if (token.isEmpty()) return

        val isDailyEnabled = PrefAssist.getBoolean(context, PrefConst.KEY_DAILY_NOTIFICATION)
        val schedulesJson = PrefAssist.getString(
            context, PrefConst.KEY_REMINDER_SCHEDULES_JSON, "[]"
        )

        val flutterLang = PrefAssist.getString(context, "flutter.language", "")
        val language = if (flutterLang.isNotEmpty()) flutterLang else java.util.Locale.getDefault().language

        val soundEffect = PrefAssist.getString(context, "flutter.sound_effect", "default_sound")

        val dict = hashMapOf<String, Any>(
            "is_enabled" to if (isDailyEnabled) "true" else "false",
            "schedules_json" to schedulesJson,
            "timezone" to getCurrentTimezoneOffset(),
            "client_updated_time" to System.currentTimeMillis(),
            "os_api_level" to Build.VERSION.RELEASE,
            "app_version" to 1,
            "is_allow_notification" to if (checkNotificationPermission(context)) "true" else "false",
            "language" to language,
            "sound_effect" to soundEffect,
        )

        val db = Firebase.firestore
        db.collection(Const.FIRESTORE_FCM_COLLECTION)
            .document(token)
            .set(dict)
            .addOnSuccessListener {
                Log.d(TAG, "Firestore FCM token registered successfully")
                PrefAssist.setBoolean(context, PrefConst.IS_FCM_TOKEN_REG_FAILED, false)
                PrefAssist.setLong(
                    context, PrefConst.FCM_TOKEN_UPDATE_TIMESTAMP,
                    System.currentTimeMillis()
                )
            }
            .addOnFailureListener { e ->
                Log.e(TAG, "Firestore FCM token registration failed", e)
                // IS_FCM_TOKEN_REG_FAILED remains true — will retry on next app start
            }
    }

    /**
     * Returns the device timezone offset as "+HHMM" or "-HHMM" string.
     * e.g. Vietnam (UTC+7) → "+0700", US Eastern (UTC-5) → "-0500"
     */
    private fun getCurrentTimezoneOffset(): String {
        val tz = TimeZone.getDefault()
        val offsetMs = tz.getOffset(Calendar.getInstance().timeInMillis)
        val sign = if (offsetMs >= 0) "+" else "-"
        val absMs = Math.abs(offsetMs)
        val hours = absMs / (60 * 60 * 1000)
        val minutes = (absMs % (60 * 60 * 1000)) / (60 * 1000)
        return String.format("%s%02d%02d", sign, hours, minutes)
    }

    private fun checkNotificationPermission(context: Context): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ActivityCompat.checkSelfPermission(
                context, Manifest.permission.POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
    }
}
