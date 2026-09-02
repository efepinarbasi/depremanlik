package com.seismoalert.data

import com.russhwolf.settings.Settings
import com.seismoalert.models.SavedLocation
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

class SettingsRepository(private val settings: Settings = Settings()) {

    companion object {
        private const val KEY_MIN_MAGNITUDE = "minMagnitude"
        private const val KEY_NOTIFICATION_RADIUS = "notificationRadius"
        private const val KEY_SOUND_ENABLED = "soundEnabled"
        private const val KEY_DARK_MODE = "isDarkMode"
        private const val KEY_SAVED_LOCATIONS = "saved_locations"
        private const val KEY_LANGUAGE = "language"

        // Emergency contacts
        private const val KEY_CONTACT_0 = "contact0"
        private const val KEY_CONTACT_1 = "contact1"
        private const val KEY_CONTACT_2 = "contact2"

        // Structural Health
        private const val KEY_BINA_YASI = "binaYasi"
        private const val KEY_KAT_SAYISI = "katSayisi"
        private const val KEY_BINA_TIPI = "binaTipi"
        private const val KEY_ZEMIN_TIPI = "zeminTipi"

        // Evacuation Plan
        private const val KEY_EV_CIKISI = "evCikisi"
        private const val KEY_TOPLANMA = "toplanmaNoktasi"
        private const val KEY_ALTERNATIF = "alternatifRota"
        private const val KEY_BULUSMA = "bulusmaNoktasi"

        // Kit items
        private const val KEY_KIT_CHECKED = "kitChecked"
    }

    private val json = Json { ignoreUnknownKeys = true }

    // ─── GENEL AYARLAR ───

    var minMagnitude: Double
        get() = settings.getDouble(KEY_MIN_MAGNITUDE, 0.0)
        set(value) = settings.putDouble(KEY_MIN_MAGNITUDE, value)

    var notificationRadius: Double
        get() = settings.getDouble(KEY_NOTIFICATION_RADIUS, 100.0)
        set(value) = settings.putDouble(KEY_NOTIFICATION_RADIUS, value)

    var soundEnabled: Boolean
        get() = settings.getBoolean(KEY_SOUND_ENABLED, true)
        set(value) = settings.putBoolean(KEY_SOUND_ENABLED, value)

    var isDarkMode: Boolean
        get() = settings.getBoolean(KEY_DARK_MODE, true)
        set(value) = settings.putBoolean(KEY_DARK_MODE, value)

    var language: String
        get() = settings.getString(KEY_LANGUAGE, "tr")
        set(value) = settings.putString(KEY_LANGUAGE, value)

    // ─── ACİL DURUM KİŞİLERİ ───

    fun getContact(index: Int): String {
        val key = when (index) {
            0 -> KEY_CONTACT_0
            1 -> KEY_CONTACT_1
            2 -> KEY_CONTACT_2
            else -> return ""
        }
        return settings.getString(key, "")
    }

    fun setContact(index: Int, value: String) {
        val key = when (index) {
            0 -> KEY_CONTACT_0
            1 -> KEY_CONTACT_1
            2 -> KEY_CONTACT_2
            else -> return
        }
        settings.putString(key, value)
    }

    fun getEmergencyContacts(): List<String> {
        return (0..2).map { getContact(it) }.filter { it.isNotBlank() }
    }

    // ─── YAPI SAĞLIĞI ───

    var binaYasi: String
        get() = settings.getString(KEY_BINA_YASI, "")
        set(value) = settings.putString(KEY_BINA_YASI, value)

    var katSayisi: String
        get() = settings.getString(KEY_KAT_SAYISI, "")
        set(value) = settings.putString(KEY_KAT_SAYISI, value)

    var binaTipi: String
        get() = settings.getString(KEY_BINA_TIPI, "")
        set(value) = settings.putString(KEY_BINA_TIPI, value)

    var zeminTipi: String
        get() = settings.getString(KEY_ZEMIN_TIPI, "")
        set(value) = settings.putString(KEY_ZEMIN_TIPI, value)

    // ─── TAHLİYE PLANI ───

    var evCikisi: String
        get() = settings.getString(KEY_EV_CIKISI, "")
        set(value) = settings.putString(KEY_EV_CIKISI, value)

    var toplanmaNoktasi: String
        get() = settings.getString(KEY_TOPLANMA, "")
        set(value) = settings.putString(KEY_TOPLANMA, value)

    var alternatifRota: String
        get() = settings.getString(KEY_ALTERNATIF, "")
        set(value) = settings.putString(KEY_ALTERNATIF, value)

    var bulusmaNoktasi: String
        get() = settings.getString(KEY_BULUSMA, "")
        set(value) = settings.putString(KEY_BULUSMA, value)

    // ─── KAYITLI KONUMLAR ───

    fun getSavedLocations(): List<SavedLocation> {
        val raw = settings.getString(KEY_SAVED_LOCATIONS, "[]")
        return try {
            json.decodeFromString<List<SavedLocation>>(raw)
        } catch (_: Exception) {
            emptyList()
        }
    }

    fun saveLocation(location: SavedLocation) {
        val locations = getSavedLocations().toMutableList()
        val existingIndex = locations.indexOfFirst { it.name == location.name }
        if (existingIndex >= 0) {
            locations[existingIndex] = location
        } else {
            locations.add(location)
        }
        settings.putString(KEY_SAVED_LOCATIONS, json.encodeToString(locations))
    }

    fun deleteLocation(name: String) {
        val locations = getSavedLocations().toMutableList()
        locations.removeAll { it.name == name }
        settings.putString(KEY_SAVED_LOCATIONS, json.encodeToString(locations))
    }

    // ─── ACİL DURUM ÇANTASI ───

    fun getKitCheckedItems(): Set<String> {
        val raw = settings.getString(KEY_KIT_CHECKED, "")
        return if (raw.isBlank()) emptySet() else raw.split(",").toSet()
    }

    fun setKitCheckedItems(items: Set<String>) {
        settings.putString(KEY_KIT_CHECKED, items.joinToString(","))
    }
}
