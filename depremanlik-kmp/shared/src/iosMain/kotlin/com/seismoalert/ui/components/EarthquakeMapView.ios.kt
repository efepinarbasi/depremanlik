package com.seismoalert.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
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
    Box(
        modifier = modifier.fillMaxSize().background(Color(0xFF1E1E1E)),
        contentAlignment = Alignment.Center
    ) {
        Text("iOS Harita Görünümü", color = Color.White)
    }
}
