package com.seismoalert.platform

actual class LocationProvider actual constructor() {
    actual suspend fun getCurrentLocation(): Pair<Double, Double> {
        // iOS'ta CLLocationManager kullanılacak
        // Şimdilik varsayılan konum döner, macOS build'de implement edilecek
        return Pair(DefaultLocation.LAT, DefaultLocation.LNG)
    }
}
