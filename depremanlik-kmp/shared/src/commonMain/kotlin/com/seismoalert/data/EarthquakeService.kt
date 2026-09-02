package com.seismoalert.data

import com.seismoalert.models.Earthquake
import com.seismoalert.models.News
import io.ktor.client.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import kotlinx.datetime.*
import kotlinx.serialization.json.*

class EarthquakeService(private val client: HttpClient) {

    companion object {
        private const val AFAD_LIVE_URL = "https://api.orhanaydogdu.com.tr/deprem/afad/live"
        private const val KANDILLI_RSS_URL = "http://koeri.boun.edu.tr/rss/"
        private const val USGS_API_URL = "https://earthquake.usgs.gov/fdsnws/event/1/query"
        private const val GOOGLE_NEWS_RSS_URL = "https://news.google.com/rss/search?q=deprem+when:7d&hl=tr&gl=TR&ceid=TR:tr"
    }

    // ─── 1. AFAD CANLI DEPREMLER (JSON) ───

    suspend fun fetchAfadEarthquakes(limit: Int = 100): List<Earthquake> {
        return try {
            val response: HttpResponse = client.get(AFAD_LIVE_URL)
            val body = response.bodyAsText()
            val json = Json.parseToJsonElement(body).jsonObject
            val results = json["result"]?.jsonArray ?: return emptyList()

            results.take(limit).mapNotNull { element ->
                try {
                    val map = jsonElementToMap(element.jsonObject)
                    Earthquake.fromJsonAfad(map)
                } catch (_: Exception) { null }
            }
        } catch (e: Exception) {
            throw Exception("AFAD depremleri çekilirken hata: ${e.message}")
        }
    }

    // ─── 2. KANDİLLİ RSS (XML) ───

    suspend fun fetchKandilliEarthquakes(limit: Int = 200): List<Earthquake> {
        return try {
            val response: HttpResponse = client.get(KANDILLI_RSS_URL)
            val body = response.bodyAsText()
            parseKandilliRss(body, limit)
        } catch (e: Exception) {
            throw Exception("Kandilli depremleri çekilirken hata: ${e.message}")
        }
    }

    private fun parseKandilliRss(xml: String, limit: Int): List<Earthquake> {
        val earthquakes = mutableListOf<Earthquake>()
        // Basit XML parser (Regex tabanlı, bağımlılık gerektirmeyen)
        val itemRegex = Regex("""<item>(.*?)</item>""", RegexOption.DOT_MATCHES_ALL)
        val titleRegex = Regex("""<title>(.*?)</title>""")
        val descRegex = Regex("""<description>(.*?)</description>""", RegexOption.DOT_MATCHES_ALL)
        val linkRegex = Regex("""<link>(.*?)</link>""")

        for (match in itemRegex.findAll(xml)) {
            if (earthquakes.size >= limit) break
            val itemContent = match.groupValues[1]
            try {
                val title = titleRegex.find(itemContent)?.groupValues?.get(1) ?: continue
                val desc = descRegex.find(itemContent)?.groupValues?.get(1) ?: ""
                val link = linkRegex.find(itemContent)?.groupValues?.get(1) ?: ""
                earthquakes.add(Earthquake.fromKandilliXml(title, desc, link))
            } catch (_: Exception) { /* Geçersiz item'ı atla */ }
        }
        return earthquakes
    }

    // ─── 3. USGS GEÇMİŞ DEPREMLER (GeoJSON) ───

    suspend fun fetchUSGSHistoryEarthquakes(
        latitude: Double,
        longitude: Double,
        radiusKm: Double = 100.0
    ): List<Earthquake> {
        return try {
            val now = Clock.System.now()
            val oneYearAgo = now.minus(DateTimePeriod(years = 1), TimeZone.UTC)

            val nowDt = now.toLocalDateTime(TimeZone.UTC)
            val agoDt = oneYearAgo.toLocalDateTime(TimeZone.UTC)

            val startTime = "${agoDt.year}-${agoDt.monthNumber.toString().padStart(2, '0')}-${agoDt.dayOfMonth.toString().padStart(2, '0')}"
            val endTime = "${nowDt.year}-${nowDt.monthNumber.toString().padStart(2, '0')}-${nowDt.dayOfMonth.toString().padStart(2, '0')}"

            val url = "$USGS_API_URL?format=geojson&starttime=$startTime&endtime=$endTime&latitude=$latitude&longitude=$longitude&maxradiuskm=$radiusKm&minmagnitude=1.0"
            val response: HttpResponse = client.get(url)
            val body = response.bodyAsText()
            val json = Json.parseToJsonElement(body).jsonObject
            val features = json["features"]?.jsonArray ?: return emptyList()

            features.mapNotNull { element ->
                try {
                    val map = jsonElementToMap(element.jsonObject)
                    Earthquake.fromJsonUSGS(map)
                } catch (_: Exception) { null }
            }
        } catch (e: Exception) {
            throw Exception("USGS geçmiş depremler çekilirken hata: ${e.message}")
        }
    }

