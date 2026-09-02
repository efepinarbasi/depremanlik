package com.seismoalert.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.seismoalert.ui.theme.*

@Composable
fun GuideScreen(
    kitItems: Map<String, Boolean>,
    onKitItemToggle: (String, Boolean) -> Unit,
    simulatorMagnitude: Float,
    onSimulatorMagnitudeChange: (Float) -> Unit,
    isSirenActive: Boolean,
    onToggleSiren: () -> Unit,
    onSendSafe: () -> Unit,
    modifier: Modifier = Modifier
) {
    LazyColumn(
        modifier = modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // ─── ACİL DURUM ARAÇLARI ───
        item {
            Text(
                "Acil Durum Araçları",
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                color = OnSurface
            )
        }
        item {
            Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                EmergencyButton(
                    icon = Icons.Filled.Sos,
                    label = "Güvendeyim",
                    color = Tertiary.copy(alpha = 0.7f),
                    onClick = onSendSafe,
                    modifier = Modifier.weight(1f)
                )
                EmergencyButton(
                    icon = if (isSirenActive) Icons.Filled.VolumeOff else Icons.Filled.VolumeUp,
                    label = if (isSirenActive) "Siren Kapat" else "Siren Aç",
                    color = if (isSirenActive) SurfaceHigh else PrimaryContainer,
                    onClick = onToggleSiren,
                    modifier = Modifier.weight(1f)
                )
            }
        }

        // ─── HIZLI ERİŞİM ───
        item { Spacer(Modifier.height(16.dp)) }
        item {
            Text(
                "Hızlı Erişim",
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                color = OnSurface
            )
            Text(
                "Acil durum araçlarına hızlıca ulaşın.",
                color = OnSurfaceVariant,
                fontSize = 13.sp
            )
        }
        item {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                QuickToolCard(Icons.Filled.FamilyRestroom, "Aile\nTakibi", Primary, Modifier.weight(1f))
                QuickToolCard(Icons.Filled.Domain, "Bina\nSağlığı", Secondary, Modifier.weight(1f))
                QuickToolCard(Icons.Filled.Map, "Tahliye\nPlanı", Tertiary, Modifier.weight(1f))
            }
        }

        // ─── DEPREM SİMÜLATÖRÜ ───
        item { Spacer(Modifier.height(16.dp)) }
        item {
            Text(
                "Deprem Simülatörü",
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                color = OnSurface
            )
            Text(
                "Sarsıntı şiddetini test edin ve güvenlik protokollerini öğrenin.",
                color = OnSurfaceVariant,
                fontSize = 13.sp
            )
        }
        item {
            SimulatorCard(
                magnitude = simulatorMagnitude,
                onMagnitudeChange = onSimulatorMagnitudeChange
            )
        }

        // ─── ACİL DURUM ÇANTASI ───
        item { Spacer(Modifier.height(16.dp)) }
        item {
            Text(
                "Acil Durum Çantası",
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                color = OnSurface
            )
            Text(
                "Afet sonrası hayatta kalmak için çantanızı hazırlayın.",
                color = OnSurfaceVariant,
                fontSize = 13.sp
            )
        }
        // İlerleme çubuğu
        item {
            val checkedCount = kitItems.values.count { it }
            val totalCount = kitItems.size
            val progress = if (totalCount > 0) checkedCount.toFloat() / totalCount else 0f

            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = SurfaceHigh)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text("$checkedCount / $totalCount Hazır", color = OnSurface, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                        Text("${(progress * 100).toInt()}%", color = Tertiary, fontWeight = FontWeight.Black, fontSize = 16.sp)
                    }
                    Spacer(Modifier.height(12.dp))
                    LinearProgressIndicator(
                        progress = { progress },
                        modifier = Modifier.fillMaxWidth().height(8.dp).clip(RoundedCornerShape(8.dp)),
                        color = Tertiary,
                        trackColor = SurfaceBright
                    )
                }
            }
        }
        // Kit items
        kitItems.forEach { (key, checked) ->
            item(key = key) {
                KitCheckItem(
                    label = getKitItemLabel(key),
                    checked = checked,
                    onCheckedChange = { onKitItemToggle(key, it) }
                )
            }
        }

        // ─── HAYATTA KALMA REHBERİ ───
        item { Spacer(Modifier.height(16.dp)) }
        item {
            Text(
                "Acil Durum Hayatta Kalma Rehberi",
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                color = OnSurface
            )
        }
        item { GuideCard(Icons.Filled.AccessibilityNew, "1. ÇÖK, KAPAN, TUTUN", "Ellerinizin ve dizlerinizin üzerine çökün. Başınızı ve boynunuzu kollarınızla koruyun.") }
        item { GuideCard(Icons.Filled.House, "2. İÇERİDE KALIN", "Deprem sırasında dışarı koşmayın. Yaralanmaların çoğu panikle dışarı çıkmaya çalışırken olur.") }
        item { GuideCard(Icons.Filled.Dangerous, "3. CAMLARDAN UZAK DURUN", "Pencerelerden, camlardan, dış kapı ve duvarlardan uzak durun.") }
        item { GuideCard(Icons.Filled.PanTool, "4. ENKAZ ALTINDAYSANIZ", "Kibrit yakmayın. Ağzınızı kapatın. Kurtarma ekiplerine vurun. Düdük kullanın.") }
        item { Spacer(Modifier.height(32.dp)) }
    }
}

