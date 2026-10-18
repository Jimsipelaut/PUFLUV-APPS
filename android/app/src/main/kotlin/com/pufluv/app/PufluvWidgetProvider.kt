package com.pufluv.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import java.io.File

class PufluvWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.pufluv_widget_layout)

            // 1. Ambil data dari shared preferences
            val caption = widgetData.getString("partner_caption", null)
            val timeAgo = widgetData.getString("partner_time_ago", null)
            val eventTitle = widgetData.getString("nearest_event_title", null)
            val countdownNum = widgetData.getString("nearest_countdown_number", null)
            val countdownLabel = widgetData.getString("nearest_countdown_label", null)
            val imagePath = widgetData.getString("partner_image_path", null)

            // Update teks caption & waktu
            if (!caption.isNullOrBlank()) {
                views.setTextViewText(R.id.widget_caption, caption)
                views.setViewVisibility(R.id.widget_caption, View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.widget_caption, View.GONE)
            }

            if (!timeAgo.isNullOrBlank()) {
                views.setTextViewText(R.id.widget_time_ago, timeAgo)
                views.setViewVisibility(R.id.widget_time_ago, View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.widget_time_ago, View.GONE)
            }

            // Update countdown
            if (!countdownNum.isNullOrBlank()) {
                views.setTextViewText(R.id.widget_event_title, eventTitle ?: "HARI PENTING")
                views.setTextViewText(R.id.widget_countdown_number, countdownNum)
                views.setTextViewText(R.id.widget_countdown_label, countdownLabel ?: "hari lagi")
                views.setViewVisibility(R.id.widget_countdown_container, View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.widget_countdown_container, View.GONE)
            }

            // Update foto dari local file path
            var imageLoaded = false
            if (!imagePath.isNullOrBlank()) {
                val imageFile = File(imagePath)
                if (imageFile.exists() && imageFile.canRead()) {
                    try {
                        // Decode bounds terlebih dahulu untuk kalkulasi downsampling hemat memori IPC
                        val options = BitmapFactory.Options().apply {
                            inJustDecodeBounds = true
                        }
                        BitmapFactory.decodeFile(imageFile.absolutePath, options)

                        // Target dimensi widget Android maksimum ~480x480 px dengan RGB_565
                        // Ukuran memori maksimal: 480 * 480 * 2 = ~460 KB (jauh di bawah batas Binder IPC 1MB)
                        val maxDim = 480
                        var inSampleSize = 1
                        val (height: Int, width: Int) = options.outHeight to options.outWidth
                        if (height > maxDim || width > maxDim) {
                            val halfHeight: Int = height / 2
                            val halfWidth: Int = width / 2
                            while (halfHeight / inSampleSize >= maxDim || halfWidth / inSampleSize >= maxDim) {
                                inSampleSize *= 2
                            }
                        }

                        val decodeOpts = BitmapFactory.Options().apply {
                            this.inSampleSize = inSampleSize
                            inPreferredConfig = android.graphics.Bitmap.Config.RGB_565
                        }
                        val bitmap = BitmapFactory.decodeFile(imageFile.absolutePath, decodeOpts)
                        if (bitmap != null) {
                            views.setImageViewBitmap(R.id.widget_image, bitmap)
                            views.setViewVisibility(R.id.widget_image, View.VISIBLE)
                            views.setViewVisibility(R.id.widget_placeholder, View.GONE)
                            views.setViewVisibility(R.id.widget_scrim_overlay, View.VISIBLE)
                            imageLoaded = true
                        }
                    } catch (e: Throwable) {
                        e.printStackTrace()
                    }
                }
            }

            if (!imageLoaded) {
                views.setViewVisibility(R.id.widget_image, View.GONE)
                views.setViewVisibility(R.id.widget_placeholder, View.VISIBLE)
                views.setViewVisibility(R.id.widget_scrim_overlay, View.GONE)
            }

            // Klik widget untuk membuka aplikasi
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
