package com.amobi.drinkwater.drink_water

import android.content.Context
import android.content.SharedPreferences
import androidx.core.content.edit

object PrefAssist {
    @Volatile
    private var sharedPreferences: SharedPreferences? = null
    private val lock = Any()

    private fun getSharedPreferences(context: Context): SharedPreferences {
        if (sharedPreferences != null) return sharedPreferences!!
        synchronized(lock) {
            if (sharedPreferences == null) {
                sharedPreferences = context.getSharedPreferences(
                    "FlutterSharedPreferences",
                    Context.MODE_PRIVATE
                )
            }
        }
        return sharedPreferences!!
    }

    fun init(context: Context) {
        getSharedPreferences(context)
    }

    fun getString(context: Context, key: String, defaultValue: String = ""): String {
        return getSharedPreferences(context).getString(key, defaultValue) ?: defaultValue
    }

    fun setString(context: Context, key: String, value: String) {
        getSharedPreferences(context).edit { putString(key, value) }
    }

    fun getInt(context: Context, key: String, defaultValue: Int = 0): Int {
        return try {
            getSharedPreferences(context).getInt(key, defaultValue)
        } catch (e: ClassCastException) {
            // Flutter shared_preferences stores ints as longs
            getLong(context, key, defaultValue.toLong()).toInt()
        }
    }

    fun setInt(context: Context, key: String, value: Int) {
        getSharedPreferences(context).edit { putInt(key, value) }
    }

    fun getLong(context: Context, key: String, defaultValue: Long = 0L): Long {
        return try {
            getSharedPreferences(context).getLong(key, defaultValue)
        } catch (e: ClassCastException) {
            getSharedPreferences(context).getInt(key, defaultValue.toInt()).toLong()
        }
    }

    fun setLong(context: Context, key: String, value: Long) {
        getSharedPreferences(context).edit { putLong(key, value) }
    }

    fun getBoolean(context: Context, key: String, defaultValue: Boolean = false): Boolean {
        return getSharedPreferences(context).getBoolean(key, defaultValue)
    }

    fun setBoolean(context: Context, key: String, value: Boolean) {
        getSharedPreferences(context).edit { putBoolean(key, value) }
    }

    fun getLocalizedContext(context: Context): Context {
        // First, check if PrefConst.KEY_LANGUAGE exists, otherwise use its literal "flutter.language"
        val languageCode = getString(context, "flutter.language", "")
        if (languageCode.isEmpty()) return context

        val locale = if (languageCode.contains("_")) {
            val parts = languageCode.split("_")
            java.util.Locale(parts[0], parts[1])
        } else {
            java.util.Locale(languageCode)
        }

        val config = android.content.res.Configuration(context.resources.configuration)
        config.setLocale(locale)
        config.setLayoutDirection(locale)
        return context.createConfigurationContext(config)
    }
}