@Composable
private fun EmergencyButton(
    icon: ImageVector,
    label: String,
    color: Color,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier
            .clickable(onClick = onClick)
            .shadow(elevation = 8.dp, shape = RoundedCornerShape(20.dp), ambientColor = color.copy(alpha = 0.4f)),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = color)
    ) {
        Column(
            modifier = Modifier.padding(vertical = 20.dp, horizontal = 8.dp).fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Icon(icon, contentDescription = label, modifier = Modifier.size(48.dp), tint = Color.White)
            Spacer(Modifier.height(8.dp))
            Text(label, textAlign = TextAlign.Center, color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp)
        }
    }
}

@Composable
private fun QuickToolCard(
    icon: ImageVector,
    label: String,
    accentColor: Color,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier.aspectRatio(1f),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = SurfaceHigh),
        border = CardDefaults.outlinedCardBorder().copy(
            brush = androidx.compose.ui.graphics.SolidColor(accentColor.copy(alpha = 0.2f))
        )
    ) {
        Column(
            modifier = Modifier.fillMaxSize(),
            verticalArrangement = Arrangement.Center,
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Box(
                modifier = Modifier
                    .size(44.dp)
                    .background(accentColor.copy(alpha = 0.15f), CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Icon(icon, contentDescription = label, tint = accentColor, modifier = Modifier.size(24.dp))
            }
            Spacer(Modifier.height(8.dp))
            Text(label, textAlign = TextAlign.Center, color = OnSurface, fontWeight = FontWeight.SemiBold, fontSize = 11.sp, lineHeight = 14.sp)
        }
    }
}

@Composable
private fun SimulatorCard(
    magnitude: Float,
    onMagnitudeChange: (Float) -> Unit
) {
    val color = getMagnitudeColor(magnitude.toDouble())
    val label = when {
        magnitude < 3f -> "Mikro"
        magnitude < 4f -> "Hafif"
        magnitude < 5f -> "Orta"
        magnitude < 6f -> "Güçlü"
        magnitude < 7f -> "Çok Güçlü"
        magnitude < 8f -> "Büyük"
        else -> "Devasa"
    }

    Card(
        shape = RoundedCornerShape(24.dp),
        colors = CardDefaults.cardColors(containerColor = SurfaceHigh)
    ) {
        Column(
            modifier = Modifier.padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Box(
                modifier = Modifier
                    .size(100.dp)
                    .clip(CircleShape)
                    .background(color.copy(alpha = 0.15f))
                    .border(3.dp, color, CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    String.format("%.1f", magnitude),
                    color = color,
                    fontWeight = FontWeight.Black,
                    fontSize = 32.sp
                )
            }
            Spacer(Modifier.height(16.dp))
            Text("M ${String.format("%.1f", magnitude)} - $label", color = OnSurface, fontWeight = FontWeight.Bold, fontSize = 18.sp)
            Spacer(Modifier.height(16.dp))
            Slider(
                value = magnitude,
                onValueChange = onMagnitudeChange,
                valueRange = 2f..9f,
                steps = 13,
                colors = SliderDefaults.colors(thumbColor = color, activeTrackColor = color, inactiveTrackColor = SurfaceBright)
            )
            Spacer(Modifier.height(16.dp))
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                ProtocolStep(Icons.Filled.ArrowDownward, "Çök")
                ProtocolStep(Icons.Filled.Shield, "Kapan")
                ProtocolStep(Icons.Filled.BackHand, "Tutun")
            }
        }
    }
}

