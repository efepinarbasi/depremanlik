package com.seismoalert.ui.components

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.seismoalert.models.Earthquake

@Composable
expect fun EarthquakeMapView(
    earthquakes: List<Earthquake>,
    centerLat: Double,
    centerLng: Double,
    radiusKm: Double,
    onEarthquakeClick: (Earthquake) -> Unit,
    modifier: Modifier = Modifier
)
