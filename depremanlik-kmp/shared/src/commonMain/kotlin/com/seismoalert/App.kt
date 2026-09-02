package com.seismoalert

import androidx.compose.animation.*
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.seismoalert.data.*
import com.seismoalert.models.*
import com.seismoalert.platform.*
import com.seismoalert.ui.screens.*
import com.seismoalert.ui.theme.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun App() {
    val settingsRepo = remember { SettingsRepository() }
    val httpClient = remember { createHttpClient() }
    val service = remember { EarthquakeService(httpClient) }
    val scope = rememberCoroutineScope()

    // ─── State ───
    var selectedTab by remember { mutableIntStateOf(1) } // Aktivite varsayılan
    var earthquakes by remember { mutableStateOf<List<Earthquake>>(emptyList()) }
    var newsList by remember { mutableStateOf<List<News>>(emptyList()) }
    var isLoading by remember { mutableStateOf(true) }
    var currentDataType by remember { mutableStateOf(DataType.LIVE) }
    var centerLat by remember { mutableDoubleStateOf(DefaultLocation.LAT) }
    var centerLng by remember { mutableDoubleStateOf(DefaultLocation.LNG) }

    // Settings state
    var minMagnitude by remember { mutableFloatStateOf(settingsRepo.minMagnitude.toFloat()) }
    var notificationRadius by remember { mutableFloatStateOf(settingsRepo.notificationRadius.toFloat()) }
    var soundEnabled by remember { mutableStateOf(settingsRepo.soundEnabled) }
    var contacts by remember {
        mutableStateOf(List(3) { settingsRepo.getContact(it) })
    }
    var savedLocations by remember { mutableStateOf(settingsRepo.getSavedLocations()) }
    var currentLanguage by remember { mutableStateOf(settingsRepo.language) }

    // Guide state
    var simulatorMagnitude by remember { mutableFloatStateOf(6.0f) }
    var isSirenActive by remember { mutableStateOf(false) }
    var kitItems by remember {
        val checked = settingsRepo.getKitCheckedItems()
        val initial = (1..20).associate { "kit$it" to checked.contains("kit$it") }
        mutableStateOf(initial)
    }

    // ─── Data fetch ───
    fun fetchData() {
        scope.launch {
            isLoading = true
            try {
                when (currentDataType) {
                    DataType.LIVE -> {
                        println("SeismoAlert: Canlı depremler çekiliyor...")
                        val data = try {
                            val afadList = service.fetchAfadEarthquakes(limit = 100)
                            if (afadList.isNotEmpty()) afadList else service.fetchKandilliEarthquakes(limit = 100)
                        } catch (e: Exception) {
                            println("SeismoAlert: AFAD hatası (${e.message}), Kandilli deneniyor...")
                            try {
                                service.fetchKandilliEarthquakes(limit = 100)
                            } catch (e2: Exception) {
                                println("SeismoAlert: Kandilli de başarısız: ${e2.message}")
                                emptyList()
                            }
                        }
                        println("SeismoAlert: Toplam ${data.size} canlı deprem alındı")

                        data.forEach { eq ->
                            eq.distance = Earthquake.haversineDistance(centerLat, centerLng, eq.latitude, eq.longitude)
                        }

                        val filtered = if (minMagnitude > 0f) data.filter { it.mag >= minMagnitude } else data
                        earthquakes = (if (filtered.isNotEmpty()) filtered else data).sortedByDescending { it.dateEpochMs }
                        println("SeismoAlert: Ekranda listelenen deprem sayısı: ${earthquakes.size}")
                    }
                    DataType.HISTORY -> {
                        println("SeismoAlert: Geçmiş depremler çekiliyor...")
                        val data = try {
                            service.fetchUSGSHistoryEarthquakes(centerLat, centerLng, 1000.0)
                        } catch (e: Exception) {
                            println("SeismoAlert: USGS geçmiş hata: ${e.message}")
                            emptyList()
                        }
                        data.forEach { eq ->
                            eq.distance = Earthquake.haversineDistance(centerLat, centerLng, eq.latitude, eq.longitude)
                        }
                        val filtered = if (minMagnitude > 0f) data.filter { it.mag >= minMagnitude } else data
                        earthquakes = (if (filtered.isNotEmpty()) filtered else data).sortedByDescending { it.dateEpochMs }
                    }
                    DataType.NEWS -> {
                        println("SeismoAlert: Haberler çekiliyor...")
                        newsList = try {
                            service.fetchEarthquakeNews()
                        } catch (e: Exception) {
                            println("SeismoAlert: Haberler çekilirken hata: ${e.message}")
                            emptyList()
                        }
                    }
                }
            } catch (e: Exception) {
                println("SeismoAlert: Veri çekme genel hata: ${e.message}")
                e.printStackTrace()
            } finally {
                isLoading = false
            }
        }
    }

    // İlk yükleme
    LaunchedEffect(Unit) {
        try {
            val locationProvider = LocationProvider()
            val loc = locationProvider.getCurrentLocation()
            centerLat = loc.first
            centerLng = loc.second
            println("SeismoAlert: Konum alındı -> Lat: $centerLat, Lng: $centerLng")
        } catch (_: Exception) { }
        fetchData()
    }

    // Veri tipi değiştiğinde yeniden yükle
    LaunchedEffect(currentDataType) {
        fetchData()
    }

    // Otomatik yenileme (60 saniye)
    LaunchedEffect(currentDataType) {
        while (true) {
            delay(60_000)
            if (currentDataType == DataType.LIVE) fetchData()
        }
    }

    SeismoAlertTheme(darkTheme = true) {
        Scaffold(
            topBar = {
                if (selectedTab != 0) { // Harita sekmesinde AppBar yok
                    TopAppBar(
                        title = {
                            Text(
                                "SeismoAlert",
                                fontWeight = FontWeight.Black,
                                letterSpacing = (-0.5).sp
                            )
                        },
                        colors = TopAppBarDefaults.topAppBarColors(
                            containerColor = BgColor,
                            titleContentColor = OnSurface
                        ),
                        actions = {
                            if (isLoading) {
                                CircularProgressIndicator(
                                    modifier = Modifier.padding(16.dp).size(20.dp),
                                    strokeWidth = 2.dp,
                                    color = PrimaryContainer
                                )
                            }
                            IconButton(onClick = { fetchData() }) {
                                Icon(Icons.Filled.Refresh, contentDescription = "Yenile", tint = OnSurfaceVariant)
                            }
                        }
                    )
                }
            },
            bottomBar = {
                NavigationBar(
                    containerColor = BgColor.copy(alpha = 0.95f)
                ) {
                    NavigationBarItem(
                        selected = selectedTab == 0,
                        onClick = { selectedTab = 0 },
                        icon = { Icon(if (selectedTab == 0) Icons.Filled.Map else Icons.Outlined.Map, contentDescription = null) },
                        label = { Text("Harita", fontSize = 12.sp) },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = PrimaryContainer,
                            selectedTextColor = Primary,
                            unselectedIconColor = OnSurfaceVariant.copy(alpha = 0.5f),
                            unselectedTextColor = OnSurfaceVariant.copy(alpha = 0.6f),
                            indicatorColor = PrimaryContainer.copy(alpha = 0.2f)
                        )
                    )
                    NavigationBarItem(
                        selected = selectedTab == 1,
                        onClick = { selectedTab = 1 },
                        icon = { Icon(if (selectedTab == 1) Icons.Filled.ListAlt else Icons.Outlined.ListAlt, contentDescription = null) },
                        label = { Text("Aktivite", fontSize = 12.sp) },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = PrimaryContainer,
                            selectedTextColor = Primary,
                            unselectedIconColor = OnSurfaceVariant.copy(alpha = 0.5f),
                            unselectedTextColor = OnSurfaceVariant.copy(alpha = 0.6f),
                            indicatorColor = PrimaryContainer.copy(alpha = 0.2f)
                        )
                    )
                    NavigationBarItem(
                        selected = selectedTab == 2,
                        onClick = { selectedTab = 2 },
                        icon = { Icon(if (selectedTab == 2) Icons.Filled.MenuBook else Icons.Outlined.MenuBook, contentDescription = null) },
                        label = { Text("Rehber", fontSize = 12.sp) },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = PrimaryContainer,
                            selectedTextColor = Primary,
                            unselectedIconColor = OnSurfaceVariant.copy(alpha = 0.5f),
                            unselectedTextColor = OnSurfaceVariant.copy(alpha = 0.6f),
                            indicatorColor = PrimaryContainer.copy(alpha = 0.2f)
                        )
                    )
                    NavigationBarItem(
                        selected = selectedTab == 3,
                        onClick = { selectedTab = 3 },
                        icon = { Icon(if (selectedTab == 3) Icons.Filled.Settings else Icons.Outlined.Settings, contentDescription = null) },
                        label = { Text("Ayarlar", fontSize = 12.sp) },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = PrimaryContainer,
                            selectedTextColor = Primary,
                            unselectedIconColor = OnSurfaceVariant.copy(alpha = 0.5f),
                            unselectedTextColor = OnSurfaceVariant.copy(alpha = 0.6f),
                            indicatorColor = PrimaryContainer.copy(alpha = 0.2f)
                        )
                    )
                }
            },
            containerColor = BgColor
        ) { innerPadding ->
            AnimatedContent(
                targetState = selectedTab,
                modifier = Modifier.padding(innerPadding),
                transitionSpec = {
                    fadeIn() + slideInVertically { it / 20 } togetherWith fadeOut()
                }
            ) { tab ->
                when (tab) {
                    0 -> MapScreen(
                        earthquakes = earthquakes,
                        centerLat = centerLat,
                        centerLng = centerLng,
                        radiusKm = notificationRadius.toDouble(),
                        currentDataType = currentDataType,
                        onDataTypeChanged = { currentDataType = it; fetchData() },
                        onEarthquakeClick = { /* Detay modal */ },
                        onLocationSearch = { query ->
                            scope.launch {
                                isLoading = true
                                val loc = service.searchLocation(query)
                                if (loc != null) {
                                    centerLat = loc.first
                                    centerLng = loc.second
                                    fetchData()
                                }
                                isLoading = false
                            }
                        }
                    )
                    1 -> ActivityScreen(
                        earthquakes = earthquakes,
                        newsList = newsList,
                        isLoading = isLoading,
                        currentDataType = currentDataType,
                        notificationRadius = notificationRadius,
                        onDataTypeChanged = { currentDataType = it; fetchData() },
                        onEarthquakeClick = { /* Detay modal */ },
                        onNewsClick = { news -> openUrl(news.link) }
                    )
                    2 -> GuideScreen(
                        kitItems = kitItems,
                        onKitItemToggle = { key, value ->
                            kitItems = kitItems.toMutableMap().apply { put(key, value) }
                            settingsRepo.setKitCheckedItems(kitItems.filter { it.value }.keys)
                        },
                        simulatorMagnitude = simulatorMagnitude,
                        onSimulatorMagnitudeChange = { simulatorMagnitude = it },
                        isSirenActive = isSirenActive,
                        onToggleSiren = {
                            isSirenActive = !isSirenActive
                            if (isSirenActive) {
                                playAlarmSound()
                                vibrate()
                            } else {
                                stopAlarmSound()
                            }
                        },
                        onSendSafe = {
                            val emergencyContacts = settingsRepo.getEmergencyContacts()
                            if (emergencyContacts.isNotEmpty()) {
                                val msg = "Güvendeyim! Son Konum: https://maps.google.com/?q=$centerLat,$centerLng"
                                sendSms(emergencyContacts, msg)
                            }
                        }
                    )
                    3 -> SettingsScreen(
                        minMagnitude = minMagnitude,
                        notificationRadius = notificationRadius,
                        soundEnabled = soundEnabled,
                        contacts = contacts,
                        savedLocations = savedLocations,
                        currentLanguage = currentLanguage,
                        onMinMagnitudeChange = {
                            minMagnitude = it
                            settingsRepo.minMagnitude = it.toDouble()
                            fetchData()
                        },
                        onRadiusChange = {
                            notificationRadius = it
                            settingsRepo.notificationRadius = it.toDouble()
                            fetchData()
                        },
                        onSoundEnabledChange = {
                            soundEnabled = it
                            settingsRepo.soundEnabled = it
                        },
                        onContactChange = { idx, value ->
                            contacts = contacts.toMutableList().apply { set(idx, value) }
                            settingsRepo.setContact(idx, value)
                        },
                        onAddLocation = { address ->
                            val loc = SavedLocation(
                                id = kotlinx.datetime.Clock.System.now().toEpochMilliseconds().toString(),
                                name = address,
                                latitude = centerLat,
                                longitude = centerLng
                            )
                            settingsRepo.saveLocation(loc)
                            savedLocations = settingsRepo.getSavedLocations()
                        },
                        onDeleteLocation = { name ->
                            settingsRepo.deleteLocation(name)
                            savedLocations = settingsRepo.getSavedLocations()
                        },
                        onLanguageChange = { code ->
                            currentLanguage = code
                            settingsRepo.language = code
                        }
                    )
                }
            }
        }
    }
}
