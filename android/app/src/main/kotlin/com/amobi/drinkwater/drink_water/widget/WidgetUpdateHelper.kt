package com.amobi.drinkwater.drink_water.widget

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context

/**
 * Central helper to refresh all active widgets from anywhere (Flutter channel, etc.).
 */
object WidgetUpdateHelper {

    fun refreshAllWidgets(context: Context) {
        val awm = AppWidgetManager.getInstance(context)

        refreshProvider<SmallWidgetAProvider>(context, awm) { ctx, mgr, id ->
            SmallWidgetAProvider.updateWidget(ctx, mgr, id)
        }
        refreshProvider<SmallWidgetBProvider>(context, awm) { ctx, mgr, id ->
            SmallWidgetBProvider.updateWidget(ctx, mgr, id)
        }
        refreshProvider<MediumWidgetAProvider>(context, awm) { ctx, mgr, id ->
            MediumWidgetAProvider.updateWidget(ctx, mgr, id)
        }
        refreshProvider<MediumWidgetBProvider>(context, awm) { ctx, mgr, id ->
            MediumWidgetBProvider.updateWidget(ctx, mgr, id)
        }
        refreshProvider<LargeWidgetProvider>(context, awm) { ctx, mgr, id ->
            LargeWidgetProvider.updateWidget(ctx, mgr, id)
        }
    }

    private inline fun <reified T> refreshProvider(
        context: Context,
        awm: AppWidgetManager,
        updater: (Context, AppWidgetManager, Int) -> Unit
    ) {
        val ids = awm.getAppWidgetIds(ComponentName(context, T::class.java))
        for (id in ids) {
            updater(context, awm, id)
        }
    }
}
