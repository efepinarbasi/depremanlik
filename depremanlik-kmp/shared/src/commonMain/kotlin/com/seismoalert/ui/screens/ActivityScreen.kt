package com.seismoalert.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.seismoalert.models.Earthquake
import com.seismoalert.models.News
import com.seismoalert.ui.components.*
import com.seismoalert.ui.theme.*

enum class DataType { LIVE, HISTORY, NEWS }

@Composable
fun ActivityScreen(
    earthquakes: List<Earthquake>,
    newsList: List<News>,
    isLoading: Boolean,
    currentDataType: DataType,
    notificationRadius: Float = 100f,
    onDataTypeChanged: (DataType) -> Unit,
    onEarthquakeClick: (Earthquake) -> Unit,
    onNewsClick: (News) -> Unit,
    modifier: Modifier = Modifier
) {
    val isAreaSafe = earthquakes.none { it.distanceKm <= notificationRadius && it.mag >= 4.0 }

    Column(modifier = modifier.fillMaxSize()) {
        // Durum Banner
        StatusBanner(
            isAreaSafe = isAreaSafe,
            safeTitle = "Bölge Güvenli",
            safeDescription = "Çevrenizde (${notificationRadius.toInt()} km) önemli bir sismik aktivite algılanmadı.",
            alertTitle = "Sismik Uyarı",
            alertDescription = "Yakınınızda (${notificationRadius.toInt()} km) önemli sismik aktivite algılandı!"
        )

        // Filtre Chip'leri
        FilterChipRow(
            items = listOf(
                "Canlı" to DataType.LIVE.ordinal,
                "Geçmiş" to DataType.HISTORY.ordinal,
                "Haberler" to DataType.NEWS.ordinal
            ),
            selectedIndex = currentDataType.ordinal,
            onSelected = { index ->
                onDataTypeChanged(DataType.entries[index])
            }
        )

        Spacer(Modifier.height(16.dp))

        // İçerik Listesi
        if (isLoading) {
            Box(
                modifier = Modifier.fillMaxSize(),
                contentAlignment = Alignment.Center
            ) {
                CircularProgressIndicator(color = PrimaryContainer)
            }
        } else {
            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(bottom = 16.dp)
            ) {
                if (currentDataType == DataType.NEWS) {
                    if (newsList.isEmpty()) {
                        item {
                            Box(
                                modifier = Modifier.fillMaxWidth().padding(32.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                Text("Veri bulunamadı.", color = OnSurfaceVariant)
                            }
                        }
                    } else {
                        itemsIndexed(newsList) { _, news ->
                            NewsCard(
                                news = news,
                                onClick = { onNewsClick(news) }
                            )
                        }
                    }
                } else {
                    if (earthquakes.isEmpty()) {
                        item {
                            Box(
                                modifier = Modifier.fillMaxWidth().padding(32.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                Text("Veri bulunamadı.", color = OnSurfaceVariant)
                            }
                        }
                    } else {
                        itemsIndexed(earthquakes) { _, earthquake ->
                            EarthquakeCard(
                                earthquake = earthquake,
                                onClick = { onEarthquakeClick(earthquake) }
                            )
                        }
                    }
                }
            }
        }
    }
}
