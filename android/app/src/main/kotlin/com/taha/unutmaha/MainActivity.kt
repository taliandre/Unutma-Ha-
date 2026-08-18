package com.taha.unutmaha

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.ContentResolver
import android.content.pm.PackageManager
import android.os.Build
import android.provider.CalendarContract
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CALENDAR_CHANNEL = "com.example.threshold/calendar"
    private val CALENDAR_PERMISSION_REQUEST = 1001

    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ── Takvim MethodChannel ──────────────────────────────────────────────
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CALENDAR_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getTodayEvents" -> {
                    if (hasCalendarPermission()) {
                        result.success(readTodayEvents())
                    } else {
                        pendingResult = result
                        requestCalendarPermission()
                    }
                }
                "addEvent" -> {
                    if (hasCalendarPermission()) {
                        try {
                            insertEvent(
                                title = call.argument<String>("title") ?: "",
                                location = call.argument<String>("location") ?: "",
                                startMs = call.argument<Long>("startMs") ?: 0L,
                                endMs = call.argument<Long>("endMs") ?: 0L,
                                allDay = call.argument<Boolean>("allDay") ?: false,
                            )
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("ADD_FAILED", e.message, null)
                        }
                    } else {
                        pendingResult = result
                        requestCalendarPermission()
                    }
                }
                "deleteEvent" -> {
                    if (hasCalendarPermission()) {
                        try {
                            val id = call.argument<Int>("id") ?: 0
                            removeEvent(id.toLong())
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("DELETE_FAILED", e.message, null)
                        }
                    } else {
                        pendingResult = result
                        requestCalendarPermission()
                    }
                }
                else -> result.notImplemented()
            }
        }

        setupNotificationChannels()
    }

    // ── İzin Kontrolü ─────────────────────────────────────────────────────────

    private fun hasCalendarPermission(): Boolean =
        ContextCompat.checkSelfPermission(
            this, Manifest.permission.READ_CALENDAR
        ) == PackageManager.PERMISSION_GRANTED

    private fun requestCalendarPermission() {
        ActivityCompat.requestPermissions(
            this,
            arrayOf(Manifest.permission.READ_CALENDAR, Manifest.permission.WRITE_CALENDAR),
            CALENDAR_PERMISSION_REQUEST
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == CALENDAR_PERMISSION_REQUEST) {
            val granted = grantResults.isNotEmpty() &&
                    grantResults[0] == PackageManager.PERMISSION_GRANTED
            if (granted) {
                pendingResult?.success(readTodayEvents())
            } else {
                pendingResult?.error("PERMISSION_DENIED", "Takvim izni reddedildi.", null)
            }
            pendingResult = null
        }
    }

    // ── Etkinlik Ekle ─────────────────────────────────────────────────────────

    private fun removeEvent(eventId: Long) {
        val uri = android.content.ContentUris.withAppendedId(
            CalendarContract.Events.CONTENT_URI,
            eventId
        )
        contentResolver.delete(uri, null, null)
    }

    private fun insertEvent(
        title: String,
        location: String,
        startMs: Long,
        endMs: Long,
        allDay: Boolean
    ) {
        // İlk takvimi bul (varsayılan)
        val calCursor = contentResolver.query(
            CalendarContract.Calendars.CONTENT_URI,
            arrayOf(CalendarContract.Calendars._ID),
            "${CalendarContract.Calendars.VISIBLE} = 1",
            null,
            "${CalendarContract.Calendars._ID} ASC LIMIT 1"
        )
        var calendarId = 1L
        calCursor?.use {
            if (it.moveToFirst()) {
                calendarId = it.getLong(0)
            }
        }

        val values = android.content.ContentValues().apply {
            put(CalendarContract.Events.CALENDAR_ID, calendarId)
            put(CalendarContract.Events.TITLE, title)
            put(CalendarContract.Events.EVENT_LOCATION, location)
            put(CalendarContract.Events.DTSTART, startMs)
            put(CalendarContract.Events.DTEND, endMs)
            put(CalendarContract.Events.ALL_DAY, if (allDay) 1 else 0)
            put(CalendarContract.Events.EVENT_TIMEZONE,
                java.util.TimeZone.getDefault().id)
        }
        contentResolver.insert(CalendarContract.Events.CONTENT_URI, values)
    }

    // ── Bugünkü Etkinlikleri Oku ──────────────────────────────────────────────

    private fun readTodayEvents(): List<Map<String, Any?>> {
        val now = System.currentTimeMillis()
        val cal = java.util.Calendar.getInstance()

        // Günün başı
        cal.set(java.util.Calendar.HOUR_OF_DAY, 0)
        cal.set(java.util.Calendar.MINUTE, 0)
        cal.set(java.util.Calendar.SECOND, 0)
        cal.set(java.util.Calendar.MILLISECOND, 0)
        val startOfDay = cal.timeInMillis

        // Günün sonu
        cal.set(java.util.Calendar.HOUR_OF_DAY, 23)
        cal.set(java.util.Calendar.MINUTE, 59)
        cal.set(java.util.Calendar.SECOND, 59)
        val endOfDay = cal.timeInMillis

        val events = mutableListOf<Map<String, Any?>>()

        val projection = arrayOf(
            CalendarContract.Instances.EVENT_ID,
            CalendarContract.Events.TITLE,
            CalendarContract.Instances.BEGIN,
            CalendarContract.Instances.END,
            CalendarContract.Events.EVENT_LOCATION,
            CalendarContract.Events.ALL_DAY,
            CalendarContract.Calendars.CALENDAR_COLOR
        )

        val uri = CalendarContract.Instances.CONTENT_URI.buildUpon()
            .appendPath(startOfDay.toString())
            .appendPath(endOfDay.toString())
            .build()

        try {
            val cursor = contentResolver.query(
                uri, projection, null, null,
                "${CalendarContract.Instances.BEGIN} ASC"
            )

            cursor?.use {
                val idIdx = it.getColumnIndex(CalendarContract.Instances.EVENT_ID)
                val titleIdx = it.getColumnIndex(CalendarContract.Events.TITLE)
                val beginIdx = it.getColumnIndex(CalendarContract.Instances.BEGIN)
                val endIdx = it.getColumnIndex(CalendarContract.Instances.END)
                val locationIdx = it.getColumnIndex(CalendarContract.Events.EVENT_LOCATION)
                val allDayIdx = it.getColumnIndex(CalendarContract.Events.ALL_DAY)
                val colorIdx = it.getColumnIndex(CalendarContract.Calendars.CALENDAR_COLOR)

                while (it.moveToNext()) {
                    events.add(
                        mapOf(
                            "id" to (if (idIdx >= 0) it.getLong(idIdx).toInt() else 0),
                            "title" to (if (titleIdx >= 0) it.getString(titleIdx) else null),
                            "startMs" to (if (beginIdx >= 0) it.getLong(beginIdx) else 0L),
                            "endMs" to (if (endIdx >= 0) it.getLong(endIdx) else 0L),
                            "location" to (if (locationIdx >= 0) it.getString(locationIdx) else null),
                            "allDay" to (if (allDayIdx >= 0) it.getInt(allDayIdx) == 1 else false),
                            "calendarColor" to (if (colorIdx >= 0) it.getInt(colorIdx) else null)
                        )
                    )
                }
            }
        } catch (e: Exception) {
            // Hata durumunda boş liste dön
        }

        return events
    }

    // ── Bildirim Kanalları ────────────────────────────────────────────────────

    private fun setupNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = getSystemService(NotificationManager::class.java)

            val defaultChannel = NotificationChannel(
                "default_channel",
                "Genel Bildirimler",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply { description = "Genel bildirim kanalı" }
            notificationManager?.createNotificationChannel(defaultChannel)

            val highChannel = NotificationChannel(
                "high_priority_channel",
                "Önemli Bildirimler",
                NotificationManager.IMPORTANCE_HIGH
            ).apply { description = "Önemli bildirim kanalı" }
            notificationManager?.createNotificationChannel(highChannel)
        }
    }
}
