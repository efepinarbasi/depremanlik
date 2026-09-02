package com.seismoalert.ui.components

import androidx.compose.animation.*
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.seismoalert.ui.theme.*

@Composable
fun StatusBanner(
    isAreaSafe: Boolean,
    safeTitle: String,
    safeDescription: String,
    alertTitle: String,
    alertDescription: String,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier
            .fillMaxWidth()
            .padding(16.dp)
            .shadow(elevation = 12.dp, shape = RoundedCornerShape(24.dp)),
        shape = RoundedCornerShape(24.dp),
        colors = CardDefaults.cardColors(
            containerColor = if (isAreaSafe) SurfaceHigh else PrimaryContainer.copy(alpha = 0.15f)
        )
    ) {
        Row(
            modifier = Modifier.padding(24.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = if (isAreaSafe) Icons.Filled.CheckCircle else Icons.Filled.Warning,
                contentDescription = null,
                tint = if (isAreaSafe) Tertiary else PrimaryContainer,
                modifier = Modifier.size(40.dp)
            )

            Spacer(Modifier.width(16.dp))

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = if (isAreaSafe) safeTitle else alertTitle,
                    fontSize = 22.sp,
                    fontWeight = FontWeight.Bold,
                    color = OnSurface
                )
                Spacer(Modifier.height(4.dp))
                Text(
                    text = if (isAreaSafe) safeDescription else alertDescription,
                    fontSize = 14.sp,
                    color = OnSurfaceVariant,
                    lineHeight = 20.sp
                )
            }
        }
    }
}

@Composable
fun FilterChipRow(
    items: List<Pair<String, Int>>, // label to enum ordinal
    selectedIndex: Int,
    onSelected: (Int) -> Unit,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier.padding(horizontal = 16.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        items.forEachIndexed { index, (label, _) ->
            val isSelected = selectedIndex == index
            AnimatedContent(targetState = isSelected) {
                Box(
                    modifier = Modifier
                        .clickable { onSelected(index) }
                        .background(
                            color = if (isSelected) PrimaryContainer else androidx.compose.ui.graphics.Color.Transparent,
                            shape = RoundedCornerShape(20.dp)
                        )
                        .then(
                            if (!isSelected) Modifier.background(
                                color = androidx.compose.ui.graphics.Color.Transparent,
                                shape = RoundedCornerShape(20.dp)
                            ) else Modifier
                        )
                        .padding(horizontal = 16.dp, vertical = 8.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = label,
                        color = if (isSelected) androidx.compose.ui.graphics.Color.White else OnSurfaceVariant.copy(alpha = 0.7f),
                        fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                        fontSize = 14.sp
                    )
                }
            }
        }
    }
}
