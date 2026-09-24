package com.amobi.drinkwater.water_nudge

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.RatingBar
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.NativeAdFactory

/**
 * Renders `res/layout/native_ad_layout.xml` for the [NativeAdController]
 * factory id [MainActivity.NATIVE_AD_FACTORY_ID] — the app-styled card shown
 * on app reopen (Android only), in place of a full-screen App Open Ad.
 * Registered in MainActivity.configureFlutterEngine, unregistered in
 * cleanUpFlutterEngine.
 */
class AppNativeAdFactory(private val context: Context) : NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = LayoutInflater.from(context)
            .inflate(R.layout.native_ad_layout, null) as NativeAdView

        val headlineView = adView.findViewById<TextView>(R.id.ad_headline)
        val bodyView = adView.findViewById<TextView>(R.id.ad_body)
        val iconView = adView.findViewById<ImageView>(R.id.ad_icon)
        val ctaView = adView.findViewById<Button>(R.id.ad_call_to_action)
        val starsView = adView.findViewById<RatingBar>(R.id.ad_stars)

        headlineView.text = nativeAd.headline
        adView.headlineView = headlineView

        val body = nativeAd.body
        bodyView.visibility = if (body.isNullOrEmpty()) View.GONE else View.VISIBLE
        bodyView.text = body
        adView.bodyView = bodyView

        val cta = nativeAd.callToAction
        ctaView.visibility = if (cta.isNullOrEmpty()) View.GONE else View.VISIBLE
        ctaView.text = cta
        adView.callToActionView = ctaView

        val icon = nativeAd.icon
        if (icon != null) {
            iconView.setImageDrawable(icon.drawable)
            iconView.visibility = View.VISIBLE
        } else {
            iconView.visibility = View.GONE
        }
        adView.iconView = iconView

        val rating = nativeAd.starRating
        if (rating != null) {
            starsView.rating = rating.toFloat()
            starsView.visibility = View.VISIBLE
        } else {
            starsView.visibility = View.GONE
        }
        adView.starRatingView = starsView

        adView.setNativeAd(nativeAd)

        return adView
    }
}
