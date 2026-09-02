package com.seismoalert.data

import io.ktor.client.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.serialization.json.Json

/**
 * Ktor HttpClient factory - platforma göre doğru engine seçilir.
 * commonMain'de engine belirtilmez, androidMain ve iosMain'de
 * engine bağımlılıkları zaten Gradle'da tanımlıdır.
 */
fun createHttpClient(): HttpClient {
    return HttpClient {
        install(ContentNegotiation) {
            json(Json {
                prettyPrint = false
                isLenient = true
                ignoreUnknownKeys = true
            })
        }
        // Ek yapılandırmalar
        expectSuccess = false
    }
}
