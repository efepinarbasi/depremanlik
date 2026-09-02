package com.seismoalert.platform

import platform.Foundation.NSURL
import platform.UIKit.UIApplication

actual fun openUrl(url: String) {
    val nsUrl = NSURL.URLWithString(url) ?: return
    UIApplication.sharedApplication.openURL(nsUrl)
}

actual fun sendSms(phones: List<String>, message: String) {
    val phoneStr = phones.joinToString(",")
    val smsUrl = "sms:$phoneStr&body=$message"
    val nsUrl = NSURL.URLWithString(smsUrl) ?: return
    UIApplication.sharedApplication.openURL(nsUrl)
}

actual fun playAlarmSound() {
    // iOS'ta AudioServicesPlaySystemSound veya AVAudioPlayer ile implement edilecek
}

actual fun stopAlarmSound() {
    // iOS'ta stop implementasyonu
}

actual fun vibrate() {
    // iOS'ta AudioServicesPlaySystemSound(kSystemSoundID_Vibrate) ile implement edilecek
}
