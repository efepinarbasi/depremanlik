package com.seismoalert.models

import kotlinx.datetime.*
import kotlinx.serialization.Serializable

@Serializable
data class News(
    val title: String,
    val link: String,
    val description: String,
    val pubDateMs: Long,
    val source: String? = "Google News"
) {
    val formattedDate: String
        get() {
            return try {
                val instant = Instant.fromEpochMilliseconds(pubDateMs)
                val dt = instant.toLocalDateTime(TimeZone.currentSystemDefault())
                "${dt.dayOfMonth.toString().padStart(2, '0')}.${dt.monthNumber.toString().padStart(2, '0')}.${dt.year} ${dt.hour.toString().padStart(2, '0')}:${dt.minute.toString().padStart(2, '0')}"
            } catch (_: Exception) {
                ""
            }
        }

    val cleanDescription: String
        get() = description.replace(Regex("<[^>]*>|&[^;]+;"), "")
}
