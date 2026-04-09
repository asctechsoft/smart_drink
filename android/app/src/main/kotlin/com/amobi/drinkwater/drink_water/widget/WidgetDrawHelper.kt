package com.amobi.drinkwater.drink_water.widget

import android.content.Context
import android.graphics.*
import android.util.TypedValue

object WidgetDrawHelper {

    fun drawProgressRing(
        context: Context,
        progress: Float,
        sizeDp: Int = 80
    ): Bitmap {
        val pxFloat = dpToPx(context, sizeDp.toFloat())
        val px = pxFloat.toInt()
        val bitmap = Bitmap.createBitmap(px, px, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)

        val center = pxFloat / 2f
        val strokeWidth = dpToPx(context, 8f)
        val radius = (pxFloat - strokeWidth) / 2f - dpToPx(context, 4f)
        val rect = RectF(center - radius, center - radius, center + radius, center + radius)

        val startAngle = 135f
        val totalSweep = 270f

        // Track Drop Shadow (Glow)
        val trackGlowPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.parseColor("#66FFFFFF") // 0.4 alpha white
            style = Paint.Style.STROKE
            this.strokeWidth = strokeWidth
            strokeCap = Paint.Cap.ROUND
            maskFilter = BlurMaskFilter(dpToPx(context, 4f), BlurMaskFilter.Blur.NORMAL)
        }
        canvas.drawArc(rect, startAngle, totalSweep, false, trackGlowPaint)

        // Background Track
        val trackPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.parseColor("#021447")
            style = Paint.Style.STROKE
            this.strokeWidth = strokeWidth
            strokeCap = Paint.Cap.ROUND
        }
        canvas.drawArc(rect, startAngle, totalSweep, false, trackPaint)

        // Progress Arc
        if (progress > 0) {
            val sweepAngle = totalSweep * progress.coerceIn(0f, 1f)

            // Progress Gradient
            val colors = intArrayOf(
                Color.parseColor("#00E0FF"),
                Color.parseColor("#0094FF"),
                Color.parseColor("#00E0FF")
            )
            val positions = floatArrayOf(0f, totalSweep / 360f, 1f)
            val sweepGradient = SweepGradient(center, center, colors, positions)
            
            // Rotate gradient to match startAngle (135)
            val matrix = Matrix()
            matrix.setRotate(startAngle, center, center)
            sweepGradient.setLocalMatrix(matrix)

            val progressPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = sweepGradient
                style = Paint.Style.STROKE
                this.strokeWidth = strokeWidth
                strokeCap = Paint.Cap.ROUND
            }
            canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint)
        }

        return bitmap
    }

    fun drawCircleProgress(
        context: Context,
        progress: Float,
        sizeDp: Int = 60,
        strokeWidthDp: Float = 4f,
        borderWidthDp: Float = 1f
    ): Bitmap {
        val pxFloat = dpToPx(context, sizeDp.toFloat())
        val px = pxFloat.toInt()
        val bitmap = Bitmap.createBitmap(px, px, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)

        val center = pxFloat / 2f
        val strokeWidth = dpToPx(context, strokeWidthDp)
        val borderWidth = dpToPx(context, borderWidthDp)
        
        // The main radius is the center line of the progress ring
        val radius = (pxFloat - strokeWidth) / 2f - borderWidth - dpToPx(context, 1f)
        val rect = RectF(center - radius, center - radius, center + radius, center + radius)

        val startAngle = -90f // Start from top
        val totalSweep = 360f

        val borderPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.parseColor("#4DFFFFFF") // 0.3 alpha white
            style = Paint.Style.STROKE
            this.strokeWidth = borderWidth
        }

        // 1. Draw Outer Border
        val outerRadius = radius + (strokeWidth / 2f) + (borderWidth / 2f)
        canvas.drawCircle(center, center, outerRadius, borderPaint)

        // 2. Draw Inner Border
        val innerRadius = radius - (strokeWidth / 2f) - (borderWidth / 2f)
        canvas.drawCircle(center, center, innerRadius, borderPaint)

        // 3. Background Track
        val trackPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.parseColor("#1AFFFFFF") // 0.1 alpha white track
            style = Paint.Style.STROKE
            this.strokeWidth = strokeWidth
        }
        canvas.drawCircle(center, center, radius, trackPaint)

        // 4. Progress Arc
        if (progress > 0) {
            val sweepAngle = totalSweep * progress.coerceIn(0f, 1f)

            val progressPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.WHITE
                style = Paint.Style.STROKE
                this.strokeWidth = strokeWidth
                strokeCap = Paint.Cap.ROUND
            }
            canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint)
        }

        return bitmap
    }

    private fun dpToPx(context: Context, dp: Float): Float {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            dp,
            context.resources.displayMetrics
        )
    }
}
