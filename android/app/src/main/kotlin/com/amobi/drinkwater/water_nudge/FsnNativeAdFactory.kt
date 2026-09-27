package com.amobi.drinkwater.water_nudge

import android.content.Context
import android.graphics.RenderEffect
import android.graphics.Shader
import android.os.Build
import android.view.LayoutInflater
import android.widget.Button
import android.widget.ImageView
import android.widget.RatingBar
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.NativeAdFactory

/**
 * Renders `res/layout/lout_fsn_native_ad.xml` for the full-screen native ad
 * factory id [MainActivity.FSN_NATIVE_AD_FACTORY_ID] — used for the
 * "FSN_1"/"FSN_2" full-screen ad pages between onboarding steps
 * (`FullScreenNativeAdScreen` on the Dart side). Unlike
 * [AppNativeAdFactory]'s compact card, this fills the whole screen: the
 * ad's own media (image/video) stretches edge to edge behind a bottom info
 * panel, not a small card.
 */
class FsnNativeAdFactory(private val context: Context) : NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = LayoutInflater.from(context)
            .inflate(R.layout.lout_fsn_native_ad, null) as NativeAdView

        val backgroundView = adView.findViewById<ImageView>(R.id.ad_background_blur)
        val mediaView = adView.findViewById<com.google.android.gms.ads.nativead.MediaView>(R.id.ad_media)
        val headlineView = adView.findViewById<TextView>(R.id.ad_headline)
        val bodyView = adView.findViewById<TextView>(R.id.ad_body)
        val iconView = adView.findViewById<ImageView>(R.id.ad_icon)
        val ctaView = adView.findViewById<Button>(R.id.ad_call_to_action)
        val starsView = adView.findViewById<RatingBar>(R.id.ad_stars)
        val advertiserView = adView.findViewById<TextView>(R.id.ad_advertiser)
        val storeView = adView.findViewById<TextView>(R.id.ad_store)

        // Behind everything: a blurred still of the ad's own main image, so
        // the letterboxed edges (media/mediaContent doesn't always exactly
        // match the screen aspect ratio) never show plain navy.
        val mainImage = nativeAd.images.firstOrNull()?.drawable
        if (mainImage != null) {
            backgroundView.setImageDrawable(mainImage)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                backgroundView.setRenderEffect(
                    RenderEffect.createBlurEffect(60f, 60f, Shader.TileMode.CLAMP)
                )
            }
        }

        headlineView.text = nativeAd.headline
        adView.headlineView = headlineView

        mediaView.mediaContent = nativeAd.mediaContent
        adView.mediaView = mediaView

        val body = nativeAd.body
        bodyView.visibility = if (body.isNullOrEmpty()) android.view.View.GONE else android.view.View.VISIBLE
        bodyView.text = body
        adView.bodyView = bodyView

        val cta = nativeAd.callToAction
        ctaView.visibility = if (cta.isNullOrEmpty()) android.view.View.GONE else android.view.View.VISIBLE
        ctaView.text = cta
        adView.callToActionView = ctaView

        val icon = nativeAd.icon
        if (icon != null) {
            iconView.setImageDrawable(icon.drawable)
            iconView.visibility = android.view.View.VISIBLE
        } else {
            iconView.visibility = android.view.View.GONE
        }
        adView.iconView = iconView

        val rating = nativeAd.starRating
        if (rating != null) {
            starsView.rating = rating.toFloat()
            starsView.visibility = android.view.View.VISIBLE
        } else {
            starsView.visibility = android.view.View.GONE
        }
        adView.starRatingView = starsView

        val advertiser = nativeAd.advertiser
        advertiserView.visibility = if (advertiser.isNullOrEmpty()) android.view.View.GONE else android.view.View.VISIBLE
        advertiserView.text = advertiser
        adView.advertiserView = advertiserView

        val store = nativeAd.store
        storeView.visibility = if (store.isNullOrEmpty()) android.view.View.GONE else android.view.View.VISIBLE
        storeView.text = store
        adView.storeView = storeView

        adView.setNativeAd(nativeAd)

        return adView
    }
}
