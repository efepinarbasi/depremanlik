package com.seismoalert.platform

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import android.location.LocationManager
import androidx.core.content.ContextCompat

actual class LocationProvider actual constructor() {

    private var context: Context? = null

    fun init(ctx: Context) {
        context = ctx
    }

    @SuppressLint("MissingPermission")
    actual suspend fun getCurrentLocation(): Pair<Double, Double> {
        val ctx = context ?: AndroidContext.appContext ?: return Pair(DefaultLocation.LAT, DefaultLocation.LNG)

        // İzin kontrolü
        val fineGranted = ContextCompat.checkSelfPermission(ctx, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
        val coarseGranted = ContextCompat.checkSelfPermission(ctx, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED

        if (!fineGranted && !coarseGranted) {
            return Pair(DefaultLocation.LAT, DefaultLocation.LNG)
        }

        return try {
            val locationManager = ctx.getSystemService(Context.LOCATION_SERVICE) as LocationManager
            val provider = if (locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
                LocationManager.GPS_PROVIDER
            } else if (locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)) {
                LocationManager.NETWORK_PROVIDER
            } else {
                return Pair(DefaultLocation.LAT, DefaultLocation.LNG)
            }

            val lastLocation = locationManager.getLastKnownLocation(provider)
            if (lastLocation != null) {
                Pair(lastLocation.latitude, lastLocation.longitude)
            } else {
                Pair(DefaultLocation.LAT, DefaultLocation.LNG)
            }
        } catch (_: Exception) {
            Pair(DefaultLocation.LAT, DefaultLocation.LNG)
        }
    }
}