    // ─── 4. DEPREM HABERLERİ (RSS) ───

    suspend fun fetchEarthquakeNews(): List<News> {
        return try {
            val response: HttpResponse = client.get(GOOGLE_NEWS_RSS_URL)
            val body = response.bodyAsText()
            parseNewsRss(body)
        } catch (_: Exception) {
            emptyList()
        }
    }

    private fun parseNewsRss(xml: String): List<News> {
        val newsList = mutableListOf<News>()
        val itemRegex = Regex("""<item>(.*?)</item>""", RegexOption.DOT_MATCHES_ALL)
        val titleRegex = Regex("""<title>(.*?)</title>""")
        val linkRegex = Regex("""<link>(.*?)</link>""")
        val descRegex = Regex("""<description>(.*?)</description>""", RegexOption.DOT_MATCHES_ALL)
        val pubDateRegex = Regex("""<pubDate>(.*?)</pubDate>""")
        val sourceRegex = Regex("""<source[^>]*>(.*?)</source>""")

        for (match in itemRegex.findAll(xml)) {
            val content = match.groupValues[1]
            try {
                val title = titleRegex.find(content)?.groupValues?.get(1) ?: continue
                val link = linkRegex.find(content)?.groupValues?.get(1) ?: ""
                val desc = descRegex.find(content)?.groupValues?.get(1) ?: ""
                val pubDateStr = pubDateRegex.find(content)?.groupValues?.get(1) ?: ""
                val source = sourceRegex.find(content)?.groupValues?.get(1) ?: "Google News"

                val pubDateMs = try {
                    Instant.parse(pubDateStr).toEpochMilliseconds()
                } catch (_: Exception) {
                    Clock.System.now().toEpochMilliseconds()
                }

                newsList.add(News(title, link, desc, pubDateMs, source))
            } catch (_: Exception) { /* Geçersiz haber item'ı atla */ }
        }
        return newsList
    }

    // ─── 5. KONUM ARAMA (Nominatim Geocoding API) ───

    suspend fun searchLocation(query: String): Pair<Double, Double>? {
        return try {
            // Basit url encoding
            val encodedQuery = query.trim().replace(" ", "+")
            val url = "https://nominatim.openstreetmap.org/search?q=$encodedQuery&format=json&limit=1"
            val response: HttpResponse = client.get(url)
            val body = response.bodyAsText()
            val array = Json.parseToJsonElement(body).jsonArray
            if (array.isNotEmpty()) {
                val obj = array[0].jsonObject
                val lat = obj["lat"]?.jsonPrimitive?.content?.toDoubleOrNull()
                val lon = obj["lon"]?.jsonPrimitive?.content?.toDoubleOrNull()
                if (lat != null && lon != null) {
                    return Pair(lat, lon)
                }
            }
            null
        } catch (_: Exception) {
            println("SeismoAlert: Konum arama hatası")
            null
        }
    }

    // ─── YARDIMCI: JsonObject → Map dönüşümü ───

    private fun jsonElementToMap(obj: JsonObject): Map<String, Any?> {
        return obj.entries.associate { (key, value) ->
            key to jsonElementToAny(value)
        }
    }

    private fun jsonElementToAny(element: JsonElement): Any? {
        return when (element) {
            is JsonNull -> null
            is JsonPrimitive -> {
                if (element.isString) element.content
                else element.content.toLongOrNull() ?: element.content.toDoubleOrNull() ?: element.content.toBooleanStrictOrNull() ?: element.content
            }
            is JsonArray -> element.map { jsonElementToAny(it) }
            is JsonObject -> jsonElementToMap(element)
        }
    }
}
