import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../models/earthquake.dart';
import '../models/news.dart';

class EarthquakeService {
  // Kandilli Rasathanesi Resmi RSS Kaynağı
  static const String _kandilliRssUrl = "http://koeri.boun.edu.tr/rss/";
  static const String _usgsApiUrl = "https://earthquake.usgs.gov/fdsnws/event/1/query";
  static const String _googleNewsRssUrl = "https://news.google.com/rss/search?q=deprem+when:7d&hl=tr&gl=TR&ceid=TR:tr";
  static const String _afadLiveUrl = "https://api.orhanaydogdu.com.tr/deprem/afad/live";

  // 1. ANLIK DEPREMLER (AFAD JSON PROXY)
  Future<List<Earthquake>> fetchAfadEarthquakes({int limit = 100}) async {
    try {
      final response = await http.get(Uri.parse(_afadLiveUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['result'] != null) {
          List<dynamic> results = data['result'];
          List<Earthquake> earthquakes = results.map((json) => Earthquake.fromJsonAfad(json)).toList();
          
          if (earthquakes.length > limit) {
            earthquakes = earthquakes.sublist(0, limit);
          }
          return earthquakes;
        }
        return [];
      } else {
        throw Exception("AFAD API isteği başarısız oldu: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("AFAD depremleri çekilirken hata: $e");
    }
  }

  // 2. ANLIK DEPREMLER (KANDİLLİ - OPSİYONEL)
  Future<List<Earthquake>> fetchKandilliEarthquakes({int limit = 200}) async {
    try {
      final response = await http.get(Uri.parse(_kandilliRssUrl));
      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        final items = document.findAllElements('item');

        List<Earthquake> earthquakes = [];
        for (var item in items) {
          try {
            earthquakes.add(Earthquake.fromKandilliXml(item));
          } catch (_) {
            // Parse edilemeyen item'ı atla
          }
        }

        // Limit uygula
        if (earthquakes.length > limit) {
          earthquakes = earthquakes.sublist(0, limit);
        }

        return earthquakes;
      } else {
        throw Exception("Kandilli RSS isteği başarısız oldu: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Anlık depremler çekilirken hata: $e");
    }
  }

  // 2. SON 1 YIL BÜYÜK DEPREMLER (USGS - KONUM BAZLI)
  Future<List<Earthquake>> fetchUSGSHistoryEarthquakes({
    required double latitude,
    required double longitude,
    double radiusKm = 100.0,
  }) async {
    try {
      final now = DateTime.now();
      final oneYearAgo = now.subtract(const Duration(days: 365));
      
      final String startTime = "${oneYearAgo.year}-${oneYearAgo.month.toString().padLeft(2, '0')}-${oneYearAgo.day.toString().padLeft(2, '0')}";
      final String endTime = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      
      final Uri uri = Uri.parse(
        '$_usgsApiUrl?format=geojson&starttime=$startTime&endtime=$endTime&latitude=$latitude&longitude=$longitude&maxradiuskm=$radiusKm&minmagnitude=1.0'
      );

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['features'] != null) {
          List<dynamic> features = data['features'];
          return features.map((json) => Earthquake.fromJsonUSGS(json)).toList();
        }
        return [];
      } else {
        throw Exception("USGS API isteği başarısız oldu: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Tarihçe çekilirken hata: $e");
    }
  }

  // 3. DEPREM HABERLERİ (GOOGLE NEWS RSS)
  Future<List<News>> fetchEarthquakeNews() async {
    try {
      final response = await http.get(Uri.parse(_googleNewsRssUrl));
      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        final items = document.findAllElements('item');

        List<News> newsList = [];
        for (var item in items) {
          try {
            newsList.add(News(
              title: item.findElements('title').first.innerText,
              link: item.findElements('link').first.innerText,
              description: item.findElements('description').first.innerText,
              pubDate: _parseRfc822Date(item.findElements('pubDate').first.innerText),
              source: item.findElements('source').isNotEmpty ? item.findElements('source').first.innerText : "Google News",
            ));
          } catch (_) {}
        }
        return newsList;
      }
      return [];
    } catch (e) {
      // Log error internally if needed
      return [];
    }
  }

  // RSS zaman formatını parse et (RFC 822)
  DateTime _parseRfc822Date(String dateString) {
    try {
      // Örn: Sat, 21 Mar 2026 12:00:00 GMT
      // Simple parse for now, can be improved with intl/DateFormat
      return DateTime.tryParse(dateString) ?? DateTime.now();
    } catch (_) {
      return DateTime.now();
    }
  }
}


