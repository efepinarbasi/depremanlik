import 'package:xml/xml.dart';

class Earthquake {
  final String id;
  final String title;
  final DateTime date;
  final double mag;
  final double depth;
  final double latitude;
  final double longitude;
  double distance; // Metre veya km cinsinden aradaki mesafe

  Earthquake({
    required this.id,
    required this.title,
    required this.date,
    required this.mag,
    required this.depth,
    required this.latitude,
    required this.longitude,
    this.distance = 0.0,
  });

  factory Earthquake.fromJsonAfad(Map<String, dynamic> json) {
    double lat = 0.0;
    double lng = 0.0;
    
    if (json['geojson'] != null && json['geojson']['coordinates'] != null) {
      var coords = json['geojson']['coordinates'];
      if (coords is List && coords.length >= 2) {
        lng = _parseDouble(coords[0]);
        lat = _parseDouble(coords[1]);
      }
    } else {
      lat = _parseDouble(json['lat'] ?? json['latitude']);
      lng = _parseDouble(json['lng'] ?? json['longitude']);
    }

    return Earthquake(
      id: json['earthquake_id'] ?? json['id'] ?? '',
      title: json['title'] ?? json['location'] ?? 'Bilinmeyen Konum',
      date: _parseAfadDate(json['date_time'] ?? json['date']),
      mag: _parseDouble(json['mag'] ?? json['magnitude']),
      depth: _parseDouble(json['depth']),
      latitude: lat,
      longitude: lng,
    );
  }

  static DateTime _parseAfadDate(dynamic dateStr) {
    if (dateStr == null) return DateTime.now();
    try {
      // Format: "21.03.2024 13:00:24" veya "2024-03-21T13:00:24"
      if (dateStr.toString().contains('.')) {
        // DD.MM.YYYY HH:MM:SS formatı için basit parse
        final parts = dateStr.toString().split(' ');
        final dateParts = parts[0].split('.');
        final y = int.parse(dateParts[2]);
        final m = int.parse(dateParts[1]);
        final d = int.parse(dateParts[0]);
        final t = parts[1].split(':');
        return DateTime(y, m, d, int.parse(t[0]), int.parse(t[1]), int.parse(t[2]));
      }
      return DateTime.tryParse(dateStr.toString())?.toLocal() ?? DateTime.now();
    } catch (_) {
      return DateTime.now();
    }
  }

  static double _parseDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  // Kandilli API'den gelen veriyi parse eder (ESKİ JSON API - Orhan Aydoğdu)
  factory Earthquake.fromJsonKandilli(Map<String, dynamic> json) {
    List<dynamic> coordinates = json['geojson']['coordinates'] ?? [0.0, 0.0];
    // Kandilli API returns [longitude, latitude]
    double lng = _parseDouble(coordinates[0]);
    double lat = _parseDouble(coordinates[1]);

    return Earthquake(
      id: json['earthquake_id'] ?? json['_id'] ?? '',
      title: json['title'] ?? 'Bilinmeyen Konum',
      date: DateTime.tryParse(json['date'] ?? '')?.toLocal() ?? DateTime.now(),
      mag: _parseDouble(json['mag']),
      depth: _parseDouble(json['depth']),
      latitude: lat,
      longitude: lng,
    );
  }

