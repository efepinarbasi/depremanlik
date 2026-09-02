package com.seismoalert.ui.screens

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.seismoalert.models.SavedLocation
import com.seismoalert.ui.theme.*

@Composable
fun SettingsScreen(
    minMagnitude: Float,
    notificationRadius: Float,
    soundEnabled: Boolean,
    contacts: List<String>,
    savedLocations: List<SavedLocation>,
    currentLanguage: String,
    onMinMagnitudeChange: (Float) -> Unit,
    onRadiusChange: (Float) -> Unit,
    onSoundEnabledChange: (Boolean) -> Unit,
    onContactChange: (Int, String) -> Unit,
    onAddLocation: (String) -> Unit,
    onDeleteLocation: (String) -> Unit,
    onLanguageChange: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    var addressText by remember { mutableStateOf("") }
    val textColor = OnSurface
    val subColor = OnSurfaceVariant

    LazyColumn(
        modifier = modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        // ─── BÜYÜKLÜK FİLTRESİ ───
        item {
            Text("Bildirim Filtresi", fontSize = 20.sp, fontWeight = FontWeight.Bold, color = textColor)
            Spacer(Modifier.height(8.dp))
            Text("Şu şiddet ve üzeri depremleri göster: ${String.format("%.1f", minMagnitude)}", color = subColor)
            Slider(
                value = minMagnitude,
                onValueChange = onMinMagnitudeChange,
                valueRange = 1f..8f,
                steps = 13,
                colors = SliderDefaults.colors(thumbColor = PrimaryContainer, activeTrackColor = PrimaryContainer, inactiveTrackColor = SurfaceBright)
            )
        }

        // ─── YARIÇAP FİLTRESİ ───
        item {
            Spacer(Modifier.height(16.dp))
            Text("Tarama Yarıçapı", fontSize = 20.sp, fontWeight = FontWeight.Bold, color = textColor)
            Spacer(Modifier.height(8.dp))
            Text("Bana şu mesafedeki depremleri bildir: ${notificationRadius.toInt()} km", color = subColor)
            Slider(
                value = notificationRadius,
                onValueChange = onRadiusChange,
                valueRange = 50f..500f,
                steps = 8,
                colors = SliderDefaults.colors(thumbColor = PrimaryContainer, activeTrackColor = PrimaryContainer, inactiveTrackColor = SurfaceBright)
            )
        }

        // ─── TERCİHLER ───
        item {
            Spacer(Modifier.height(16.dp))
            Text("Tercihler", fontSize = 20.sp, fontWeight = FontWeight.Bold, color = textColor)
            Spacer(Modifier.height(8.dp))
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text("Sesli Bildirimler", color = textColor, fontWeight = FontWeight.SemiBold)
                Switch(
                    checked = soundEnabled,
                    onCheckedChange = onSoundEnabledChange,
                    colors = SwitchDefaults.colors(
                        checkedThumbColor = PrimaryContainer,
                        checkedTrackColor = PrimaryContainer.copy(alpha = 0.4f),
                        uncheckedThumbColor = SurfaceBright,
                        uncheckedTrackColor = SurfaceColor
                    )
                )
            }
        }

        // ─── ACİL DURUM KİŞİLERİ ───
        item {
            Spacer(Modifier.height(16.dp))
            Text("Acil Durum Kişileri", fontSize = 20.sp, fontWeight = FontWeight.Bold, color = textColor)
            Spacer(Modifier.height(4.dp))
            Text("Acil durumda SMS gönderilecek numaralar", color = subColor, fontSize = 13.sp)
            Spacer(Modifier.height(12.dp))
        }
        items(3) { idx ->
            OutlinedTextField(
                value = contacts.getOrElse(idx) { "" },
                onValueChange = { onContactChange(idx, it) },
                modifier = Modifier.fillMaxWidth().padding(bottom = 12.dp),
                label = { Text("Kişi Numarası ${idx + 1}") },
                leadingIcon = { Icon(Icons.Filled.Phone, contentDescription = null, tint = subColor) },
                shape = RoundedCornerShape(12.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = PrimaryContainer,
                    unfocusedBorderColor = Outline.copy(alpha = 0.3f),
                    focusedTextColor = textColor,
                    unfocusedTextColor = textColor,
                    focusedLabelColor = PrimaryContainer,
                    unfocusedLabelColor = subColor,
                    cursorColor = PrimaryContainer
                ),
                singleLine = true
            )
        }

        // ─── KAYITLI ADRESLER ───
        item {
            Spacer(Modifier.height(16.dp))
            Text("Kayıtlı Adresler", fontSize = 20.sp, fontWeight = FontWeight.Bold, color = textColor)
            Spacer(Modifier.height(8.dp))
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                OutlinedTextField(
                    value = addressText,
                    onValueChange = { addressText = it },
                    modifier = Modifier.weight(1f),
                    label = { Text("Adres Takip Et") },
                    leadingIcon = { Icon(Icons.Filled.LocationCity, contentDescription = null, tint = subColor) },
                    shape = RoundedCornerShape(12.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = PrimaryContainer,
                        unfocusedBorderColor = Outline.copy(alpha = 0.3f),
                        focusedTextColor = textColor,
                        unfocusedTextColor = textColor,
                        cursorColor = PrimaryContainer
                    ),
                    singleLine = true
                )
                Spacer(Modifier.width(8.dp))
                IconButton(
                    onClick = {
                        if (addressText.isNotBlank()) {
                            onAddLocation(addressText)
                            addressText = ""
                        }
                    }
                ) {
                    Icon(Icons.Filled.AddCircle, contentDescription = "Ekle", tint = PrimaryContainer, modifier = Modifier.size(44.dp))
                }
            }
        }

        itemsIndexed(savedLocations) { _, loc ->
            Card(
                modifier = Modifier.fillMaxWidth().padding(top = 8.dp),
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(containerColor = SurfaceHigh)
            ) {
                Row(
                    modifier = Modifier.padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(Icons.Filled.Home, contentDescription = null, tint = OnSurface)
                    Spacer(Modifier.width(12.dp))
                    Column(modifier = Modifier.weight(1f)) {
                        Text(loc.name.uppercase(), color = textColor, fontWeight = FontWeight.Bold)
                        Text("${String.format("%.2f", loc.latitude)}, ${String.format("%.2f", loc.longitude)}", color = subColor, fontSize = 12.sp)
                    }
                    IconButton(onClick = { onDeleteLocation(loc.name) }) {
                        Icon(Icons.Filled.Delete, contentDescription = "Sil", tint = PrimaryContainer)
                    }
                }
            }
        }

        // ─── DİL AYARLARI ───
        item {
            Spacer(Modifier.height(24.dp))
            Text("Dil Ayarları", fontSize = 20.sp, fontWeight = FontWeight.Bold, color = textColor)
            Spacer(Modifier.height(16.dp))
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = SurfaceHigh)
            ) {
                Column {
                    LanguageOption("Türkçe", "🇹🇷", "tr", currentLanguage, onLanguageChange)
                    LanguageOption("English", "🇬🇧", "en", currentLanguage, onLanguageChange)
                    LanguageOption("日本語", "🇯🇵", "ja", currentLanguage, onLanguageChange)
                    LanguageOption("Français", "🇫🇷", "fr", currentLanguage, onLanguageChange)
                    LanguageOption("Deutsch", "🇩🇪", "de", currentLanguage, onLanguageChange)
                    LanguageOption("Español", "🇪🇸", "es", currentLanguage, onLanguageChange)
                    LanguageOption("Русский", "🇷🇺", "ru", currentLanguage, onLanguageChange)
                }
            }
        }

        item { Spacer(Modifier.height(32.dp)) }
    }
}

@Composable
private fun LanguageOption(
    name: String,
    flag: String,
    code: String,
    currentCode: String,
    onSelect: (String) -> Unit
) {
    val isSelected = code == currentCode
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onSelect(code) }
            .then(
                if (isSelected) Modifier.padding(0.dp) // Placeholder for background
                else Modifier
            )
            .padding(horizontal = 16.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(flag, fontSize = 24.sp)
        Spacer(Modifier.width(16.dp))
        Text(
            name,
            modifier = Modifier.weight(1f),
            fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
            color = OnSurface,
            fontSize = 16.sp
        )
        if (isSelected) {
            Icon(Icons.Filled.CheckCircle, contentDescription = null, tint = PrimaryContainer)
        }
    }
}
