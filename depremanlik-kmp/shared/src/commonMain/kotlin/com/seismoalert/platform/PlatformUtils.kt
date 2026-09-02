package com.seismoalert.platform

/**
 * Platform-specific URL açma ve SMS gönderme.
 */
expect fun openUrl(url: String)

expect fun sendSms(phones: List<String>, message: String)

expect fun playAlarmSound()

expect fun stopAlarmSound()

expect fun vibrate()
