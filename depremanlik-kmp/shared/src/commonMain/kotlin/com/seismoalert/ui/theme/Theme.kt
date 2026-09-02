package com.seismoalert.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.*
import androidx.compose.runtime.Composable

private val DarkColorScheme = darkColorScheme(
    primary = Primary,
    onPrimary = BgColor,
    primaryContainer = PrimaryContainer,
    onPrimaryContainer = OnSurface,
    secondary = Secondary,
    secondaryContainer = SecondaryContainer,
    tertiary = Tertiary,
    background = BgColor,
    surface = SurfaceColor,
    surfaceVariant = SurfaceHigh,
    surfaceContainerHighest = SurfaceHighest,
    onSurface = OnSurface,
    onSurfaceVariant = OnSurfaceVariant,
    error = ErrorColor,
    outline = Outline,
    outlineVariant = OutlineVariant,
)

private val LightColorScheme = lightColorScheme(
    primary = PrimaryContainer,
    onPrimary = LightSurface,
    primaryContainer = PrimaryContainer,
    onPrimaryContainer = LightOnSurface,
    secondary = SecondaryContainer,
    secondaryContainer = SecondaryContainer,
    tertiary = Tertiary,
    background = LightBg,
    surface = LightSurface,
    surfaceVariant = LightBg,
    onSurface = LightOnSurface,
    onSurfaceVariant = LightOnSurfaceVariant,
    error = ErrorColor,
    outline = Outline,
    outlineVariant = OutlineVariant,
)

@Composable
fun SeismoAlertTheme(
    darkTheme: Boolean = true,
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography(),
        content = content
    )
}

/**
 * Büyüklüğe göre renk döndürür
 */
fun getMagnitudeColor(mag: Double): androidx.compose.ui.graphics.Color {
    return when {
        mag < 4.0 -> Tertiary          // Yeşil
        mag < 5.0 -> SecondaryContainer // Turuncu
        else -> PrimaryContainer       // Kırmızı
    }
}