@Composable
private fun ProtocolStep(icon: ImageVector, label: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Box(
            modifier = Modifier
                .size(48.dp)
                .background(PrimaryContainer.copy(alpha = 0.15f), CircleShape),
            contentAlignment = Alignment.Center
        ) {
            Icon(icon, contentDescription = label, tint = PrimaryContainer, modifier = Modifier.size(28.dp))
        }
        Spacer(Modifier.height(8.dp))
        Text(label, color = OnSurface, fontWeight = FontWeight.Black, fontSize = 12.sp)
    }
}

@Composable
private fun KitCheckItem(
    label: String,
    checked: Boolean,
    onCheckedChange: (Boolean) -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth().padding(bottom = 6.dp),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = SurfaceHigh)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth().clickable { onCheckedChange(!checked) }.padding(horizontal = 16.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Checkbox(
                checked = checked,
                onCheckedChange = onCheckedChange,
                colors = CheckboxDefaults.colors(
                    checkedColor = Tertiary,
                    checkmarkColor = Color.Black,
                    uncheckedColor = SurfaceBright
                )
            )
            Spacer(Modifier.width(8.dp))
            Text(
                text = label,
                color = if (checked) OnSurfaceVariant else OnSurface,
                fontWeight = if (checked) FontWeight.Normal else FontWeight.SemiBold,
                fontSize = 14.sp,
                textDecoration = if (checked) TextDecoration.LineThrough else null
            )
        }
    }
}

@Composable
private fun GuideCard(
    icon: ImageVector,
    title: String,
    description: String
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = SurfaceHigh)
    ) {
        Row(
            modifier = Modifier.padding(16.dp),
            verticalAlignment = Alignment.Top
        ) {
            Icon(icon, contentDescription = title, tint = PrimaryContainer, modifier = Modifier.size(32.dp))
            Spacer(Modifier.width(16.dp))
            Column(modifier = Modifier.weight(1f)) {
                Text(title, fontWeight = FontWeight.Bold, fontSize = 16.sp, color = OnSurface)
                Spacer(Modifier.height(4.dp))
                Text(description, color = OnSurfaceVariant, fontSize = 14.sp)
            }
        }
    }
}

fun getKitItemLabel(key: String): String {
    return when (key) {
        "kit1" -> "Su (kişi başı günlük 4 litre)"
        "kit2" -> "Bozulmayan gıdalar"
        "kit3" -> "Pilli radyo"
        "kit4" -> "El feneri ve yedek piller"
        "kit5" -> "İlk yardım çantası"
        "kit6" -> "Düdük"
        "kit7" -> "Toz maskesi"
        "kit8" -> "Nemli bezler ve çöp torbaları"
        "kit9" -> "İngiliz anahtarı veya pense"
        "kit10" -> "Manuel konserve açacağı"
        "kit11" -> "Yerel haritalar"
        "kit12" -> "Cep telefonu ve yedek şarj cihazı"
        "kit13" -> "Reçeteli ilaçlar"
        "kit14" -> "Gözlük ve lens solüsyonu"
        "kit15" -> "Bebek maması ve bezi"
        "kit16" -> "Evcil hayvan maması ve suyu"
        "kit17" -> "Önemli evrak kopyaları"
        "kit18" -> "Nakit para ve bozuk para"
        "kit19" -> "Uyku tulumu veya battaniye"
        "kit20" -> "Kıyafet ve sağlam ayakkabı"
        else -> key
    }
}
