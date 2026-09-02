package com.seismoalert.ui.components

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.model.BitmapDescriptor
import com.google.android.gms.maps.model.BitmapDescriptorFactory
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
import com.google.maps.android.compose.*
import com.seismoalert.models.Earthquake

@Composable
actual fun EarthquakeMapView(
    earthquakes: List<Earthquake>,
    centerLat: Double,
    centerLng: Double,
    radiusKm: Double,
    onEarthquakeClick: (Earthquake) -> Unit,
    modifier: Modifier
) {
    val userLocation = remember(centerLat, centerLng) { LatLng(centerLat, centerLng) }

    val cameraPositionState = rememberCameraPositionState {
        position = CameraPosition.fromLatLngZoom(userLocation, 6.5f)
    }

    LaunchedEffect(centerLat, centerLng) {
        cameraPositionState.animate(
            CameraUpdateFactory.newLatLngZoom(userLocation, 6.5f)
        )
    }

    val uiSettings = remember {
        MapUiSettings(
            zoomControlsEnabled = true,
            compassEnabled = true,
            myLocationButtonEnabled = false,
            rotationGesturesEnabled = true,
            scrollGesturesEnabled = true,
            tiltGesturesEnabled = true,
            zoomGesturesEnabled = true
        )
    }

    val mapProperties = remember {
        MapProperties(
            isMyLocationEnabled = false
        )
    }

    var isMapLoaded by remember { mutableStateOf(false) }

    GoogleMap(
        modifier = modifier.fillMaxSize(),
        cameraPositionState = cameraPositionState,
        uiSettings = uiSettings,
        properties = mapProperties,
        onMapLoaded = {
            isMapLoaded = true
        }
    ) {
        // Map tam olarak yüklenmeden BitmapDescriptorFactory çağırmak çökmeye neden (NullPointerException) olur.
        if (isMapLoaded) {
            // Google Maps BitmapDescriptor oluştururken aşırı bellek tüketimini önlemek 
            // ve animasyonlarda kasmayı durdurmak için mapScope içinde cacheliyoruz:
            val azureMarker = remember { BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_AZURE) }
            val redMarker = remember { BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_RED) }
            val orangeMarker = remember { BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_ORANGE) }
            val yellowMarker = remember { BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_YELLOW) }

            // Kullanıcı konumu ve tarama yarıçapı çemberi
            Circle(
                center = userLocation,
                radius = radiusKm * 1000.0,
                fillColor = Color(0x262196F3),
                strokeColor = Color(0x802196F3),
                strokeWidth = 3f
            )

            Marker(
                state = MarkerState(position = userLocation),
                title = "Mevcut Konumunuz",
                snippet = "Tarama yarıçapı: ${radiusKm.toInt()} km",
                icon = azureMarker,
                zIndex = 100f
            )

            // Deprem işaretçileri 
            earthquakes.forEach { eq ->
                val icon = when {
                    eq.mag >= 4.5 -> redMarker
                    eq.mag >= 3.0 -> orangeMarker
                    else -> yellowMarker
                }

                val markerState = remember(eq.latitude, eq.longitude) {
                    MarkerState(position = LatLng(eq.latitude, eq.longitude))
                }

                Marker(
                    state = markerState,
                    title = "M ${eq.mag} • ${eq.title}",
                    snippet = "${eq.formattedDate} • ${eq.depth} km derinlik",
                    icon = icon,
                    onClick = {
                        onEarthquakeClick(eq)
                        false
                    }
                )
            }
        }
    }
}
