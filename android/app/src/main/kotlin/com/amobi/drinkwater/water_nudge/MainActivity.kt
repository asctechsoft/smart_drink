package com.amobi.drinkwater.water_nudge

import android.Manifest
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.amobi.drinkwater.water_nudge.notification.FCMTokenManager
import com.amobi.drinkwater.water_nudge.notification.NotificationCenter
import com.amobi.drinkwater.water_nudge.widget.*
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import org.json.JSONArray
import org.json.JSONObject

// FlutterFragmentActivity (an AndroidX ComponentActivity) rather than
// FlutterActivity: Health Connect's permission request is an ActivityResult
// contract, which only a ComponentActivity can launch.
class MainActivity : FlutterFragmentActivity() {

    companion object {
        private const val CHANNEL = "com.amobi.drinkwater/notifications"
        private const val WIDGET_CHANNEL = "com.amobi.drinkwater/widget"
        private const val REQUEST_NOTIFICATION_PERMISSION = 1001
        private const val ACTION_SHOW_PERMISSIONS_RATIONALE =
            "androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE"
        private const val ACTION_VIEW_PERMISSION_USAGE =
            "android.intent.action.VIEW_PERMISSION_USAGE"

        // Must match the factoryId passed to NativeAdController on the Dart
        // side (see AdsConfig.nativeAdFactoryId).
        const val NATIVE_AD_FACTORY_ID = "appOpenReplacement"
    }

    private var pendingPermissionResult: MethodChannel.Result? = null

    /** Set when Health Connect launched us to show the privacy policy. */
    private var pendingShowPrivacyPolicy = false

