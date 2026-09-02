package com.seismoalert.models

import kotlinx.datetime.Instant
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime
import kotlinx.serialization.Serializable
import kotlin.math.*

@Serializable
data class Earthquake(
    val id: String,
    val title: String,
    val dateEpochMs: Long,
    val mag: Double,
    val depth: Double,
    val latitude: Double,
    val longitude: Double,
    var distance: Double = 0.0 // Metre cinsinden mesafe
) {
    val formattedDate: String
        get() {
            return try {
                val instant = Instant.fromEpochMilliseconds(dateEpochMs)
                val dt = instant.toLocalDateTime(TimeZone.currentSystemDefault())
                "${dt.dayOfMonth.toString().padStart(2, '0')}.${dt.monthNumber.toString().padStart(2, '0')}.${dt.year} ${dt.hour.toString().padStart(2, '0')}:${dt.minute.toString().padStart(2, '0')}"
            } catch (_: Exception) {
                ""
            }
        }

    val formattedDateFull: String
        get() {
            return try {
                val instant = Instant.fromEpochMilliseconds(dateEpochMs)
                val dt = instant.toLocalDateTime(TimeZone.currentSystemDefault())
                "${dt.dayOfMonth.toString().padStart(2, '0')}.${dt.monthNumber.toString().padStart(2, '0')}.${dt.year} - ${dt.hour.toString().padStart(2, '0')}:${dt.minute.toString().padStart(2, '0')}:${dt.second.toString().padStart(2, '0')}"
            } catch (_: Exception) {
                ""
            }
        }

    val distanceKm: Double
        get() = distance / 1000.0

    companion object {
        /**
         * AFAD JSON API'den parse
         */
        fun fromJsonAfad(json: Map<String, Any?>): Earthquake {
            var lat = 0.0
            var lng = 0.0

            val geojson = json["geojson"] as? Map<*, *>
            val coords = geojson?.get("coordinates") as? List<*>
            if (coords != null && coords.size >= 2) {
                lng = parseDouble(coords[0])
                lat = parseDouble(coords[1])
            } else {
                lat = parseDouble(json["lat"] ?: json["latitude"])
                lng = parseDouble(json["lng"] ?: json["longitude"])
            }

            val dateStr = (json["date_time"] ?: json["date"])?.toString() ?: ""
            val dateMs = parseAfadDateToEpochMs(dateStr)

            return Earthquake(
                id = (json["earthquake_id"] ?: json["id"] ?: "").toString(),
                title = (json["title"] ?: json["location"] ?: "Bilinmeyen Konum").toString(),
                dateEpochMs = dateMs,
                mag = parseDouble(json["mag"] ?: json["magnitude"]),
                depth = parseDouble(json["depth"]),
                latitude = lat,
                longitude = lng,
            )
        }

        /**
         * USGS GeoJSON API'den parse
         */
        fun fromJsonUSGS(json: Map<String, Any?>): Earthquake {
            val properties = json["properties"] as? Map<*, *> ?: emptyMap<String, Any?>()
            val geometry = json["geometry"] as? Map<*, *> ?: emptyMap<String, Any?>()
            val coordinates = geometry["coordinates"] as? List<*> ?: listOf(0.0, 0.0, 0.0)

            val timeMs = (properties["time"] as? Number)?.toLong() ?: System.currentTimeMillis()

            var title = (properties["place"] ?: "Bilinmeyen Konum").toString()
            if (title.contains(" of ")) {
                title = title.substringAfter(" of ").trim()
            }

            return Earthquake(
                id = (json["id"] ?: "").toString(),
                title = title,
                dateEpochMs = timeMs,
                mag = parseDouble(properties["mag"]),
                depth = parseDouble(if (coordinates.size > 2) coordinates[2] else 0.0),
                latitude = parseDouble(coordinates.getOrNull(1) ?: 0.0),
                longitude = parseDouble(coordinates.getOrNull(0) ?: 0.0),
            )
        }

        /**
         * Kandilli RSS XML'den parse.
         * title: "1.5 (ML) MALAZGIRT"
         * description: date, lat, lng, depth bilgilerini içerir
         */
        fun fromKandilliXml(
            titleText: String,
            descText: String,
            linkText: String
        ): Earthquake {
            // Büyüklük
            var mag = 0.0
            val magMatch = Regex("""^([\d.]+)""").find(titleText)
            if (magMatch != null) {
                mag = magMatch.groupValues[1].toDoubleOrNull() ?: 0.0
            }

            // Konum adı
            val location = titleText.replace(Regex("""^[\d.]+\s*(?:\([a-zA-Z]+\)|\-)?\s*"""), "").trim()

            // Tarih (description'dan): "2024.12.11 09:22:06"
            var dateMs = System.currentTimeMillis()
            val dateMatch = Regex("""(\d{4})[./-](\d{2})[./-](\d{2})\s+(\d{2}):(\d{2}):(\d{2})""").find(descText)
            if (dateMatch != null) {
                try {
                    val (y, mo, d, h, mi, s) = dateMatch.destructured
                    // Basit epoch hesabı (yaklaşık)
                    val dateStr = "$y-${mo}-${d}T${h}:${mi}:${s}"
                    val instant = Instant.parse("${dateStr}Z")
                    dateMs = instant.toEpochMilliseconds()
                } catch (_: Exception) {}
            }

            // Derinlik
            var depth = 0.0
            val depthMatch = Regex("""Derinlik[^\d]*([\d.]+)""").find(descText)
            if (depthMatch != null) {
                depth = depthMatch.groupValues[1].toDoubleOrNull() ?: 0.0
            }

            // Koordinatlar (float'ları yakala)
            var lat = 0.0
            var lng = 0.0
            val floatMatches = Regex("""\b(\d+\.\d+)\b""").findAll(descText).toList()
            if (floatMatches.size >= 3) {
                lat = floatMatches[1].groupValues[1].toDoubleOrNull() ?: 0.0
                lng = floatMatches[2].groupValues[1].toDoubleOrNull() ?: 0.0
            }
            if (depth == 0.0 && floatMatches.isNotEmpty()) {
                depth = (if (floatMatches.size >= 4) floatMatches[3].groupValues[1] else floatMatches.last().groupValues[1]).toDoubleOrNull() ?: 0.0
            }

            val id = if (linkText.isNotEmpty()) {
                linkText.split("/").last().replace(".asp", "")
            } else {
                dateMs.toString()
            }

            return Earthquake(
                id = id,
                title = location.ifEmpty { "Bilinmeyen Konum" },
                dateEpochMs = dateMs,
                mag = mag,
                depth = depth,
                latitude = lat,
                longitude = lng,
            )
        }

        // --- Yardımcı fonksiyonlar ---

        private fun parseDouble(value: Any?): Double {
            return when (value) {
                is Number -> value.toDouble()
                is String -> value.toDoubleOrNull() ?: 0.0
                else -> 0.0
            }
        }

        private fun parseAfadDateToEpochMs(dateStr: String): Long {
            if (dateStr.isBlank()) return System.currentTimeMillis()
            return try {
                val clean = dateStr.trim()
                if (clean.contains('.')) {
                    // "21.03.2024 13:00:24" veya "2024.03.21 13:00:24"
                    val parts = clean.split(' ')
                    val dateParts = parts[0].split('.')
                    val timeParts = parts.getOrElse(1) { "00:00:00" }.split(':')
                    val (y, m, d) = if (dateParts[0].length == 4) {
                        Triple(dateParts[0].toInt(), dateParts[1].toInt(), dateParts[2].toInt())
                    } else {
                        Triple(dateParts[2].toInt(), dateParts[1].toInt(), dateParts[0].toInt())
                    }
                    val h = timeParts.getOrElse(0) { "0" }.toInt()
                    val mi = timeParts.getOrElse(1) { "0" }.toInt()
                    val s = timeParts.getOrElse(2) { "0" }.toInt()
                    val isoStr = "$y-${m.toString().padStart(2, '0')}-${d.toString().padStart(2, '0')}T${h.toString().padStart(2, '0')}:${mi.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}Z"
                    Instant.parse(isoStr).toEpochMilliseconds()
                } else if (clean.contains('-') && clean.contains(' ') && !clean.contains('T')) {
                    // "2026-09-02 17:43:34"
                    val isoStr = clean.replace(' ', 'T') + "Z"
                    Instant.parse(isoStr).toEpochMilliseconds()
                } else {
                    Instant.parse(clean).toEpochMilliseconds()
                }
            } catch (_: Exception) {
                System.currentTimeMillis()
            }
        }

        /**
         * İki koordinat arası mesafeyi metre cinsinden hesaplar (Haversine formülü)
         */
        fun haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double): Double {
            val r = 6371000.0 // Dünya yarıçapı (metre)
            val dLat = (lat2 - lat1) * (PI / 180.0)
            val dLon = (lon2 - lon1) * (PI / 180.0)
            val a = sin(dLat / 2).pow(2) +
                    cos(lat1 * (PI / 180.0)) * cos(lat2 * (PI / 180.0)) *
                    sin(dLon / 2).pow(2)
            val c = 2 * atan2(sqrt(a), sqrt(1 - a))
            return r * c
        }

        /**
         * Depremleri belirli bir yarıçap içinde filtreler
         */
        fun filterWithinRadius(
            earthquakes: List<Earthquake>,
            centerLat: Double,
            centerLng: Double,
            radiusKm: Double = 100.0
        ): List<Earthquake> {
            return earthquakes.filter { eq ->
                val dist = haversineDistance(centerLat, centerLng, eq.latitude, eq.longitude)
                eq.distance = dist
                dist <= radiusKm * 1000
            }
        }

        private object System {
            fun currentTimeMillis(): Long = kotlinx.datetime.Clock.System.now().toEpochMilliseconds()
        }
    }
}
