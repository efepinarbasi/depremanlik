import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../models/earthquake.dart';
import '../models/saved_location.dart';
import '../services/earthquake_service.dart';
import '../utils/location_helper.dart';
import '../models/news.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/native_ad_card.dart';
import 'home_screen.dart';

import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class StitchHomeScreen extends StatefulWidget {
  const StitchHomeScreen({super.key});

  @override
  State<StitchHomeScreen> createState() => _StitchHomeScreenState();
}

class _StitchHomeScreenState extends State<StitchHomeScreen> with TickerProviderStateMixin {
  final EarthquakeService _service = EarthquakeService();
  int _selectedIndex = 1;
  
  List<Earthquake> _earthquakes = [];
  List<News> _newsList = [];
  bool _isLoading = true;
  String _errorMessage = '';
  
  LatLng _center = const LatLng(LocationHelper.defaultLat, LocationHelper.defaultLng);
  bool _isLocationReady = false;
  DataType _currentDataType = DataType.live; 
  String _mapStyle = 'satellite';
  
  List<SavedLocation> _savedLocations = [];
  SavedLocation? _selectedLocation;
  late final MapController _mapController;
  Timer? _refreshTimer;
  
  // Settings
  double _minMagnitude = 3.0;
  double _notificationRadius = 100.0;
  bool _isDarkMode = true;
  bool _soundEnabled = true;
  final List<TextEditingController> _contactControllers = [TextEditingController(), TextEditingController(), TextEditingController()];
  final TextEditingController _addressController = TextEditingController();

  // Structural Health
  final TextEditingController _binaYasiController = TextEditingController();
  final TextEditingController _katSayisiController = TextEditingController();
  final TextEditingController _binaTipiController = TextEditingController();
  final TextEditingController _zeminTipiController = TextEditingController();

  // Evacuation Plan
  final TextEditingController _evCikisiController = TextEditingController();
  final TextEditingController _toplanmaNoktasiController = TextEditingController();
  final TextEditingController _alternatifRotaController = TextEditingController();
  final TextEditingController _bulusmaNoktasiController = TextEditingController();

