package com.example.finance_mobile

import android.content.Context
import androidx.work.*
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.finance_mobile.notifications.NotificationWorker
import java.util.concurrent.TimeUnit

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.finance_mobile/notifications"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleNotification" -> {
                    val title = call.argument<String>("title")
                    val message = call.argument<String>("message")
                    val timestamp = call.argument<Long>("timestamp")
                    val notificationId = call.argument<Int>("id")
                    
                    if (title != null && message != null && timestamp != null && notificationId != null) {
                        scheduleNotification(title, message, timestamp, notificationId)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Missing required arguments", null)
                    }
                }
                "cancelNotification" -> {
                    val id = call.argument<Int>("id")
                    if (id != null) {
                        cancelNotification(id)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Missing notification id", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun scheduleNotification(title: String, message: String, timestamp: Long, notificationId: Int) {
        val currentTime = System.currentTimeMillis()
        val delay = timestamp - currentTime

        val inputData = workDataOf(
            NotificationWorker.KEY_TITLE to title,
            NotificationWorker.KEY_MESSAGE to message,
            NotificationWorker.KEY_NOTIFICATION_ID to notificationId
        )

        val notificationWork = OneTimeWorkRequestBuilder<NotificationWorker>()
            .setInitialDelay(delay, TimeUnit.MILLISECONDS)
            .setInputData(inputData)
            .addTag(notificationId.toString())
            .build()

        WorkManager.getInstance(this)
            .enqueueUniqueWork(
                notificationId.toString(),
                ExistingWorkPolicy.REPLACE,
                notificationWork
            )
    }

    private fun cancelNotification(notificationId: Int) {
        WorkManager.getInstance(this)
            .cancelUniqueWork(notificationId.toString())
    }
}