  // Kandilli'nin orjinal XML (RSS) servisinden gelen veriyi parse eder
  factory Earthquake.fromKandilliXml(XmlElement item) {
    String titleText = item.findElements('title').isNotEmpty ? item.findElements('title').first.innerText : 'Bilinmeyen Konum';
    String descText = item.findElements('description').isNotEmpty ? item.findElements('description').first.innerText : '';
    
    // "1.5 (ML) MALAZGIRT" -> Büyüklüğü ayır
    double mag = 0.0;
    final magMatch = RegExp(r'^([\d\.]+)').firstMatch(titleText);
    if (magMatch != null) {
      mag = double.tryParse(magMatch.group(1) ?? '0') ?? 0.0;
    }

    String location = titleText.replaceAll(RegExp(r'^[\d\.]+\s*(?:\([a-zA-Z]+\)|\-)?\s*'), '').trim();

    // Tarihi açıklama formatından çıkar: "2024.12.11 09:22:06"
    DateTime date = DateTime.now();
    try {
      final dateMatch = RegExp(r'(\d{4})[./-](\d{2})[./-](\d{2})\s+(\d{2}):(\d{2}):(\d{2})').firstMatch(descText);
      if (dateMatch != null) {
        date = DateTime(
          int.parse(dateMatch.group(1)!),
          int.parse(dateMatch.group(2)!),
          int.parse(dateMatch.group(3)!),
          int.parse(dateMatch.group(4)!),
          int.parse(dateMatch.group(5)!),
          int.parse(dateMatch.group(6)!),
        );
      }
    } catch (_) {}

    // Derinlik ve Koordinatları çıkar
    double depth = 0.0;
    double lat = 0.0;
    double lng = 0.0;

    final depthMatch1 = RegExp(r'Derinlik[^\d]*([\d\.]+)').firstMatch(descText);
    if (depthMatch1 != null) {
      depth = double.tryParse(depthMatch1.group(1) ?? '0') ?? 0.0;
    }

    if (item.findElements('geo:lat').isNotEmpty) lat = double.tryParse(item.findElements('geo:lat').first.innerText) ?? 0.0;
    if (item.findElements('geo:long').isNotEmpty) lng = double.tryParse(item.findElements('geo:long').first.innerText) ?? 0.0;

    // Farklı formattaysa Description'dan arta kalan floatları topla: [mag, lat, lng, depth]
    if (lat == 0.0 || lng == 0.0 || depth == 0.0) {
      final floatMatches = RegExp(r'\b(\d+\.\d+)\b').allMatches(descText).toList();
      if (lat == 0.0 && floatMatches.length >= 3) {
        lat = double.tryParse(floatMatches[1].group(1) ?? '0') ?? lat;
        lng = double.tryParse(floatMatches[2].group(1) ?? '0') ?? lng;
      }
      if (depth == 0.0 && floatMatches.isNotEmpty) {
        depth = double.tryParse(floatMatches.length >= 4 ? floatMatches[3].group(1) ?? '0' : floatMatches.last.group(1)!) ?? 0.0;
      }
    }

    String link = item.findElements('link').isNotEmpty ? item.findElements('link').first.innerText : '';
    String id = link.isNotEmpty ? link.split('/').last.replaceAll('.asp', '') : date.millisecondsSinceEpoch.toString();

    return Earthquake(
      id: id,
      title: location.isEmpty ? 'Bilinmeyen Konum' : location,
      date: date,
      mag: mag,
      depth: depth,
      latitude: lat,
      longitude: lng,
    );
  }

  // USGS API'den gelen GeoJSON verisini parse eder
  factory Earthquake.fromJsonUSGS(Map<String, dynamic> json) {
    final properties = json['properties'];
    final geometry = json['geometry'];
    
    // USGS returns coordinates as [longitude, latitude, depth]
    List<dynamic> coordinates = geometry['coordinates'] ?? [0.0, 0.0, 0.0];
    
    // Time is in milliseconds since epoch
    final timeMs = properties['time'] as int?;
    DateTime date = timeMs != null 
        ? DateTime.fromMillisecondsSinceEpoch(timeMs).toLocal() 
        : DateTime.now();
        
    String title = properties['place'] ?? 'Bilinmeyen Konum';
    // Remove "X km Y of " prefix from USGS title to make it cleaner
    if (title.contains(' of ')) {
      title = title.split(' of ').last;
    }

    return Earthquake(
      id: json['id'] ?? '',
      title: title.trim(),
      date: date,
      mag: _parseDouble(properties['mag']),
      depth: _parseDouble(coordinates.length > 2 ? coordinates[2] : 0.0), // USGS provides depth as 3rd coordinate
      latitude: _parseDouble(coordinates[1]),
      longitude: _parseDouble(coordinates[0]),
    );
  }
}