  bool _isSirenActive = false;
  Timer? _vibrationTimer;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    // AdMob SDK başlat
    MobileAds.instance.initialize();
    _loadSettings();
    _initializeLocationAndData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (_currentDataType == DataType.live) _fetchData();
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _minMagnitude = prefs.getDouble('minMagnitude') ?? 3.0;
      _notificationRadius = prefs.getDouble('notificationRadius') ?? 100.0;
      _isDarkMode = true;
      _soundEnabled = prefs.getBool('soundEnabled') ?? true;
      _contactControllers[0].text = prefs.getString('contact0') ?? '';
      _contactControllers[1].text = prefs.getString('contact1') ?? '';
      _contactControllers[2].text = prefs.getString('contact2') ?? '';
      _binaYasiController.text = prefs.getString('binaYasi') ?? 'RC / Masonry / Steel';
      _katSayisiController.text = prefs.getString('katSayisi') ?? '1-50+';
      _binaTipiController.text = prefs.getString('binaTipi') ?? 'RC / Masonry / Steel';
      _zeminTipiController.text = prefs.getString('zeminTipi') ?? 'Rock / Sand / Clay';
      _evCikisiController.text = prefs.getString('evCikisi') ?? '→ →';
      _toplanmaNoktasiController.text = prefs.getString('toplanmaNoktasi') ?? '📍';
      _alternatifRotaController.text = prefs.getString('alternatifRota') ?? '🔀';
      _bulusmaNoktasiController.text = prefs.getString('bulusmaNoktasi') ?? '👥';
      // Load kit items
      final savedKit = prefs.getStringList('kitChecked') ?? [];
      if (savedKit.isNotEmpty) {
        for (final key in _kitItems.keys.toList()) {
          _kitItems[key] = savedKit.contains(key);
        }
      }
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('minMagnitude', _minMagnitude);
    await prefs.setDouble('notificationRadius', _notificationRadius);
    // await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setBool('soundEnabled', _soundEnabled);
    await prefs.setString('contact0', _contactControllers[0].text);
    await prefs.setString('contact1', _contactControllers[1].text);
    await prefs.setString('contact2', _contactControllers[2].text);
    await prefs.setString('binaYasi', _binaYasiController.text);
    await prefs.setString('katSayisi', _katSayisiController.text);
    await prefs.setString('binaTipi', _binaTipiController.text);
    await prefs.setString('zeminTipi', _zeminTipiController.text);
    await prefs.setString('evCikisi', _evCikisiController.text);
    await prefs.setString('toplanmaNoktasi', _toplanmaNoktasiController.text);
    await prefs.setString('alternatifRota', _alternatifRotaController.text);
    await prefs.setString('bulusmaNoktasi', _bulusmaNoktasiController.text);
    // Save kit items
    final checkedItems = _kitItems.entries.where((e) => e.value).map((e) => e.key).toList();
    await prefs.setStringList('kitChecked', checkedItems);
    _fetchData(); 
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    if (_isSirenActive) {
      FlutterRingtonePlayer().stop();
      _vibrationTimer?.cancel();
    }
    for(var c in _contactControllers) { c.dispose(); }
    _addressController.dispose();
    _binaYasiController.dispose();
    _katSayisiController.dispose();
    _binaTipiController.dispose();
    _zeminTipiController.dispose();
    _evCikisiController.dispose();
    _toplanmaNoktasiController.dispose();
    _alternatifRotaController.dispose();
    _bulusmaNoktasiController.dispose();
    super.dispose();
  }

  Future<void> _addNewLocation() async {
    if (_addressController.text.trim().isEmpty) return;
    final l = AppLocalizations.of(context)!;
    
    final name = _addressController.text.trim();
    final LatLng? coords = await LocationHelper.geocodeAddress(name);
    
    if (coords != null) {
      final newLoc = SavedLocation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        latitude: coords.latitude,
        longitude: coords.longitude,
      );
      await LocationHelper.saveLocation(newLoc);
      _addressController.clear();
      await _loadSavedLocations();
      
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.localeName == 'tr' ? 'Adres kaydedildi' : 'Address saved')));
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.localeName == 'tr' ? 'Adres bulunamadı' : 'Address not found')));
    }
  }

  Future<void> _deleteLocation(String name) async {
    await LocationHelper.deleteLocation(name);
    await _loadSavedLocations();
  }

  Future<void> _loadSavedLocations() async {
    final locs = await LocationHelper.getSavedLocations();
    if (mounted) setState(() => _savedLocations = locs);
  }

  Future<void> _initializeLocationAndData() async {
    setState(() => _isLoading = true);
    await _loadSavedLocations();

    if (_selectedLocation != null) {
      _center = LatLng(_selectedLocation!.latitude, _selectedLocation!.longitude);
      _isLocationReady = true;
    } else {
      final LatLng userLoc = await LocationHelper.getCurrentLocation();
      if (!mounted) return;
      _center = userLoc;
      _isLocationReady = true;
    }
    await _fetchData();
  }
  
  Future<void> _fetchData() async {
    if (!mounted || !_isLocationReady) return;
    setState(() { _isLoading = true; _errorMessage = ''; });
    
    try {
      List<Earthquake> data = [];
      if (_currentDataType == DataType.live) {
        data = await _service.fetchAfadEarthquakes(limit: 100);
        var filtered = LocationHelper.filterEarthquakesWithinRadius(data, _center, radiusKm: _notificationRadius);
        filtered = filtered.where((eq) => eq.mag >= _minMagnitude).toList();
        filtered.sort((a, b) => b.date.compareTo(a.date));
        if (mounted) setState(() { _earthquakes = filtered; _isLoading = false; });
      } else if (_currentDataType == DataType.history) {
        data = await _service.fetchUSGSHistoryEarthquakes(
          latitude: _center.latitude, longitude: _center.longitude, radiusKm: _notificationRadius,
        );
        data = LocationHelper.filterEarthquakesWithinRadius(data, _center, radiusKm: _notificationRadius);
        data = data.where((eq) => eq.mag >= _minMagnitude).toList();
        data.sort((a, b) => b.date.compareTo(a.date));
        if (mounted) setState(() { _earthquakes = data; _isLoading = false; });
      } else if (_currentDataType == DataType.news) {
        final news = await _service.fetchEarthquakeNews();
        if (mounted) setState(() { _newsList = news; _isLoading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _errorMessage = e.toString(); _isLoading = false; });
    }
  }

  void _onCategoryChanged(DataType type) {
    if (_currentDataType == type) return;
    setState(() { _currentDataType = type; _earthquakes = []; _newsList = []; });
    _fetchData();
  }

  // Stitch "Seismic Elite" Glassmorphism Design Tokens
  static const Color _bgColor = Color(0xFF131313);
  static const Color _surfaceColor = Color(0xFF202020);
  static const Color _surfaceHigh = Color(0xFF2a2a2a);
  static const Color _surfaceHighest = Color(0xFF353535);
  static const Color _surfaceBright = Color(0xFF393939);
  static const Color _onSurface = Color(0xFFE5E2E1);
  static const Color _onSurfaceVariant = Color(0xFFE7BCB8);
  static const Color _primary = Color(0xFFFFB4AB);
  static const Color _primaryContainer = Color(0xFFFF544B);
  static const Color _secondary = Color(0xFFFFB77D);
  static const Color _secondaryContainer = Color(0xFFFD8B00);
  static const Color _tertiary = Color(0xFF2AE500);
  static const Color _outline = Color(0xFFAE8883);
  static const Color _outlineVariant = Color(0xFF5E3F3C);

  Color _getMagnitudeColor(double mag) {
    if (mag < 4.0) return _tertiary;          // Neon Green
    if (mag < 5.0) return _secondaryContainer; // Electric Orange  
    return _primaryContainer;                  // Neon Red
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLocationReady) {
      return Scaffold(
        backgroundColor: _bgColor,
        body: Center(child: CircularProgressIndicator(color: _primaryContainer)),
      );
    }

    final l = AppLocalizations.of(context)!;
    final isDark = _isDarkMode;
    
    final Color bgColor = isDark ? _bgColor : const Color(0xFFF8F9FA);
    final Color cardColor = isDark ? _surfaceHigh : const Color(0xFFFFFFFF);
    final Color navColor = isDark ? const Color(0xFF0E0E0E) : const Color(0xFFF3F4F5);

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: _selectedIndex == 0 ? null : AppBar(
        title: Text('SeismoAlert', style: TextStyle(fontWeight: FontWeight.w900, color: _onSurface, letterSpacing: -0.5, fontFamily: 'Inter')),
        centerTitle: false,
        backgroundColor: _bgColor,
        elevation: 0,
        actions: [
          if (_isLoading) 
             Padding(padding: const EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: _primaryContainer))),
          IconButton(icon: Icon(Icons.refresh, color: _onSurfaceVariant), onPressed: _fetchData),
        ],
      ),
      body: _buildBody(l, isDark, cardColor),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _primary, fontFamily: 'Inter');
              }
              return TextStyle(fontSize: 12, color: _onSurfaceVariant.withValues(alpha: 0.6), fontFamily: 'Inter');
            }),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
          backgroundColor: const Color(0xFF0E0E0E),
          indicatorColor: _primaryContainer.withValues(alpha: 0.2),
          destinations: [
            NavigationDestination(icon: Icon(Icons.map_outlined, color: _onSurfaceVariant.withValues(alpha: 0.5)), selectedIcon: Icon(Icons.map, color: _primaryContainer), label: l.mapTab),
            NavigationDestination(icon: Icon(Icons.list_alt_outlined, color: _onSurfaceVariant.withValues(alpha: 0.5)), selectedIcon: Icon(Icons.list_alt, color: _primaryContainer), label: l.activityTab),
            NavigationDestination(icon: Icon(Icons.menu_book_outlined, color: _onSurfaceVariant.withValues(alpha: 0.5)), selectedIcon: Icon(Icons.menu_book, color: _primaryContainer), label: l.localeName == 'tr' ? 'Rehber' : 'Guide'),
            NavigationDestination(icon: Icon(Icons.settings_outlined, color: _onSurfaceVariant.withValues(alpha: 0.5)), selectedIcon: Icon(Icons.settings, color: _primaryContainer), label: l.settingsTab),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l, bool isDark, Color cardColor) {
    Widget content;
    switch (_selectedIndex) {
      case 0: content = _buildMapTab(l, isDark); break;
      case 1: content = _buildActivityTab(l, isDark, cardColor); break;
      case 2: content = _buildGuideTab(l, isDark, cardColor); break;
      case 3: content = _buildSettingsTab(l, isDark, cardColor); break;
      default: content = Center(child: Text(l.developmentInProgress, style: TextStyle(color: isDark ? Colors.white : Colors.black))); break;
    }
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: SlideTransition(position: Tween<Offset>(begin: const Offset(0.0, 0.05), end: Offset.zero).animate(animation), child: child));
      },
      child: KeyedSubtree(key: ValueKey<int>(_selectedIndex), child: content),
    );
  }

  // Emergency Kit items state
  final Map<String, bool> _kitItems = {
    'kit1': true, 'kit2': true, 'kit3': true, 'kit4': true, 'kit5': false,
    'kit6': false, 'kit7': true, 'kit8': false, 'kit9': false, 'kit10': true,
    'kit11': false, 'kit12': true, 'kit13': true, 'kit14': false, 'kit15': true,
    'kit16': true, 'kit17': false, 'kit18': false, 'kit19': false, 'kit20': true,
  };

  String _getKitItemLabel(String key, AppLocalizations l) {
    final isTr = l.localeName == 'tr';
    switch (key) {
      case 'kit1': return isTr ? 'Su (kişi başı günlük 4 litre)' : 'Water (4 liters per person per day)';
      case 'kit2': return isTr ? 'Bozulmayan gıdalar' : 'Non-perishable food';
      case 'kit3': return isTr ? 'Pilli radyo' : 'Battery-powered radio';
      case 'kit4': return isTr ? 'El feneri ve yedek piller' : 'Flashlight and extra batteries';
      case 'kit5': return isTr ? 'İlk yardım çantası' : 'First aid kit';
      case 'kit6': return isTr ? 'Düdük' : 'Whistle';
      case 'kit7': return isTr ? 'Toz maskesi' : 'Dust mask';
      case 'kit8': return isTr ? 'Nemli bezler ve çöp torbaları' : 'Moist towelettes and garbage bags';
      case 'kit9': return isTr ? 'İngiliz anahtarı veya pense' : 'Wrench or pliers';
      case 'kit10': return isTr ? 'Manuel konserve açacağı' : 'Manual can opener';
      case 'kit11': return isTr ? 'Yerel haritalar' : 'Local maps';
      case 'kit12': return isTr ? 'Cep telefonu ve yedek şarj cihazı' : 'Cell phone and extra charger';
      case 'kit13': return isTr ? 'Reçeteli ilaçlar' : 'Prescription medications';
      case 'kit14': return isTr ? 'Gözlük ve lens solüsyonu' : 'Glasses and contact lens solution';
      case 'kit15': return isTr ? 'Bebek maması ve bezi' : 'Infant formula and diapers';
      case 'kit16': return isTr ? 'Evcil hayvan maması ve suyu' : 'Pet food and water';
      case 'kit17': return isTr ? 'Önemli evrak kopyaları' : 'Copies of important documents';
      case 'kit18': return isTr ? 'Nakit para ve bozuk para' : 'Cash and coins';
      case 'kit19': return isTr ? 'Uyku tulumu veya battaniye' : 'Sleeping bag or blanket';
      case 'kit20': return isTr ? 'Kıyafet ve sağlam ayakkabı' : 'Change of clothes and sturdy shoes';
      default: return key;
    }
  }

  double _simulatorMagnitude = 6.0;

  Widget _buildGuideTab(AppLocalizations l, bool isDark, Color cardColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // EMERGENCY TOOLS START
        Text(l.localeName == 'tr' ? 'Acil Durum Araçları' : 'Emergency Tools', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? _onSurface : const Color(0xFF191C1D), letterSpacing: -0.01)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildEmergencyToolsButton(
                icon: Icons.sos,
                label: l.localeName == 'tr' ? 'Güvendeyim' : 'I am safe',
                color: _tertiary.withValues(alpha: 0.7),
                onTap: _sendImSafeMessage,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildEmergencyToolsButton(
                icon: _isSirenActive ? Icons.volume_off : Icons.volume_up,
                label: _isSirenActive ? (l.localeName == 'tr' ? 'Siren Kapat' : 'Siren Off') : (l.localeName == 'tr' ? 'Siren Aç' : 'Siren On'),
                color: _isSirenActive ? _surfaceHigh : _primaryContainer,
                onTap: _toggleSirenVibration,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        // EMERGENCY TOOLS END

        // === QUICK ACCESS TOOLS GRID (FROM STITCH) ===
        Text(l.localeName == 'tr' ? 'Hızlı Erişim' : 'Quick Access', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? _onSurface : const Color(0xFF191C1D), letterSpacing: -0.01)),
        const SizedBox(height: 4),
        Text(l.localeName == 'tr' ? 'Acil durum araçlarına hızlıca ulaşın.' : 'Quickly access emergency tools.', style: TextStyle(color: isDark ? _onSurfaceVariant : const Color(0xFF45474D), fontSize: 13)),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
          children: [             _buildQuickToolCard(Icons.family_restroom, l.localeName == 'tr' ? 'Aile Takibi' : 'Family Tracker', isDark, cardColor, _primary),
            _buildQuickToolCard(Icons.domain, l.localeName == 'tr' ? 'Bina Sağlığı' : 'Structural Health', isDark, cardColor, _secondary),
            _buildQuickToolCard(Icons.map, l.localeName == 'tr' ? 'Tahliye Planı' : 'Evacuation Plan', isDark, cardColor, _tertiary),
            _buildQuickToolCard(Icons.volunteer_activism, l.localeName == 'tr' ? 'Bağış Merkezleri' : 'Donation Centers', isDark, cardColor, _primaryContainer),
            _buildQuickToolCard(Icons.location_off, l.localeName == 'tr' ? 'Çevrimdışı\nHaritalar' : 'Offline\nMaps', isDark, cardColor, _outline),
          ],
        ),
        const SizedBox(height: 32),

        // === EARTHQUAKE SIMULATOR (FROM STITCH) ===
        Text(l.localeName == 'tr' ? 'Deprem Simülatörü' : 'Earthquake Simulator', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? _onSurface : const Color(0xFF191C1D), letterSpacing: -0.01)),
        const SizedBox(height: 4),
        Text(l.localeName == 'tr' ? 'Sarsıntı şiddetini test edin ve güvenlik protokollerini öğrenin.' : 'Test earthquake intensity and learn safety protocols.', style: TextStyle(color: isDark ? _onSurfaceVariant : const Color(0xFF45474D), fontSize: 13)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05), blurRadius: 40, spreadRadius: -10, offset: const Offset(0, 8))],
          ),
          child: Column(
            children: [
              // Magnitude display
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getMagnitudeColor(_simulatorMagnitude).withValues(alpha: 0.15),
                  border: Border.all(color: _getMagnitudeColor(_simulatorMagnitude), width: 3),
                  boxShadow: [BoxShadow(color: _getMagnitudeColor(_simulatorMagnitude).withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 2)],
                ),
                child: Center(
                  child: Text(
                    _simulatorMagnitude.toStringAsFixed(1),
                    style: TextStyle(color: _getMagnitudeColor(_simulatorMagnitude), fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: -0.02),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text("M ${_simulatorMagnitude.toStringAsFixed(1)} - ${_getSimulatorLabel(l)}", style: TextStyle(color: isDark ? _onSurface : const Color(0xFF191C1D), fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Text(_getSimulatorDescription(l), textAlign: TextAlign.center, style: TextStyle(color: isDark ? _onSurfaceVariant : const Color(0xFF45474D), fontSize: 13, height: 1.5)),
              const SizedBox(height: 16),
              Slider(
                value: _simulatorMagnitude,
                min: 2.0, max: 9.0, divisions: 14,
                activeColor: _getMagnitudeColor(_simulatorMagnitude),
                inactiveColor: isDark ? _surfaceBright : const Color(0xFFE7E8E9),
                onChanged: (val) => setState(() => _simulatorMagnitude = val),
              ),
              const SizedBox(height: 16),
              // Safety protocols
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildProtocolStep(Icons.arrow_downward, l.localeName == 'tr' ? 'Çök' : 'Drop', isDark),
                  _buildProtocolStep(Icons.shield, l.localeName == 'tr' ? 'Kapan' : 'Cover', isDark),
                  _buildProtocolStep(Icons.back_hand, l.localeName == 'tr' ? 'Tutun' : 'Hold', isDark),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // === EMERGENCY KIT CHECKLIST (FROM STITCH) ===
        Text(l.localeName == 'tr' ? 'Acil Durum Çantası' : 'Emergency Kit', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? _onSurface : const Color(0xFF191C1D), letterSpacing: -0.01)),
        const SizedBox(height: 4),
        Text(l.localeName == 'tr' ? 'Afet sonrası hayatta kalmak için çantanızı hazırlayın.' : 'Prepare your bag to survive after a disaster.', style: TextStyle(color: isDark ? _onSurfaceVariant : const Color(0xFF45474D), fontSize: 13)),
        const SizedBox(height: 12),
        // Progress bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${_kitItems.values.where((v) => v).length} / ${_kitItems.length} ${l.localeName == 'tr' ? 'Hazır' : 'Ready'}", style: TextStyle(color: isDark ? _onSurface : const Color(0xFF191C1D), fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("${((_kitItems.values.where((v) => v).length / _kitItems.length) * 100).toStringAsFixed(0)}%", style: TextStyle(color: _tertiary, fontWeight: FontWeight.w900, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _kitItems.values.where((v) => v).length / _kitItems.length,
                  backgroundColor: isDark ? _surfaceBright : const Color(0xFFE7E8E9),
                  valueColor: AlwaysStoppedAnimation<Color>(_tertiary),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ..._kitItems.entries.map((entry) => Container(
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: CheckboxListTile(
            value: entry.value,
            onChanged: (val) { setState(() => _kitItems[entry.key] = val ?? false); _saveSettings(); },
            title: Text(_getKitItemLabel(entry.key, l), style: TextStyle(
              color: entry.value ? (isDark ? _onSurfaceVariant : const Color(0xFF45474D)) : (isDark ? _onSurface : const Color(0xFF191C1D)),
              fontWeight: entry.value ? FontWeight.normal : FontWeight.w600,
              decoration: entry.value ? TextDecoration.lineThrough : null,
              fontSize: 14,
            )),
            activeColor: _tertiary,
            checkColor: Colors.black,
            dense: true,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        )),
        const SizedBox(height: 32),

        // === SURVIVAL GUIDE (ORIGINAL) ===
        Text(l.guideTitle ?? "Emergency Survival Guide", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? _onSurface : const Color(0xFF191C1D), letterSpacing: -0.01)),
        const SizedBox(height: 16),
        _buildGuideCard(cardColor, isDark, l.guide1Title ?? "1. DROP, COVER, HOLD ON", l.guide1Desc ?? "...", Icons.accessibility_new),
        _buildGuideCard(cardColor, isDark, l.guide2Title ?? "2. STAY INDOORS", l.guide2Desc ?? "...", Icons.house),
        _buildGuideCard(cardColor, isDark, l.guide3Title ?? "3. STAY AWAY FROM GLASS", l.guide3Desc ?? "...", Icons.dangerous),
        _buildGuideCard(cardColor, isDark, l.guide4Title ?? "4. IF TRAPPED", l.guide4Desc ?? "...", Icons.pan_tool),
      ],
    );
  }

  Widget _buildQuickToolCard(IconData icon, String label, bool isDark, Color cardColor, Color accentColor) {
    return GestureDetector(
      onTap: () => _showToolPage(label.replaceAll('\n', ' '), icon, accentColor),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentColor.withValues(alpha: 0.2)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04), blurRadius: 20, spreadRadius: -5)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: TextStyle(color: isDark ? _onSurface : const Color(0xFF191C1D), fontWeight: FontWeight.w600, fontSize: 11, height: 1.2)),
          ],
        ),
      ),
    );
  }

  void _showToolPage(String title, IconData icon, Color accentColor) {
    final l = AppLocalizations.of(context)!;
    final content = _getToolContent(title, l);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: _surfaceHigh,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 5, decoration: BoxDecoration(color: _outline.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Icon(icon, color: accentColor, size: 36),
              ),
              const SizedBox(height: 12),
              Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _onSurface)),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: content,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _getToolContent(String title, AppLocalizations l) {
    final familyTitle = l.localeName == 'tr' ? 'Aile Takibi' : 'Family Tracker';
    final structTitle = l.localeName == 'tr' ? 'Bina Sağlığı' : 'Structural Health';
    final evacTitle = l.localeName == 'tr' ? 'Tahliye Planı' : 'Evacuation Plan';
    final donTitle = l.localeName == 'tr' ? 'Bağış Merkezleri' : 'Donation Centers';
    final simTitle = l.localeName == 'tr' ? 'Deprem Simülatörü' : 'Earthquake Simulator';
    final offTitle = l.localeName == 'tr' ? 'Çevrimdışı Haritalar' : 'Offline Maps';
     if (title == familyTitle) {
      return [
        _toolInfoCard(l.localeName == 'tr' ? 'Aile üyelerinizin durumunu takip edin.' : 'Track your family members\' status.', Icons.family_restroom),
        const SizedBox(height: 12),
        ..._contactControllers.asMap().entries.where((e) => e.value.text.isNotEmpty).map((e) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: _surfaceHighest, borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: _tertiary.withValues(alpha: 0.15), shape: BoxShape.circle), child: Icon(Icons.person, color: _tertiary, size: 20)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("${l.localeName == 'tr' ? 'Kişi' : 'Person'} ${e.key + 1}", style: TextStyle(color: _onSurface, fontWeight: FontWeight.bold)),
              Text(e.value.text, style: TextStyle(color: _onSurfaceVariant, fontSize: 13)),
            ])),
            Icon(Icons.check_circle, color: _tertiary, size: 20),
          ]),
        )),
        if (_contactControllers.every((c) => c.text.isEmpty))
          _toolInfoCard(l.localeName == 'tr' ? 'Acil durum kişisi eklenmemiş.' : 'No emergency contacts added.', Icons.warning_amber, color: _secondaryContainer),
      ];
    } else if (title == structTitle) {
      return [
        _toolInfoCard(l.localeName == 'tr' ? 'Bina Yapısal Sağlık Analizi' : 'Structural Health Analysis', Icons.domain),
        const SizedBox(height: 12),
        _buildEditableReportItem(l.localeName == 'tr' ? 'Bina Yaşı' : 'Building Age', _binaYasiController, Icons.calendar_today),
        _buildEditableReportItem(l.localeName == 'tr' ? 'Kat Sayısı' : 'Floor Count', _katSayisiController, Icons.layers),
        _buildEditableReportItem(l.localeName == 'tr' ? 'Bina Tipi' : 'Building Type', _binaTipiController, Icons.foundation),
        _buildEditableReportItem(l.localeName == 'tr' ? 'Zemin Tipi' : 'Ground Type', _zeminTipiController, Icons.terrain),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: _secondaryContainer.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            Icon(Icons.info, color: _secondaryContainer),
            const SizedBox(width: 12),
            Expanded(child: Text(l.localeName == 'tr' ? 'Binanızın yapısal durumunu uzmanlara kontrol ettirin.' : 'Have your building\'s structural status checked by experts.', style: TextStyle(color: _onSurfaceVariant, fontSize: 13))),
          ]),
        ),
      ];
    } else if (title == evacTitle) {
      return [
        _toolInfoCard(l.localeName == 'tr' ? 'Tahliye Planı' : 'Evacuation Plan', Icons.map),
        const SizedBox(height: 12),
        _buildEditableReportItem(l.localeName == 'tr' ? 'Ev Çıkışı' : 'Home Exit', _evCikisiController, Icons.door_front_door),
        _buildEditableReportItem(l.localeName == 'tr' ? 'Toplanma Noktası' : 'Assembly Point', _toplanmaNoktasiController, Icons.location_on),
        _buildEditableReportItem(l.localeName == 'tr' ? 'Alternatif Rota' : 'Alternate Route', _alternatifRotaController, Icons.alt_route),
        _buildEditableReportItem(l.localeName == 'tr' ? 'Buluşma Noktası' : 'Meeting Point', _bulusmaNoktasiController, Icons.people),
      ];
    } else if (title == donTitle) {
      return [
        _toolInfoCard(l.localeName == 'tr' ? 'Yardım kuruluşlarına bağış yapın.' : 'Donate to aid organizations.', Icons.volunteer_activism),
        const SizedBox(height: 12),
        _buildDonationItem("Kızılay", "kizilay.org.tr", "https://www.kizilay.org.tr"),
        _buildDonationItem("AFAD", "afad.gov.tr", "https://www.afad.gov.tr"),
        _buildDonationItem("AHBAP", "ahbap.org", "https://ahbap.org"),
      ];
    } else if (title == simTitle) {
      Navigator.pop(context);
      return [];
    } else if (title == offTitle) {
      return [
        _toolInfoCard(l.localeName == 'tr' ? 'Çevrimdışı harita verilerini yönetin.' : 'Manage offline map data.', Icons.location_off),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: _surfaceHighest, borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.localeName == 'tr' ? 'Önbellek Durumu' : 'Cache Status', style: TextStyle(color: _onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: 0.3, backgroundColor: _surfaceBright, valueColor: AlwaysStoppedAnimation<Color>(_tertiary), minHeight: 6),
            const SizedBox(height: 8),
            Text(l.localeName == 'tr' ? 'Harita verileri önbelleğe alındı.' : 'Map data is cached.', style: TextStyle(color: _onSurfaceVariant, fontSize: 13)),
          ]),
        ),
      ];
    }
    return [_toolInfoCard(l.localeName == 'tr' ? 'Yakında' : 'Coming Soon', Icons.construction)];
  }

  Widget _toolInfoCard(String text, IconData icon, {Color? color}) {
    final c = color ?? _primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Icon(icon, color: c, size: 28),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: TextStyle(color: _onSurface, fontSize: 14, height: 1.4))),
      ]),
    );
  }

  Widget _buildEditableReportItem(String title, TextEditingController controller, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: _surfaceHighest, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Icon(icon, color: _onSurfaceVariant, size: 22),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: _onSurface, fontWeight: FontWeight.bold, fontSize: 15)),
          TextField(
            controller: controller,
            style: TextStyle(color: _onSurfaceVariant, fontSize: 13),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 4),
              border: InputBorder.none,
            ),
            onChanged: (val) => _saveSettings(),
          ),
        ])),
        Icon(Icons.edit, color: _outline, size: 18),
      ]),
    );
  }

  Widget _buildReportItem(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _surfaceHighest, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Icon(icon, color: _onSurfaceVariant, size: 22),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: _onSurface, fontWeight: FontWeight.bold, fontSize: 15)),
          Text(subtitle, style: TextStyle(color: _onSurfaceVariant, fontSize: 13)),
        ])),
        Icon(Icons.chevron_right, color: _outline),
      ]),
    );
  }

  Widget _buildDonationItem(String name, String desc, String url) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: _surfaceHighest, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: _primaryContainer.withValues(alpha: 0.15), shape: BoxShape.circle), child: Icon(Icons.favorite, color: _primaryContainer, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: TextStyle(color: _onSurface, fontWeight: FontWeight.bold, fontSize: 15)),
            Text(desc, style: TextStyle(color: _onSurfaceVariant, fontSize: 13)),
          ])),
          Icon(Icons.open_in_new, color: _primaryContainer, size: 18),
        ]),
      ),
    );
  }

  Widget _buildProtocolStep(IconData icon, String label, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _primaryContainer.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: _primaryContainer, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: isDark ? _onSurface : const Color(0xFF191C1D), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.1)),
      ],
    );
  }

  String _getSimulatorLabel(AppLocalizations l) {
    if (_simulatorMagnitude < 3.0) return l.localeName == 'tr' ? 'Mikro' : 'Micro';
    if (_simulatorMagnitude < 4.0) return l.localeName == 'tr' ? 'Hafif' : 'Light';
    if (_simulatorMagnitude < 5.0) return l.localeName == 'tr' ? 'Orta' : 'Moderate';
    if (_simulatorMagnitude < 6.0) return l.localeName == 'tr' ? 'Güçlü' : 'Strong';
    if (_simulatorMagnitude < 7.0) return l.localeName == 'tr' ? 'Çok Güçlü' : 'Very Strong';
    if (_simulatorMagnitude < 8.0) return l.localeName == 'tr' ? 'Büyük' : 'Major';
    return l.localeName == 'tr' ? 'Devasa' : 'Great';
  }

  String _getSimulatorDescription(AppLocalizations l) {
    if (_simulatorMagnitude < 3.0) return l.localeName == 'tr' ? 'Hissedilmeyebilir' : 'May not be felt';
    if (_simulatorMagnitude < 4.0) return l.localeName == 'tr' ? 'Hafif sarsıntı' : 'Light shaking';
    if (_simulatorMagnitude < 5.0) return l.localeName == 'tr' ? 'Belirgin sarsıntı' : 'Moderate shaking';
    if (_simulatorMagnitude < 6.0) return l.localeName == 'tr' ? 'Eşyalar devrilebilir' : 'Strong shaking';
    if (_simulatorMagnitude < 7.0) return l.localeName == 'tr' ? 'Ciddi hasar riski' : 'Very strong shaking';
    if (_simulatorMagnitude < 8.0) return l.localeName == 'tr' ? 'Yıkıcı etki' : 'Major destruction';
    return l.localeName == 'tr' ? 'Felaket düzeyinde' : 'Great destruction';
  }

  Widget _buildEmergencyToolsButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, height: 1.2)),
          ],
        ),
      ),
    );
  }

  Future<void> _sendImSafeMessage() async {
    final l = AppLocalizations.of(context)!;
    final prefs = await SharedPreferences.getInstance();
    final contacts = [
      prefs.getString('contact0') ?? '',
      prefs.getString('contact1') ?? '',
      prefs.getString('contact2') ?? '',
    ].where((c) => c.trim().isNotEmpty).toList();

    if (contacts.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.localeName == 'tr' ? 'Acil durum kişisi ekleyin' : 'Add emergency contacts')));
      return;
    }

    String message = l.localeName == 'tr' ? 'Güvendeyim!' : 'I am safe!';
    if (_isLocationReady) {
      message += " ${l.localeName == 'tr' ? 'Son Konum' : 'Last Location'}: https://maps.google.com/?q=${_center.latitude},${_center.longitude}";
    }

    final String phones = contacts.join(',');
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phones,
      queryParameters: <String, String>{
        'body': message,
      },
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.localeName == 'tr' ? 'SMS gönderilemedi' : 'SMS failed')));
    }
  }

  void _toggleSirenVibration() async {
    if (_isSirenActive) {
      FlutterRingtonePlayer().stop();
      _vibrationTimer?.cancel();
      setState(() => _isSirenActive = false);
    } else {
      FlutterRingtonePlayer().playAlarm(looping: true, volume: 1.0, asAlarm: true);
      _vibrationTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        HapticFeedback.heavyImpact();
      });
      setState(() => _isSirenActive = true);
    }
  }
  
  Widget _buildGuideCard(Color bg, bool isDark, String title, String desc, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: isDark ? _primaryContainer : const Color(0xFFBA1A1A)),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? _onSurface : Colors.black)),
              const SizedBox(height: 4),
              Text(desc, style: TextStyle(color: isDark ? _onSurfaceVariant : const Color(0xFF45474D))),
            ],
          ))
        ],
      ),
    );
  }

  Widget _buildSettingsTab(AppLocalizations l, bool isDark, Color cardColor) {
    final textColor = isDark ? _onSurface : const Color(0xFF191C1D);
    final subColor = isDark ? _onSurfaceVariant : const Color(0xFF45474D);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Magnitude Filter
        Text(l.filterMagnitudeTitle ?? "Notification Filter (Magnitude)", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 8),
        Text("${l.filterMagnitudeDesc ?? 'Show earthquakes above magnitude:'} ${_minMagnitude.toStringAsFixed(1)}", style: TextStyle(color: subColor)),
        Slider(
          value: _minMagnitude,
          min: 1.0, max: 8.0, divisions: 14,
          activeColor: _primaryContainer,
          onChanged: (val) => setState(() => _minMagnitude = val),
          onChangeEnd: (val) => _saveSettings(),
        ),
        const SizedBox(height: 24),
        
        // Radius Filter
        Text(l.filterRadiusTitle ?? "Coverage Radius", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 8),
        Text("${l.filterRadiusDesc ?? 'Alert me for earthquakes within:'} ${_notificationRadius.toStringAsFixed(0)} km", style: TextStyle(color: subColor)),
        Slider(
          value: _notificationRadius,
          min: 50.0, max: 500.0, divisions: 9,
          activeColor: const Color(0xFFBA1A1A),
          onChanged: (val) => setState(() => _notificationRadius = val),
          onChangeEnd: (val) => _saveSettings(),
        ),
        const SizedBox(height: 24),

        // Appearance & Sound Adjustments
        Text(l.preferencesTitle ?? "Preferences", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 8),

        SwitchListTile(
          title: Text(l.soundTitle ?? "Sound Notifications", style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
          contentPadding: EdgeInsets.zero,
          activeThumbColor: const Color(0xFFBA1A1A),
          value: _soundEnabled,
          onChanged: (val) { setState(() => _soundEnabled = val); _saveSettings(); },
        ),
        const SizedBox(height: 24),

        // Emergency Contacts
        Text(l.emergencyContactsTitle ?? "Emergency Contacts", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 8),
        Text(l.emergencyContactsDesc ?? "Phone numbers to notify during an SOS event", style: TextStyle(color: subColor, fontSize: 13)),
        const SizedBox(height: 12),
        ...List.generate(3, (idx) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextField(
            controller: _contactControllers[idx],
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: "${l.contactHint ?? 'Contact Phone'} ${idx+1}",
              hintStyle: TextStyle(color: subColor),
              filled: true,
              fillColor: cardColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              prefixIcon: Icon(Icons.phone, color: subColor),
              suffixIcon: IconButton(
                icon: Icon(Icons.contacts, color: _primaryContainer),
                onPressed: () => _pickContactFromList(idx, isDark),
                tooltip: l.localeName == 'tr' ? 'Kişi Seç' : 'Select Contact',
              ),
            ),
            keyboardType: TextInputType.phone,
            onSubmitted: (_) => _saveSettings(),
          ),
        )),

        const SizedBox(height: 24),

        // Saved Locations
        Text(l.localeName == 'tr' ? 'Kayıtlı Adresler' : 'Saved Addresses', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _addressController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: l.localeName == 'tr' ? 'Adres Takip Et' : 'Track Address',
                  hintStyle: TextStyle(color: subColor),
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  prefixIcon: Icon(Icons.location_city, color: subColor)
                ),
                onSubmitted: (_) => _addNewLocation(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.add_circle, size: 44, color: _primaryContainer),
              onPressed: _addNewLocation,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._savedLocations.map((loc) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(Icons.home, color: isDark ? Colors.white : Colors.black),
            title: Text(loc.name.toUpperCase(), style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            subtitle: Text("${loc.latitude.toStringAsFixed(2)}, ${loc.longitude.toStringAsFixed(2)}", style: TextStyle(color: subColor, fontSize: 12)),
            trailing: IconButton(icon: Icon(Icons.delete, color: _primaryContainer), onPressed: () => _deleteLocation(loc.name)),
          ),
        )),

        const SizedBox(height: 24),

        // Languages
        Text(l.languageSettings ?? "Language Settings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ExpansionTile(
              title: Text(l.localeName == 'tr' ? 'Uygulama Dilini Seç' : 'Select App Language', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
              leading: Icon(Icons.language, color: isDark ? _primary : const Color(0xFF2D0003)),
              iconColor: textColor,
              collapsedIconColor: textColor,
              backgroundColor: cardColor,
              collapsedBackgroundColor: cardColor,
              children: [
                _buildLanguageOption("Türkçe", "🇹🇷", "tr", isDark),
                _buildLanguageOption("English", "🇬🇧", "en", isDark),
                _buildLanguageOption("日本語 (Japanese)", "🇯🇵", "ja", isDark),
                _buildLanguageOption("Français (French)", "🇫🇷", "fr", isDark),
                _buildLanguageOption("Deutsch (German)", "🇩🇪", "de", isDark),
                _buildLanguageOption("Español (Spanish)", "🇪🇸", "es", isDark),
                _buildLanguageOption("Русский (Russian)", "🇷🇺", "ru", isDark),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickContactFromList(int index, bool isDark) async {
    final l = AppLocalizations.of(context)!;
    var status = await Permission.contacts.request();
    if (status.isGranted) {
      setState(() => _isLoading = true);
      List<Contact> contacts = await FastContacts.getAllContacts();
      setState(() => _isLoading = false);

      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        backgroundColor: isDark ? const Color(0xFF191C1D) : Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (context) {
          return Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 16),
              Text(l.localeName == 'tr' ? 'Kişi Seç' : 'Select Contact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, i) {
                    final c = contacts[i];
                    final phones = c.phones;
                    if (phones.isEmpty) return const SizedBox.shrink();
                    final displayName = c.displayName.isNotEmpty ? c.displayName : (l.localeName == 'tr' ? 'İsimsiz' : 'Unnamed');
                    final firstLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
                    final number = phones.first.number;
                    
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFBA1A1A).withValues(alpha: 0.2),
                        child: Text(firstLetter, style: const TextStyle(color: Color(0xFFBA1A1A), fontWeight: FontWeight.bold)),
                      ),
                      title: Text(displayName, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600)),
                      subtitle: Text(number, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                      onTap: () {
                        _contactControllers[index].text = number;
                        _saveSettings();
                        Navigator.pop(context);
                      },
                    );
                  }
                ),
              ),
            ],
          );
        }
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.localeName == 'tr' ? 'Kişi erişim izni reddedildi' : 'Contacts permission denied'), backgroundColor: const Color(0xFFBA1A1A))
      );
    }
  }

  Widget _buildLanguageOption(String name, String flag, String code, bool isDark) {
    bool isSelected = LocaleProvider.currentLanguage == code;
    return InkWell(
      onTap: () { LocaleProvider.changeLocale(code); setState(() {}); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isSelected ? _primaryContainer.withValues(alpha: 0.15) : Colors.transparent,
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isDark ? Colors.white : const Color(0xFF191C1D), fontFamily: 'Roboto'),
                child: Text(name),
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: _primaryContainer),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTab(AppLocalizations l, bool isDark, Color cardColor) {
    bool isAreaSafe = true;
    if (_earthquakes.isNotEmpty) {
      isAreaSafe = _earthquakes.first.mag < 4.0;
    }

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isAreaSafe ? cardColor : _primaryContainer.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 40, spreadRadius: -10, offset: const Offset(0, 10))]
          ),
          child: Row(
            children: [
              Icon(isAreaSafe ? Icons.check_circle : Icons.warning, color: isAreaSafe ? _tertiary : _primaryContainer, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isAreaSafe ? (l.areaSafe ?? "Area Safe") : (l.seismicAlert ?? "Seismic Alert"), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? _onSurface : const Color(0xFF191C1D))),
                    const SizedBox(height: 4),
                    Text(isAreaSafe ? (l.noSeismicActivity ?? "Safe") : (l.significantActivity ?? "Alert"), style: TextStyle(fontSize: 14, color: isDark ? _onSurfaceVariant : const Color(0xFF45474D), height: 1.4)),
                  ],
                ),
              )
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildFilterChip(l.live ?? 'Live', DataType.live, isDark),
              const SizedBox(width: 8),
              _buildFilterChip(l.history ?? 'History', DataType.history, isDark),
              const SizedBox(width: 8),
              _buildFilterChip(l.news ?? 'News', DataType.news, isDark),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        Expanded(
          child: _currentDataType == DataType.news 
            ? ListView(children: _buildNewsListItems(l, isDark, cardColor))
            : ListView(children: _buildEarthquakeListItems(l, isDark, cardColor)),
        )
      ],
    );
  }

  Widget _buildFilterChip(String label, DataType type, bool isDark) {
    final isSelected = _currentDataType == type;
    final txtColor = isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF45474D));
    return InkWell(
      onTap: () => _onCategoryChanged(type),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.transparent : _outline.withValues(alpha: 0.4)),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(color: txtColor, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontFamily: 'Roboto'),
          child: Text(label),
        ),
      ),
    );
  }

  String _getMapUrl(bool isDark) {
    if (_mapStyle == 'satellite') return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
    if (_mapStyle == 'topo') return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}';
    return isDark 
        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png' 
        : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png';
  }

  Widget _buildMapTab(AppLocalizations l, bool isDark) {
    final tUrl = _getMapUrl(isDark);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(initialCenter: _center, initialZoom: 8.5),
          children: [
            TileLayer(
              urlTemplate: tUrl, 
              userAgentPackageName: 'com.example.depremanlik',
              subdomains: const ['a', 'b', 'c', 'd'],
            ),
            CircleLayer(
              circles: [
                CircleMarker(
                  point: _center,
                  color: const Color(0xFFBA1A1A).withValues(alpha: 0.05),
                  borderStrokeWidth: 2,
                  borderColor: const Color(0xFFBA1A1A).withValues(alpha: 0.3),
                  useRadiusInMeter: true,
                  radius: _notificationRadius * 1000, 
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: _center,
                  width: 50, height: 50,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                       Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.2), shape: BoxShape.circle)),
                       Container(width: 20, height: 20, decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3))),
                    ]
                  ),
                ),
                ..._savedLocations.map((loc) => Marker(
                  point: LatLng(loc.latitude, loc.longitude),
                  width: 44, height: 44,
                  child: GestureDetector(
                    onTap: () {
                      _animatedMapMove(LatLng(loc.latitude, loc.longitude), 8.5);
                    },
                    child: Container(
                      decoration: BoxDecoration(color: const Color(0xFF4B664A).withValues(alpha: 0.9), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2.0)),
                      child: const Center(child: Icon(Icons.home, color: Colors.white, size: 20)),
                    ),
                  ),
                )),
                ...(_currentDataType == DataType.news ? <Earthquake>[] : _earthquakes.take(100)).map((eq) => Marker(
                  point: LatLng(eq.latitude, eq.longitude),
                  width: 44, height: 44,
                  child: GestureDetector(
                    onTap: () => _showEarthquakeDetails(eq, l, isDark),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getMagnitudeColor(eq.mag).withValues(alpha: 0.9), 
                        shape: BoxShape.circle, 
                        border: Border.all(color: isDark ? _bgColor : Colors.white, width: 2.0),
                      ),
                      child: Center(child: Text(eq.mag.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                    ),
                  ),
                )),
              ]
            ),
          ],
        ),
        
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildMapFilterChip(l.live ?? 'Live', DataType.live, isDark),
                const SizedBox(width: 8),
                _buildMapFilterChip(l.history ?? 'History', DataType.history, isDark),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF25292A).withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFC5C6CD)),
                  ),
                  child: PopupMenuButton<String>(
                    tooltip: l.mapTab,
                    icon: Icon(Icons.layers, color: isDark ? Colors.white : const Color(0xFF45474D), size: 20),
                    onSelected: (String result) {
                      setState(() { _mapStyle = result; });
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(value: 'satellite', child: Text('🛰️ Uydu (Satellite)', style: TextStyle(fontWeight: FontWeight.bold))),
                      const PopupMenuItem<String>(value: 'topo', child: Text('🏔️ Arazi (Topo)')),
                      const PopupMenuItem<String>(value: 'standard', child: Text('🗺️ Sade (Standart)')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Animated Saved Locations Menu at Bottom
        if (_savedLocations.isNotEmpty)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(l.localeName == 'tr' ? 'Kayıtlı Adresler' : 'Saved Addresses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white70 : const Color(0xFF191C1D))),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _savedLocations.length,
                    itemBuilder: (context, index) {
                      final loc = _savedLocations[index];
                      final isSelected = _center.latitude == loc.latitude && _center.longitude == loc.longitude;
                      return GestureDetector(
                        onTap: () {
                          _animatedMapMove(LatLng(loc.latitude, loc.longitude), 8.5);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.fastOutSlowIn,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFBA1A1A) : (isDark ? const Color(0xFF25292A) : Colors.white),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected ? const Color(0xFFBA1A1A).withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.1),
                                blurRadius: isSelected ? 12 : 6,
                                offset: const Offset(0, 4)
                              )
                            ],
                            border: Border.all(color: isSelected ? Colors.transparent : const Color(0xFFE7E8E9).withValues(alpha: isDark ? 0.1 : 1.0))
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFFBA1A1A)), size: 18),
                              const SizedBox(width: 8),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  color: isSelected ? Colors.white : (isDark ? Colors.white : const Color(0xFF191C1D)),
                                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                                  fontFamily: 'Roboto',
                                  fontSize: 14,
                                ),
                                child: Text(loc.name.toUpperCase()),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    setState(() => _center = destLocation);
    // Removed _fetchData() to prevent building during the animation frame. 
    // This dramatically improves 60fps scrolling and panning performance.
    // Animate map controller smoothly
    final latTween = Tween<double>(begin: _mapController.camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(begin: _mapController.camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: _mapController.camera.zoom, end: destZoom);

    final controller = AnimationController(duration: const Duration(milliseconds: 750), vsync: Navigator.of(context));
    // Provide a curved animation for elasticity
    final Animation<double> animation = CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });
    controller.forward();
  }

  Widget _buildMapFilterChip(String label, DataType type, bool isDark) {
    final isSelected = _currentDataType == type;
    final bg = isSelected ? const Color(0xFFBA1A1A) : (isDark ? const Color(0xFF25292A) : Colors.white);
    final shadow = isDark ? Colors.black45 : Colors.black12;
    return InkWell(
      onTap: () => _onCategoryChanged(type),
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? Colors.transparent : (isDark ? Colors.transparent : const Color(0xFFE7E8E9))),
          boxShadow: isSelected ? [] : [BoxShadow(color: shadow, blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF45474D)), fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontFamily: 'Roboto'),
          child: Text(label),
        ),
      ),
    );
  }

  void _showEarthquakeDetails(Earthquake eq, AppLocalizations l, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: isDark ? const Color(0xFF191C1D) : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: const Color(0xFFE7E8E9), borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(color: _getMagnitudeColor(eq.mag).withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: Center(child: Text(eq.mag.toStringAsFixed(1), style: TextStyle(color: _getMagnitudeColor(eq.mag), fontWeight: FontWeight.w900, fontSize: 22))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(eq.title == 'Bilinmeyen Konum' ? (l.localeName == 'tr' ? 'Bilinmeyen Konum' : 'Unknown Location') : eq.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF191C1D)), maxLines: 2),
                          const SizedBox(height: 4),
                          Text(DateFormat('dd.MM.yyyy - HH:mm:ss').format(eq.date), style: TextStyle(color: isDark ? const Color(0xFFC5C6CD) : const Color(0xFF45474D), fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildEqStat(Icons.straighten, l.depth, "${eq.depth.toStringAsFixed(1)} km", isDark),
                    Container(width: 1, height: 40, color: const Color(0xFFE7E8E9)),
                    _buildEqStat(Icons.radar, l.distance, "${(eq.distance / 1000).toStringAsFixed(1)} km", isDark),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildEqStat(IconData icon, String label, String val, bool isDark) {
    return Column(
      children: [
        Icon(icon, color: isDark ? const Color(0xFFC5C6CD) : const Color(0xFF45474D)),
        const SizedBox(height: 8),
        Text(val, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF191C1D))),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: isDark ? const Color(0xFFC5C6CD) : const Color(0xFF45474D), fontSize: 12)),
      ],
    );
  }

  List<Widget> _buildEarthquakeListItems(AppLocalizations l, bool isDark, Color cardColor) {
    if (_earthquakes.isEmpty && !_isLoading) {
      return [Padding(padding: const EdgeInsets.all(32), child: Center(child: Text(l.noData, style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF45474D)))))];
    }
    final List<Widget> items = [];
    for (int i = 0; i < _earthquakes.length; i++) {
      final eq = _earthquakes[i];
      final color = _getMagnitudeColor(eq.mag);
      
      items.add(
        GestureDetector(
          key: ValueKey('eq_${eq.id}_$i'),
          onTap: () => _showEarthquakeDetails(eq, l, isDark),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 30, spreadRadius: -8, offset: const Offset(0, 6))]
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle, border: Border.all(color: color.withValues(alpha: 0.4), width: 2)),
                      child: Center(child: Text(eq.mag.toStringAsFixed(1), style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(eq.title == 'Bilinmeyen Konum' ? (l.localeName == 'tr' ? 'Bilinmeyen Konum' : 'Unknown Location') : eq.title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: _onSurface), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 6),
                          Text("${DateFormat('dd.MM.yyyy HH:mm').format(eq.date)} • ${(eq.distance / 1000).toStringAsFixed(1)} km", style: TextStyle(color: _onSurfaceVariant, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${eq.depth.toStringAsFixed(1)} km ${l.depth}", style: TextStyle(color: _outline, fontSize: 12)),
                    TextButton.icon(
                      onPressed: () => _showEarthquakeDetails(eq, l, isDark),
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: Text(l.localeName == 'tr' ? 'Detay' : 'Detail'),
                      style: TextButton.styleFrom(iconColor: _primaryContainer, foregroundColor: _primaryContainer),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
      
      // Her depremden sonra reklam ekle
      items.add(NativeAdCard(key: ValueKey('ad_eq_$i')));
    }
    return items;
  }

  List<Widget> _buildNewsListItems(AppLocalizations l, bool isDark, Color cardColor) {
    if (_newsList.isEmpty && !_isLoading) {
      return [Padding(padding: const EdgeInsets.all(32), child: Center(child: Text(l.noData, style: TextStyle(color: _onSurfaceVariant))))];
    }

    final List<Widget> items = [];

    for (int i = 0; i < _newsList.length; i++) {
      final news = _newsList[i];

      // --- Haber Kartı ---
      items.add(
        GestureDetector(
          key: ValueKey('news_$i'),
          onTap: () async {
            final uri = Uri.parse(news.link);
            if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 30, spreadRadius: -8, offset: const Offset(0, 6))]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: _secondaryContainer.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                      child: Text(news.source == 'Haber' ? l.news : (news.source ?? l.news), style: TextStyle(color: _secondaryContainer, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const Spacer(),
                    Icon(Icons.open_in_new, color: _outline, size: 16),
                  ],
                ),
                const SizedBox(height: 10),
                Text(news.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _onSurface)),
                const SizedBox(height: 8),
                Text(news.description.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ''), style: TextStyle(color: _onSurfaceVariant, fontSize: 13, height: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text(DateFormat('dd MMM yyyy').format(news.pubDate), style: TextStyle(color: _outline, fontSize: 12)),
              ],
            ),
          ),
        ),
      );

      // --- Native Reklam Kartı ---
      items.add(NativeAdCard(key: ValueKey('ad_$i')));
    }

    return items;
  }
}
