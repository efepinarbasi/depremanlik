package com.seismoalert.platform

import android.content.Context
import android.content.Intent
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager

/**
 * Android context reference - MainActivity'de set edilmeli
 */
object AndroidContext {
    var appContext: Context? = null
}

actual fun openUrl(url: String) {
    val ctx = AndroidContext.appContext ?: return
    try {
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        ctx.startActivity(intent)
    } catch (_: Exception) { }
}

actual fun sendSms(phones: List<String>, message: String) {
    val ctx = AndroidContext.appContext ?: return
    try {
        val uri = Uri.parse("sms:${phones.joinToString(",")}")
        val intent = Intent(Intent.ACTION_SENDTO, uri).apply {
            putExtra("sms_body", message)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        ctx.startActivity(intent)
    } catch (_: Exception) { }
}

private var ringtone: android.media.Ringtone? = null

actual fun playAlarmSound() {
    val ctx = AndroidContext.appContext ?: return
    try {
        val alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        ringtone = RingtoneManager.getRingtone(ctx, alarmUri)
        ringtone?.play()
    } catch (_: Exception) { }
}

actual fun stopAlarmSound() {
    ringtone?.stop()
    ringtone = null
}

@Suppress("DEPRECATION")
actual fun vibrate() {
    val ctx = AndroidContext.appContext ?: return
    try {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vibratorManager = ctx.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            vibratorManager.defaultVibrator.vibrate(VibrationEffect.createOneShot(500, VibrationEffect.DEFAULT_AMPLITUDE))
        } else {
            val vibrator = ctx.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator.vibrate(VibrationEffect.createOneShot(500, VibrationEffect.DEFAULT_AMPLITUDE))
            } else {
                vibrator.vibrate(500)
            }
        }
    } catch (_: Exception) { }
}
