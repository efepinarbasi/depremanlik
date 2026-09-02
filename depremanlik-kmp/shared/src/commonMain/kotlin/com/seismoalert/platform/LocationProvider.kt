package com.seismoalert.platform

/**
 * Platform-specific konum sağlayıcı.
 * Android'de FusedLocationProvider, iOS'ta CLLocationManager kullanır.
 */
expect class LocationProvider() {
    /**
     * Kullanıcının mevcut GPS konumunu alır.
     * İzin reddedilirse veya konum alınamazsa varsayılan koordinatları döner.
     * @return Pair(latitude, longitude)
     */
    suspend fun getCurrentLocation(): Pair<Double, Double>
}

object DefaultLocation {
    // Varsayılan: Ümraniye/İstanbul
    const val LAT = 41.0256
    const val LNG = 29.1147
}