    /**
     * Health Connect requires the app to show its privacy policy on request:
     * on Android 13 and below it fires ACTION_SHOW_PERMISSIONS_RATIONALE at the
     * activity, on 14+ it goes through the ViewPermissionUsageActivity alias.
     * Either way it lands here, and the flag is picked up by Flutter, which
     * opens the policy.
     */
    private fun captureHealthRationale(intent: android.content.Intent?) {
        val action = intent?.action ?: return
        if (action == ACTION_SHOW_PERMISSIONS_RATIONALE ||
            action == ACTION_VIEW_PERMISSION_USAGE
        ) {
            pendingShowPrivacyPolicy = true
        }
    }

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        captureHealthRationale(intent)
    }

    override fun onNewIntent(intent: android.content.Intent) {
        super.onNewIntent(intent)
        captureHealthRationale(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            NATIVE_AD_FACTORY_ID,
            AppNativeAdFactory(this)
        )

        NotificationCenter.createNotificationChannels(this)

        // Restore foreground service and alarms if they were enabled
        if (PrefAssist.getBoolean(this, PrefConst.KEY_NOTIFICATION_ONGOING)) {
            NotificationCenter.startOngoingNotification(this)
        }
        if (PrefAssist.getBoolean(this, PrefConst.KEY_DAILY_NOTIFICATION)) {
            NotificationCenter.scheduleDailyNotification(this)
        }

        // Schedule midnight reset for widgets (idempotent — re-schedules if already set)
        MidnightResetReceiver.schedule(this)

        // Fetch FCM token and register to Firestore for server-side push
        FCMTokenManager.fetchAndRegisterToken(this)

        // Widget channel
        setupWidgetChannel(flutterEngine)

        // Notification channel
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        if (ContextCompat.checkSelfPermission(
                                this, Manifest.permission.POST_NOTIFICATIONS
                            ) == PackageManager.PERMISSION_GRANTED
                        ) {
                            result.success(true)
                        } else {
                            pendingPermissionResult = result
                            ActivityCompat.requestPermissions(
                                this,
                                arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                                REQUEST_NOTIFICATION_PERMISSION
                            )
                        }
                    } else {
                        result.success(true)
                    }
                }

                // Reports — once — that Health Connect asked us to show the
                // privacy policy, so Flutter can open it.
                "consumeShowPrivacyPolicy" -> {
                    val pending = pendingShowPrivacyPolicy
                    pendingShowPrivacyPolicy = false
                    result.success(pending)
                }

                "startOngoingNotification" -> {
                    PrefAssist.setBoolean(this, PrefConst.KEY_NOTIFICATION_ONGOING, true)
                    NotificationCenter.startOngoingNotification(this)
                    result.success(null)
                }

                "stopOngoingNotification" -> {
                    PrefAssist.setBoolean(this, PrefConst.KEY_NOTIFICATION_ONGOING, false)
                    NotificationCenter.stopOngoingNotification(this)
                    result.success(null)
                }

                "syncReminders" -> {
                    val schedulesJson = call.argument<String>("schedulesJson") ?: "[]"
                    PrefAssist.setBoolean(this, PrefConst.KEY_DAILY_NOTIFICATION, true)
                    PrefAssist.setString(
                        this, PrefConst.KEY_REMINDER_SCHEDULES_JSON, schedulesJson
                    )
                    NotificationCenter.scheduleDynamicAlarms(this)
                    // Re-register FCM with updated schedules
                    FCMTokenManager.registerFcmToken(this)
                    result.success(null)
                }

                "scheduleDailyNotification" -> {
                    val morningHour = call.argument<Int>("morningHour")
                        ?: Const.DEFAULT_HOUR_MORNING
                    val afternoonHour = call.argument<Int>("afternoonHour")
                        ?: Const.DEFAULT_HOUR_AFTERNOON
                    val nightHour = call.argument<Int>("nightHour")
                        ?: Const.DEFAULT_HOUR_NIGHT

                    // Build JSON for dynamic alarm system
                    val jsonArray = org.json.JSONArray()
                    for ((h, m) in listOf(
                        morningHour to 0,
                        afternoonHour to 0,
                        nightHour to 0
                    )) {
                        val obj = org.json.JSONObject()
                        obj.put("hour", h)
                        obj.put("minute", m)
                        jsonArray.put(obj)
                    }

                    PrefAssist.setBoolean(this, PrefConst.KEY_DAILY_NOTIFICATION, true)
                    PrefAssist.setString(
                        this, PrefConst.KEY_REMINDER_SCHEDULES_JSON, jsonArray.toString()
                    )

                    // Keep legacy prefs for backward compat
                    PrefAssist.setBoolean(this, PrefConst.KEY_DAILY_NOTIFICATION_MORNING, true)
                    PrefAssist.setBoolean(this, PrefConst.KEY_DAILY_NOTIFICATION_AFTERNOON, true)
                    PrefAssist.setBoolean(this, PrefConst.KEY_DAILY_NOTIFICATION_NIGHT, true)
                    PrefAssist.setInt(this, PrefConst.KEY_DAILY_HOUR_MORNING, morningHour)
                    PrefAssist.setInt(this, PrefConst.KEY_DAILY_HOUR_AFTERNOON, afternoonHour)
                    PrefAssist.setInt(this, PrefConst.KEY_DAILY_HOUR_NIGHT, nightHour)

                    NotificationCenter.scheduleDailyNotification(this)
                    result.success(null)
                }

                "cancelDailyNotification" -> {
                    PrefAssist.setBoolean(this, PrefConst.KEY_DAILY_NOTIFICATION, false)
                    NotificationCenter.cancelDailyNotification(this)
                    // Update Firestore to disable server-side push
                    FCMTokenManager.registerFcmToken(this)
                    result.success(null)
                }

                "updateOngoingData" -> {
                    val currentMl = call.argument<Int>("currentMl") ?: 0
                    val goalMl = call.argument<Int>("goalMl") ?: 2000
                    val lastDrinkText = call.argument<String>("lastDrinkText") ?: ""

                    PrefAssist.setInt(this, PrefConst.ONGOING_CURRENT_ML, currentMl)
                    PrefAssist.setInt(this, PrefConst.ONGOING_GOAL_ML, goalMl)
                    PrefAssist.setString(this, PrefConst.ONGOING_LAST_DRINK_TEXT, lastDrinkText)

                    if (PrefAssist.getBoolean(this, PrefConst.KEY_NOTIFICATION_ONGOING)) {
                        NotificationCenter.updateOngoingDisplay(this)
                    }
                    result.success(null)
                }

                "setFullScreenIntentEnabled" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: true
                    PrefAssist.setBoolean(this, PrefConst.IS_FULL_SCREEN_INTENT_ENABLED, enabled)
                    result.success(null)
                }

                "getFcmToken" -> {
                    val token = PrefAssist.getString(this, PrefConst.FCM_TOKEN)
                    result.success(token)
                }

                "checkPendingAddWater" -> {
                    val pending = PrefAssist.getBoolean(this, PrefConst.PENDING_ADD_WATER)
                    if (pending) {
                        val jsonList = PrefAssist.getString(this, PrefConst.PENDING_ADD_WATER_JSON, "")
                        val resultJson = if (jsonList.isNotEmpty()) {
                            jsonList
                        } else {
                            // Fallback for single amount
                            val amount = PrefAssist.getInt(this, PrefConst.PENDING_ADD_WATER_AMOUNT, 0)
                            "[{\"amount\":$amount,\"type\":\"water\"}]"
                        }
                        
                        // Clear all pending flags/data
                        PrefAssist.setBoolean(this, PrefConst.PENDING_ADD_WATER, false)
                        PrefAssist.setInt(this, PrefConst.PENDING_ADD_WATER_AMOUNT, 0)
                        PrefAssist.setString(this, PrefConst.PENDING_ADD_WATER_JSON, "")
                        
                        result.success(resultJson)
                    } else {
                        result.success(null)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun setupWidgetChannel(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, WIDGET_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateWidgetData" -> {
                    val currentMl = call.argument<Int>("currentMl") ?: 0
                    val goalMl = call.argument<Int>("goalMl") ?: 2000
                    val nextReminderTime = call.argument<String>("nextReminderTime") ?: ""

                    val volumeUnit = call.argument<String>("volumeUnit") ?: "ml"

                    PrefAssist.setInt(this, PrefConst.ONGOING_CURRENT_ML, currentMl)
                    PrefAssist.setInt(this, PrefConst.ONGOING_GOAL_ML, goalMl)
                    PrefAssist.setString(this, PrefConst.WIDGET_VOLUME_UNIT, volumeUnit)
                    PrefAssist.setString(
                        this, WidgetDataHelper.WIDGET_NEXT_REMINDER, nextReminderTime
                    )

                    // Store recent drinks as JSON array
                    val recentDrinks = call.argument<List<Map<String, String>>>("recentDrinks")
                    if (recentDrinks != null) {
                        val jsonArray = JSONArray()
                        for (drink in recentDrinks) {
                            val obj = JSONObject()
                            obj.put("name", drink["name"] ?: "")
                            obj.put("amount", drink["amount"] ?: "")
                            obj.put("time", drink["time"] ?: "")
                            obj.put("type", drink["type"] ?: "water")
                            jsonArray.put(obj)
                        }
                        PrefAssist.setString(
                            this, PrefConst.WIDGET_RECENT_DRINKS, jsonArray.toString()
                        )
                    }

                    // Store localized labels
                    val labels = call.argument<Map<String, String>>("labels")
                    if (labels != null) {
                        for ((key, value) in labels) {
                            // Save as flutter.WIDGET_LABEL_{key}
                            PrefAssist.setString(this, "flutter.widget_label_$key", value)
                        }
                    }

                    WidgetUpdateHelper.refreshAllWidgets(this)
                    result.success(null)
                }

                "requestPinWidget" -> {
                    val widgetType = call.argument<String>("widgetType") ?: ""
                    handlePinWidgetRequest(widgetType, result)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun handlePinWidgetRequest(widgetType: String, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            result.success(false)
            return
        }

        val awm = AppWidgetManager.getInstance(this)
        if (!awm.isRequestPinAppWidgetSupported) {
            result.success(false)
            return
        }

        val providerClass = when (widgetType) {
            "small_a" -> SmallWidgetAProvider::class.java
            "small_b" -> SmallWidgetBProvider::class.java
            "medium_a" -> MediumWidgetAProvider::class.java
            "medium_b" -> MediumWidgetBProvider::class.java
            "large" -> LargeWidgetProvider::class.java
            else -> {
                result.success(false)
                return
            }
        }

        val provider = ComponentName(this, providerClass)
        awm.requestPinAppWidget(provider, null, null)
        result.success(true)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, NATIVE_AD_FACTORY_ID)
        super.cleanUpFlutterEngine(flutterEngine)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_NOTIFICATION_PERMISSION) {
            val granted = grantResults.isNotEmpty() &&
                    grantResults[0] == PackageManager.PERMISSION_GRANTED
            pendingPermissionResult?.success(granted)
            pendingPermissionResult = null
        }
    }
}
