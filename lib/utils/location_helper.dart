import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../models/earthquake.dart';
import '../models/saved_location.dart';

class LocationHelper {
  // Varsayılan Koordinatlar (Konum izni verilmezse Ümraniye/İstanbul)
  static const double defaultLat = 41.0256;
  static const double defaultLng = 29.1147;
  
  static final Distance _distance = const Distance();

  // Kullanıcının anlık cihaz GPS konumunu alır
  static Future<LatLng> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Konum servisleri açık mı?
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LatLng(defaultLat, defaultLng);
    }

    // İzin kontrolleri
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return const LatLng(defaultLat, defaultLng);
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return const LatLng(defaultLat, defaultLng);
    } 

    // Konumu al (Yüksek hassasiyet) 5 saniye zaman aşımı ile (Emülatör donmasını önler)
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException("Konum bulma zaman aşımına uğradı");
      });
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      return const LatLng(defaultLat, defaultLng);
    }
  }

  // Verilen lokasyona göre radiusKm çapındaki depremleri filtreler
  static List<Earthquake> filterEarthquakesWithinRadius(List<Earthquake> earthquakes, LatLng targetLatLng, {double radiusKm = 100.0}) {
    List<Earthquake> filtered = [];
    for (var eq in earthquakes) {
      final eqLatLng = LatLng(eq.latitude, eq.longitude);
      // Uzaklığı metre cinsinden hesapla
      final double distanceInMeters = _distance.as(LengthUnit.Meter, targetLatLng, eqLatLng);
      final double distanceInKm = distanceInMeters / 1000.0;
      
      if (distanceInKm <= radiusKm) {
        eq.distance = distanceInMeters; // Metre olarak modele kaydet
        filtered.add(eq);
      }
    }
    return filtered;
  }

  // --- ÖZEL KONUM VE ADRES SİSTEMİ (SHARED PREF & GEOCODING) --- //

  // Girilen şehir veya adres metnini koordinata çevirir
  static Future<LatLng?> geocodeAddress(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query).timeout(const Duration(seconds: 4));
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      print("Geocoding hatası: \$e");
    }
    return null;
  }

  // Cihaz hafızasından kayıtlı konumları getirir
  static Future<List<SavedLocation>> getSavedLocations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> locationsJson = prefs.getStringList('saved_locations') ?? [];
      
      if (locationsJson.isEmpty) {
        return [];
      }
      
      return locationsJson.map((jsonStr) => SavedLocation.fromJson(jsonStr)).toList();
    } catch (e) {
      print("Konumları okurken hata: \$e");
      return [];
    }
  }

  // Yeni konum kaydeder
  static Future<bool> saveLocation(SavedLocation location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<SavedLocation> locations = await getSavedLocations();
      
      // Aynı ID veya ada sahip varsa engelle veya güncelle
      final existingIndex = locations.indexWhere((l) => l.name == location.name);
      if (existingIndex >= 0) {
        locations[existingIndex] = location;
      } else {
        locations.add(location);
      }

      final List<String> jsonList = locations.map((l) => l.toJson()).toList();
      return await prefs.setStringList('saved_locations', jsonList);
    } catch (e) {
      print("Konum kaydederken hata: \$e");
      return false;
    }
  }

  // Kayıtlı bir konumu siler
  static Future<bool> deleteLocation(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<SavedLocation> locations = await getSavedLocations();
      
      locations.removeWhere((l) => l.name == name);
      
      final List<String> jsonList = locations.map((l) => l.toJson()).toList();
      return await prefs.setStringList('saved_locations', jsonList);
    } catch (e) {
      return false;
    }
  }
}
