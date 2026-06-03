
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../models/earthquake.dart';
import '../models/saved_location.dart';
import '../services/earthquake_service.dart';
import '../services/notification_service.dart';
import '../utils/location_helper.dart';
import '../models/news.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/native_ad_card.dart';
import 'package:url_launcher/url_launcher.dart';

enum DataType { live, history, news }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final EarthquakeService _service = EarthquakeService();
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  
  List<Earthquake> _earthquakes = [];
  List<News> _newsList = [];
  bool _isLoading = true;
  String _errorMessage = '';
  
  LatLng _center = const LatLng(LocationHelper.defaultLat, LocationHelper.defaultLng);
  bool _isLocationReady = false;
  DataType _currentDataType = DataType.live; // Başlangıçta canlı veriler
  
  List<SavedLocation> _savedLocations = [];
  SavedLocation? _selectedLocation;

  late final MapController _mapController;
  Timer? _refreshTimer;
  
  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    // AdMob SDK başlat
    MobileAds.instance.initialize();
    _initializeLocationAndData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (_currentDataType == DataType.live) _fetchData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _sheetController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedLocations() async {
    final locs = await LocationHelper.getSavedLocations();
    if (mounted) {
      setState(() {
        _savedLocations = locs;
      });
    }
  }

  Future<void> _initializeLocationAndData() async {
    setState(() => _isLoading = true);
    
    // Kayıtlı adresleri yükle
    await _loadSavedLocations();

    if (_selectedLocation != null) {
      _center = LatLng(_selectedLocation!.latitude, _selectedLocation!.longitude);
      _isLocationReady = true;
    } else {
      // Seçili konum yoksa (GPS kullan)
      final LatLng userLoc = await LocationHelper.getCurrentLocation();
      if (!mounted) return;
      _center = userLoc;
      _isLocationReady = true;
    }
    
    // Konum bulunduktan sonra veriyi çek
    await _fetchData();
    
    // Harita kameranın bulunduğu konuma gitsin (Render edilene kadar bekle)
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          _mapController.move(_center, 9.0);
        } catch (e) {
          debugPrint("İlk harita hareketi hatası: $e");
        }
      });
    }
  }
  
  Future<void> _fetchData() async {
    if (!mounted || !_isLocationReady) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      List<Earthquake> data = [];
      if (_currentDataType == DataType.live) {
        data = await _service.fetchAfadEarthquakes(limit: 100);
        final filtered = LocationHelper.filterEarthquakesWithinRadius(data, _center, radiusKm: 100.0);
        filtered.sort((a, b) => b.date.compareTo(a.date));
        if (mounted) {
          setState(() {
            _earthquakes = filtered;
            _isLoading = false;
          });
        }
      } else if (_currentDataType == DataType.history) {
        data = await _service.fetchUSGSHistoryEarthquakes(
          latitude: _center.latitude,
          longitude: _center.longitude,
          radiusKm: 100.0,
        );
        data.sort((a, b) => b.date.compareTo(a.date));
        if (mounted) {
          setState(() {
            _earthquakes = data;
            _isLoading = false;
          });
        }
      } else if (_currentDataType == DataType.news) {
        final news = await _service.fetchEarthquakeNews();
        if (mounted) {
          setState(() {
            _newsList = news;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // Segmented Control (Canlı | Geçmiş) seçimi
  void _onCategoryChanged(DataType type) {
    if (_currentDataType == type) return;
    setState(() {
      _currentDataType = type;
      _earthquakes = [];
      _newsList = [];
    });
    _fetchData();
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Haber linki açılamadı.')),
        );
      }
    }
  }

  Color _getMagnitudeColor(double mag) {
    if (mag < 4.0) return const Color(0xFFF8BD2A); // Neon Green
    if (mag < 5.0) return const Color(0xFF954A00); // Neon Orange
    return const Color(0xFFBA1A1A); // Neon Red
  }

  void _fireTestNotification() {
    NotificationService().triggerEarthquakeAlert(
      context,
      "TEST - 5.1 Büyüklüğünde Deprem!",
      "Merkez: MARMARA DENIZI\nDerinlik: 7.2 km\nTarih: ${DateFormat('dd.MM.yyyy HH:mm:ss').format(DateTime.now())}",
    );
  }

  void _moveToLocation(LatLng location) {
    try {
      _mapController.move(location, 11.0);
    } catch (e) {
      debugPrint("Harita hareket hatası: $e");
    }
    if (_sheetController.isAttached) {
      _sheetController.animateTo(0.15, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  // --- ÖZEL KONUM EKRANLARI ---

  void _showLocationSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFFFFFF),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40, height: 5,
                decoration: BoxDecoration(color: Colors.grey.shade600, borderRadius: BorderRadius.circular(10)),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Konum Seç", style: TextStyle(color: Color(0xFF191C1D), fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.my_location, color: Colors.blueAccent),
                title: const Text("Mevcut Konumum (GPS)", style: TextStyle(color: Color(0xFF191C1D))),
                trailing: _selectedLocation == null ? const Icon(Icons.check, color: Colors.blueAccent) : null,
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _selectedLocation = null);
                  _initializeLocationAndData();
                },
              ),
              const Divider(color: Colors.white24),
              ..._savedLocations.map((loc) => ListTile(
                leading: const Icon(Icons.location_on, color: Colors.redAccent),
                title: Text(loc.name, style: const TextStyle(color: Color(0xFF191C1D))),
                trailing: _selectedLocation?.id == loc.id ? const Icon(Icons.check, color: Colors.redAccent) : null,
                onLongPress: () async {
                  await LocationHelper.deleteLocation(loc.name);
                  _loadSavedLocations();
                  Navigator.pop(ctx);
                },
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _selectedLocation = loc);
                  _initializeLocationAndData();
                },
              )),
              if (_savedLocations.isNotEmpty) const Divider(color: Colors.white24),
              ListTile(
                leading: const Icon(Icons.add_circle_outline, color: Color(0xFF191C1D)),
                title: const Text("Yeni Konum Ekle", style: TextStyle(color: Color(0xFF191C1D))),
                onTap: () {
                  Navigator.pop(ctx);
                  _addNewLocationDialog();
                },
              ),
            ],
          ),
        );
      }
    );
  }

  void _addNewLocationDialog() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    bool isSearching = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFFFFFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("Yeni Konum", style: TextStyle(color: Color(0xFF191C1D))),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Color(0xFF191C1D)),
                    decoration: InputDecoration(
                      labelText: "Özel İsim (Örn: Evim, İzmir)",
                      labelStyle: TextStyle(color: const Color(0xFF45474D)),
                      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: addressController,
                    style: const TextStyle(color: Color(0xFF191C1D)),
                    decoration: InputDecoration(
                      labelText: "Şehir veya Adres",
                      labelStyle: TextStyle(color: const Color(0xFF45474D)),
                      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    ),
                  ),
                  if (isSearching) ...[
                    const SizedBox(height: 20),
                    const CircularProgressIndicator(color: Colors.redAccent),
                  ]
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("İptal", style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty || addressController.text.isEmpty) return;
                    
                    setDialogState(() => isSearching = true);
                    
                    try {
                      LatLng? coords = await LocationHelper.geocodeAddress(addressController.text);
                      if (coords != null) {
                        final newLoc = SavedLocation(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text,
                          latitude: coords.latitude,
                          longitude: coords.longitude,
                        );
                        await LocationHelper.saveLocation(newLoc);
                        
                        setState(() {
                          _savedLocations.add(newLoc);
                          _selectedLocation = newLoc;
                        });
                        
                        _initializeLocationAndData();
                        Navigator.pop(ctx);
                      } else {
                        // Bulunamadı hatası
                        setDialogState(() => isSearching = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Konum bulunamadı, daha belirgin bir adres yazın."))
                        );
                      }
                    } catch (e) {
                      setDialogState(() => isSearching = false);
                    }
                  },
                  child: const Text("Kaydet", style: TextStyle(color: Colors.redAccent)),
                ),
              ],
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLocationReady) {
      return Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', height: 100),
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: Colors.redAccent),
              const SizedBox(height: 24),
              const Text(
                "SeismoAlert",
                style: TextStyle(
                  color: Color(0xFF191C1D),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text("GPS Konumunuz Aranıyor...", style: TextStyle(color: Color(0xFF45474D))),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. TAM EKRAN HARITA (Performans için RepaintBoundary eklendi)
          Positioned.fill(
            child: RepaintBoundary(
              child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: 9.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.depremanlik',
                  
                ),
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _center,
                      color: Colors.blueAccent.withValues(alpha: 0.1),
                      borderStrokeWidth: 2,
                      borderColor: Colors.blueAccent.withValues(alpha: 0.3),
                      useRadiusInMeter: true,
                      radius: 100000, // 100 km
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    // Kullanıcı Konumu Cihazdan (Mavi İşaret)
                    Marker(
                      point: _center,
                      width: 44,
                      height: 44,
                      child: Container(
                         decoration: BoxDecoration(
                           shape: BoxShape.circle,
                           border: Border.all(color: const Color(0xFF191C1D), width: 2),
                           color: Colors.blueAccent.withValues(alpha: 0.3),
                         ),
                         child: const Icon(Icons.my_location, color: Colors.blueAccent, size: 28),
                      ),
                    ),
                    // Depremler Cache ve Loop
                    ..._earthquakes.map((eq) => Marker(
                      point: LatLng(eq.latitude, eq.longitude),
                      width: 50,
                      height: 50,
                      child: GestureDetector(
                        onTap: () => _moveToLocation(LatLng(eq.latitude, eq.longitude)),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: eq.mag > 4.0 ? [
                              BoxShadow(
                                color: _getMagnitudeColor(eq.mag).withValues(alpha: 0.6),
                                blurRadius: 10,
                                spreadRadius: 2,
                              )
                            ] : null
                          ),
                          child: Icon(
                            Icons.warning_rounded, 
                            color: _getMagnitudeColor(eq.mag),
                            size: eq.mag > 4.0 ? 36 : 24,
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              ],
            ),
          ),
        ),
          
          // 2. CAM EFEKTİ APP BAR
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 16, left: 20, right: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA).withValues(alpha: 0.95),
                border: Border(bottom: BorderSide(color: const Color(0xFF191C1D).withValues(alpha: 0.1), width: 1)),
              ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Image.asset('assets/images/logo.png', height: 40),
                          const SizedBox(width: 8),
                          const Text(
                            'SeismoAlert',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF191C1D),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: _showLocationSelector,
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.blueAccent, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedLocation?.name ?? AppLocalizations.of(context)!.location,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF191C1D), letterSpacing: 0.5),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.keyboard_arrow_down, color: Color(0xFF45474D)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              if (_isLoading) 
                                const SizedBox(
                                  width: 20, height: 20, 
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF191C1D))
                                ),
                              const SizedBox(width: 12),
                              // Dil Seçici (Bayraklar)
                              GestureDetector(
                                onTap: () => LocaleProvider.changeLocale('tr'),
                                child: Opacity(
                                  opacity: LocaleProvider.currentLanguage == 'tr' ? 1.0 : 0.4,
                                  child: const Text('🇹🇷', style: TextStyle(fontSize: 22)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => LocaleProvider.changeLocale('en'),
                                child: Opacity(
                                  opacity: LocaleProvider.currentLanguage == 'en' ? 1.0 : 0.4,
                                  child: const Text('🇬🇧', style: TextStyle(fontSize: 22)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: _fetchData,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF191C1D).withValues(alpha: 0.1),
                                  ),
                                  child: const Icon(Icons.refresh, color: Color(0xFF191C1D), size: 20),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Mod Seçici: Canlı <-> Son 1 Yıl B.Depremler
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF191C1D).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _onCategoryChanged(DataType.live),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _currentDataType == DataType.live 
                                      ? Colors.redAccent.withValues(alpha: 0.8) 
                                      : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(AppLocalizations.of(context)!.live, style: const TextStyle(color: Color(0xFF191C1D), fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _onCategoryChanged(DataType.history),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _currentDataType == DataType.history 
                                      ? Colors.redAccent.withValues(alpha: 0.8) 
                                      : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(AppLocalizations.of(context)!.history, style: const TextStyle(color: Color(0xFF191C1D), fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _onCategoryChanged(DataType.news),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _currentDataType == DataType.news 
                                      ? Colors.redAccent.withValues(alpha: 0.8) 
                                      : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(AppLocalizations.of(context)!.news, style: const TextStyle(color: Color(0xFF191C1D), fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),

          // 3. FLOATING ACTION BUTTON
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).size.height * 0.15 + 20,
            child: FloatingActionButton(
              onPressed: _fireTestNotification,
              backgroundColor: const Color(0xFF2D0003),
              elevation: 8,
              child: const Icon(Icons.notification_add, color: Color(0xFF191C1D)),
            ),
          ),

          // 4. KAYAN ALT ETKİLEŞİM PANELİ
          Positioned.fill(
            child: DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.15,
              minChildSize: 0.10,
              maxChildSize: 0.70,
              snap: true,
              snapSizes: const [0.15, 0.4, 0.70],
              builder: (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F5).withValues(alpha: 0.98),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    child: ListView(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      children: [
                        // Sürükleme tutma çubuğu alanı
                        const SizedBox(height: 12),
                        Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: const Color(0xFF45474D),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _currentDataType == DataType.live 
                                  ? AppLocalizations.of(context)!.liveEarthquakes 
                                  : (_currentDataType == DataType.history ? AppLocalizations.of(context)!.pastEarthquakes : AppLocalizations.of(context)!.earthquakeNews), 
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF191C1D))
                              ),
                              Text(
                                _currentDataType == DataType.news 
                                  ? AppLocalizations.of(context)!.newsCount(_newsList.length) 
                                  : AppLocalizations.of(context)!.records(_earthquakes.length), 
                                style: TextStyle(fontSize: 12, color: const Color(0xFF45474D))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // İçerik listesi
                        if (_currentDataType == DataType.news)
                          ..._buildNewsListItems()
                        else
                          ..._buildEarthquakeListItems(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- ListView için Widget Listeleri ---

  List<Widget> _buildEarthquakeListItems() {
    if (_isLoading && _earthquakes.isEmpty) {
      return [
        SizedBox(
          height: 150,
          child: Center(child: CircularProgressIndicator(color: Colors.grey.shade600)),
        ),
      ];
    }
    
    if (_errorMessage.isNotEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 36),
                const SizedBox(height: 12),
                Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF191C1D))),
              ],
            ),
          ),
        ),
      ];
    }
    
    if (_earthquakes.isEmpty) {
      String msg = _currentDataType == DataType.live 
        ? 'Çevrenizde (100km) anlık kayıtlı deprem bulunamadı.' 
        : 'Çevrenizde (100km) son 1 yılda kayıtlı deprem bulunamadı.';
      return [
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(msg, 
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: const Color(0xFF45474D))),
        ),
      ];
    }

    return _earthquakes.asMap().entries.map((entry) {
      final index = entry.key;
      final eq = entry.value;
      final color = _getMagnitudeColor(eq.mag);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 300 + (index * 50).clamp(0, 500)),
          opacity: 1.0,
          curve: Curves.easeIn,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(16),
              
              boxShadow: eq.mag > 4.0 ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.05),
                  blurRadius: 5,
                  spreadRadius: 1,
                )
              ] : null
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _moveToLocation(LatLng(eq.latitude, eq.longitude)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 2),
                          boxShadow: eq.mag > 4.0 ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.2),
                              blurRadius: 5,
                              spreadRadius: 1,
                            )
                          ] : null
                        ),
                        child: Center(
                          child: Text(
                            eq.mag.toStringAsFixed(1),
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              eq.title,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF191C1D)),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.access_time_filled, size: 14, color: const Color(0xFF45474D)),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('dd.MM.yyyy HH:mm').format(eq.date),
                                  style: TextStyle(color: const Color(0xFF45474D), fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.my_location, size: 14, color: const Color(0xFF45474D)),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${AppLocalizations.of(context)!.kmAway((eq.distance / 1000).toStringAsFixed(1))} • ${AppLocalizations.of(context)!.depth}: ${eq.depth} km',
                                    style: TextStyle(color: const Color(0xFF45474D), fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: const Color(0xFF191C1D).withValues(alpha: 0.3)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildNewsListItems() {
    if (_isLoading && _newsList.isEmpty) {
      return [
        SizedBox(
          height: 150,
          child: Center(child: CircularProgressIndicator(color: Colors.grey.shade600)),
        ),
      ];
    }

    if (_newsList.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(AppLocalizations.of(context)!.noData, 
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: Color(0xFF45474D))),
        ),
      ];
    }

    // Her haberden sonra 1 native reklam → toplam liste boyutu 2x
    final List<Widget> items = [];

    for (int i = 0; i < _newsList.length; i++) {
      final news = _newsList[i];

      // --- Haber Kartı ---
      items.add(
        Padding(
          key: ValueKey('news_$i'),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AnimatedOpacity(
            duration: Duration(milliseconds: 300 + (i * 50).clamp(0, 500)),
            opacity: 1.0,
            curve: Curves.easeIn,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _launchUrl(news.link),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                news.source ?? AppLocalizations.of(context)!.news.toUpperCase(),
                                style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              DateFormat('dd.MM.yyyy HH:mm').format(news.pubDate),
                              style: TextStyle(color: const Color(0xFF45474D), fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          news.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF191C1D)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          news.description.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ''),
                          style: TextStyle(color: const Color(0xFF45474D), fontSize: 13, height: 1.4),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // --- Native Reklam Kartı (her haberden sonra) ---
      items.add(NativeAdCard(key: ValueKey('ad_$i')));
    }

    return items;
  }
}
