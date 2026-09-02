package com.seismoalert.ui.screens

import androidx.compose.animation.*
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.seismoalert.models.Earthquake
import com.seismoalert.ui.components.EarthquakeCard
import com.seismoalert.ui.components.EarthquakeMapView
import com.seismoalert.ui.theme.*
import kotlinx.coroutines.launch

@Composable
fun MapScreen(
    earthquakes: List<Earthquake>,
    centerLat: Double,
    centerLng: Double,
    radiusKm: Double,
    currentDataType: DataType,
    onDataTypeChanged: (DataType) -> Unit,
    onEarthquakeClick: (Earthquake) -> Unit,
    onLocationSearch: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    var isMapExpanded by remember { mutableStateOf(false) }
    var searchQuery by remember { mutableStateOf("") }
    val focusManager = LocalFocusManager.current

    Column(
        modifier = modifier.fillMaxSize().background(BgColor)
    ) {
        // Harita Görünümü Kartı
        // Performans: Google Maps gibi ağır TextureView/SurfaceView bileşenlerine animateContentSize eklemek
        // ciddi kasmalara yol açar. Yalnızca AnimatedVisibility'ye boyut kontrolü bırakıldı.
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .weight(1f)
                .padding(horizontal = 12.dp, vertical = 8.dp),
            shape = RoundedCornerShape(20.dp),
            colors = CardDefaults.cardColors(containerColor = SurfaceHigh),
            elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
        ) {
            Box(modifier = Modifier.fillMaxSize()) {
                // Google Maps
                EarthquakeMapView(
                    earthquakes = earthquakes,
                    centerLat = centerLat,
                    centerLng = centerLng,
                    radiusKm = radiusKm,
                    onEarthquakeClick = onEarthquakeClick,
                    modifier = Modifier.fillMaxSize().clip(RoundedCornerShape(20.dp))
                )

                // Üst Bar: Arama Kutusu ve Filtreler
                Column(
                    modifier = Modifier.fillMaxWidth().padding(12.dp)
                ) {
                    // Arama Çubuğu
                    OutlinedTextField(
                        value = searchQuery,
                        onValueChange = { searchQuery = it },
                        modifier = Modifier
                            .fillMaxWidth()
                            .background(BgColor.copy(alpha = 0.9f), RoundedCornerShape(24.dp)),
                        placeholder = { Text("Konum Ara (Örn: İzmir)", color = OnSurfaceVariant, fontSize = 14.sp) },
                        leadingIcon = { Icon(Icons.Filled.Search, contentDescription = "Ara", tint = OnSurfaceVariant) },
                        trailingIcon = {
                            if (searchQuery.isNotEmpty()) {
                                IconButton(onClick = { searchQuery = "" }) {
                                    Icon(Icons.Filled.Close, contentDescription = "Temizle", tint = OnSurfaceVariant)
                                }
                            }
                        },
                        singleLine = true,
                        shape = RoundedCornerShape(24.dp),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = Primary,
                            unfocusedBorderColor = Color.Transparent,
                            focusedTextColor = OnSurface,
                            unfocusedTextColor = OnSurface
                        ),
                        keyboardOptions = KeyboardOptions(imeAction = ImeAction.Search),
                        keyboardActions = KeyboardActions(
                            onSearch = {
                                if (searchQuery.isNotBlank()) {
                                    onLocationSearch(searchQuery)
                                    focusManager.clearFocus()
                                }
                            }
                        )
                    )

                    Spacer(modifier = Modifier.height(8.dp))

                    // Harita üstü filtre çipleri
                    Row(
                        modifier = Modifier
                            .background(BgColor.copy(alpha = 0.85f), RoundedCornerShape(24.dp))
                            .padding(horizontal = 6.dp, vertical = 4.dp),
                        horizontalArrangement = Arrangement.spacedBy(6.dp)
                    ) {
                        FilterChipButton("Canlı", currentDataType == DataType.LIVE) { onDataTypeChanged(DataType.LIVE) }
                        FilterChipButton("Geçmiş", currentDataType == DataType.HISTORY) { onDataTypeChanged(DataType.HISTORY) }
                    }
                }

                // Alt Sol Köşe Menüsü: Büyütme Butonu ve Deprem İstatistiği
                Row(
                    modifier = Modifier
                        .align(Alignment.BottomStart)
                        .padding(12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    // Harita büyütme/küçültme butonu
                    IconButton(
                        onClick = { isMapExpanded = !isMapExpanded },
                        modifier = Modifier
                            .background(BgColor.copy(alpha = 0.85f), CircleShape)
                            .size(48.dp)
                    ) {
                        Icon(
                            imageVector = if (isMapExpanded) Icons.Filled.FullscreenExit else Icons.Filled.Fullscreen,
                            contentDescription = if (isMapExpanded) "Küçült" else "Büyüt",
                            tint = OnSurface
                        )
                    }

                    Spacer(modifier = Modifier.width(12.dp))

                    // Harita alt bilgi rozeti (Deprem sayısı & yarıçap)
                    Surface(
                        shape = RoundedCornerShape(12.dp),
                        color = BgColor.copy(alpha = 0.85f),
                        contentColor = OnSurface
                    ) {
                        Text(
                            text = "${earthquakes.size} Deprem • ${radiusKm.toInt()} km",
                            modifier = Modifier.padding(horizontal = 14.dp, vertical = 13.dp), // Yüksekliği butonla uyumlu yapmak için dikey padding
                            fontSize = 13.sp,
                            fontWeight = FontWeight.Medium
                        )
                    }
                }
            }
        }

        // Alt Liste Kısmı, "isMapExpanded" durumuna bağlı olarak gizlenip görünür
        AnimatedVisibility(
            visible = !isMapExpanded,
            enter = expandVertically() + fadeIn(),
            exit = shrinkVertically() + fadeOut()
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .fillMaxHeight(0.5f) // Ekranın %50'sini kaplar
            ) {
                // Yakındaki depremler başlığı
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp, vertical = 6.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Deprem Listesi",
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold,
                        color = OnSurface
                    )
                    Text(
                        text = "Toplam: ${earthquakes.size}",
                        fontSize = 13.sp,
                        color = OnSurfaceVariant
                    )
                }

                // Alt Deprem Listesi
                Box(
                    modifier = Modifier.fillMaxSize()
                ) {
                    if (earthquakes.isEmpty()) {
                        Box(
                            modifier = Modifier.fillMaxSize(),
                            contentAlignment = Alignment.Center
                        ) {
                            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                Icon(Icons.Filled.CheckCircle, contentDescription = null, tint = Tertiary, modifier = Modifier.size(44.dp))
                                Spacer(Modifier.height(8.dp))
                                Text("Deprem bulunamadı", color = OnSurfaceVariant, textAlign = TextAlign.Center)
                            }
                        }
                    } else {
                        androidx.compose.foundation.lazy.LazyColumn(
                            contentPadding = PaddingValues(bottom = 16.dp)
                        ) {
                            // Performans optimizasyonu: Her eleman için benzersiz ID atayarak gereksiz baştan çizmeleri (recomposition) engelliyoruz
                            items(
                                count = earthquakes.size,
                                key = { i -> "${earthquakes[i].dateEpochMs}_${earthquakes[i].title}" }
                            ) { index ->
                                val eq = earthquakes[index]
                                EarthquakeCard(
                                    earthquake = eq,
                                    onClick = { onEarthquakeClick(eq) }
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun FilterChipButton(
    label: String,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    Button(
        onClick = onClick,
        shape = RoundedCornerShape(20.dp),
        colors = ButtonDefaults.buttonColors(
            containerColor = if (isSelected) PrimaryContainer else Color.Transparent,
            contentColor = if (isSelected) Color.White else OnSurfaceVariant
        ),
        contentPadding = PaddingValues(horizontal = 14.dp, vertical = 6.dp),
        border = if (!isSelected) BorderStroke(1.dp, Outline.copy(alpha = 0.5f)) else null
    ) {
        Text(label, fontSize = 12.sp, fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal)
    }
}
