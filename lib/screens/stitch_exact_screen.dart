import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

import '../models/earthquake.dart';
import '../models/news.dart';
import '../models/saved_location.dart';
import '../services/earthquake_service.dart';
import '../utils/location_helper.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';

class StitchExactScreen extends StatefulWidget {
  const StitchExactScreen({super.key});
  @override
  State<StitchExactScreen> createState() => _StitchExactScreenState();
}

class _StitchExactScreenState extends State<StitchExactScreen> {
  final EarthquakeService _service = EarthquakeService();
  int _selectedIndex = 0; // 0: Map, 1: Earthquakes, 2: News, 3: Guide, 4: Profile
  
  List<Earthquake> _earthquakes = [];
  List<News> _newsList = [];
  bool _isLoading = true;
  
  GoogleMapController? _mapController;
  final LatLng _initialCenter = const LatLng(LocationHelper.defaultLat, LocationHelper.defaultLng);
  final TextEditingController _mapSearchController = TextEditingController();
  
  // Profile / Settings Variables
  double _minMagnitude = 3.0;
  double _notificationRadius = 100.0;
  bool _soundEnabled = true;
  
  final List<TextEditingController> _contactControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  final TextEditingController _addressController = TextEditingController();
  List<SavedLocation> _savedLocations = [];
  int _activeFilter = 0; // 0: All, 1: 4.0+, 2: 5.0+, 3: Near Me

  final Map<String, bool> _kitItems = {
      'kit1': true, 'kit2': true, 'kit3': true, 'kit4': true, 'kit5': false,
      'kit6': false, 'kit7': true, 'kit8': false, 'kit9': false, 'kit10': true,
      'kit11': false, 'kit12': true, 'kit13': true, 'kit14': false, 'kit15': true,
  };

  // Theme Colors
  final Color bg = const Color(0xFF051424);
  final Color surface = const Color(0xFF122131);
  final Color surfaceContainerLow = const Color(0xFF0D1C2D);
  final Color surfaceContainerHigh = const Color(0xFF1C2B3C);
  
  final Color primaryContainer = const Color(0xFF0B1326);
  final Color primary = const Color(0xFFBFC6E0);
  final Color secondary = const Color(0xFFFFB77D);
  final Color secondaryContainer = const Color(0xFFD97707);
  final Color onSecondaryContainer = const Color(0xFF432100);
  
  final Color errorContainer = const Color(0xFF93000A);
  final Color onErrorContainer = const Color(0xFFFFDAD6);
  
  final Color onBackground = const Color(0xFFD4E4FA);
  final Color onSurfaceVariant = const Color(0xFFC6C6CD);

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _fetchData();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _minMagnitude = prefs.getDouble('minMagnitude') ?? 3.0;
      _notificationRadius = prefs.getDouble('notificationRadius') ?? 100.0;
      _soundEnabled = prefs.getBool('soundEnabled') ?? true;
      _contactControllers[0].text = prefs.getString('contact0') ?? '';
      _contactControllers[1].text = prefs.getString('contact1') ?? '';
      _contactControllers[2].text = prefs.getString('contact2') ?? '';
      
      final savedKit = prefs.getStringList('kitChecked') ?? [];
      if (savedKit.isNotEmpty) {
         for (final key in _kitItems.keys.toList()) {
           _kitItems[key] = savedKit.contains(key);
         }
      }

      final savedLocsJson = prefs.getStringList('savedLocations') ?? [];
      _savedLocations = savedLocsJson.map((str) => SavedLocation.fromJson(str)).toList();
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('minMagnitude', _minMagnitude);
    prefs.setDouble('notificationRadius', _notificationRadius);
    prefs.setBool('soundEnabled', _soundEnabled);
    prefs.setString('contact0', _contactControllers[0].text);
    prefs.setString('contact1', _contactControllers[1].text);
    prefs.setString('contact2', _contactControllers[2].text);
    prefs.setStringList('savedLocations', _savedLocations.map((l) => l.toJson()).toList());
    
    final kitList = _kitItems.entries.where((e) => e.value).map((e) => e.key).toList();
    prefs.setStringList('kitChecked', kitList);
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final eqs = await _service.fetchAfadEarthquakes();
      final news = await _service.fetchEarthquakeNews();
      if (mounted) {
        setState(() {
          _earthquakes = eqs;
          _newsList = news;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  Future<void> _searchMapAddress(String address, bool isTr) async {
    if (address.isEmpty) return;
    try {
      List<geocoding.Location> locations = await geocoding.locationFromAddress(address);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(loc.latitude, loc.longitude), 9.0)
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isTr ? 'Adres bulunamadı' : 'Address not found')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    bool isTr = l.localeName == 'tr';

    Widget currentBody;
    switch (_selectedIndex) {
      case 0:
        currentBody = _buildMapTab(l, isTr);
        break;
      case 1:
        currentBody = _buildEarthquakesTab(l, isTr);
        break;
      case 2:
        currentBody = _buildNewsTab(l, isTr);
        break;
      case 3:
        currentBody = _buildGuideTab(l, isTr);
        break;
      case 4:
        currentBody = _buildProfileTab(l, isTr);
        break;
      default:
        currentBody = const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(l, isTr),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0.0, 0.05), end: Offset.zero).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_selectedIndex),
                  child: currentBody,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 64,
        decoration: BoxDecoration(
          color: bg,
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(0, Icons.map_outlined, l.mapTab ?? 'Map'),
            _navItem(1, Icons.monitor_heart_outlined, l.activityTab ?? 'Earthquakes'),
            _navItem(2, Icons.newspaper_outlined, l.news ?? 'News'),
            _navItem(3, Icons.info_outline, l.guideTitle ?? 'Guide'),
            _navItem(4, Icons.person_outline, l.settingsTab ?? 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l, bool isTr) {
    if (_selectedIndex == 0) return const SizedBox.shrink(); // Hide header exclusively for Map Tab
    
    String title = '';
    if (_selectedIndex == 1) title = l.activityTab ?? 'Earthquakes';
    if (_selectedIndex == 2) title = l.news ?? 'News';
    if (_selectedIndex == 3) title = l.guideTitle ?? 'Guide';
    if (_selectedIndex == 4) title = l.settingsTab ?? 'Profile';

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: bg,
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset('assets/images/logo.png', height: 32, errorBuilder: (c,e,s) => Icon(Icons.warning, color: primary)),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: onBackground, fontSize: 20, fontWeight: FontWeight.w600)),
            ],
          ),
          // User asked to remove profile icon from top right
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    bool active = _selectedIndex == index;
    Color c = active ? secondary : onSurfaceVariant;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: c, size: active ? 26 : 22),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: c, fontSize: 10, fontWeight: active ? FontWeight.bold : FontWeight.normal), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildEarthquakesTab(AppLocalizations l, bool isTr) {
    List<Earthquake> filtered = _earthquakes.where((eq) {
      if (_activeFilter == 1) return eq.mag >= 4.0;
      if (_activeFilter == 2) return eq.mag >= 5.0;
      if (_activeFilter == 3) return (eq.distance / 1000) <= _notificationRadius;
      return true;
    }).toList();

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              _filterChip(isTr ? 'Tümü' : 'All Events', 0),
              const SizedBox(width: 8),
              _filterChip('M 4.0+', 1),
              const SizedBox(width: 8),
              _filterChip('M 5.0+', 2),
              const SizedBox(width: 8),
              _filterChip(isTr ? 'Yakınımda' : 'Near Me', 3),
            ],
          ),
        ),
        Expanded(
          child: _isLoading 
            ? Center(child: CircularProgressIndicator(color: primary))
            : RefreshIndicator(
                color: primary,
                backgroundColor: bg,
                onRefresh: _fetchData,
                child: filtered.isEmpty 
                  ? Center(child: Text(isTr ? 'Bu filtreye uygun deprem bulunamadı.' : 'No earthquakes match this filter.', style: TextStyle(color: onSurfaceVariant)))
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final eq = filtered[i];
                        return _buildEqItem(eq, isTr);
                      },
                    ),
              ),
        )
      ],
    );
  }

  Widget _filterChip(String label, int index) {
    bool active = _activeFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? Colors.transparent : Colors.white.withOpacity(0.2)),
        ),
        child: Text(label, style: TextStyle(
          color: active ? onBackground : onBackground.withOpacity(0.7),
          fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5,
        )),
      ),
    );
  }

  Widget _buildEqItem(Earthquake eq, bool isTr) {
    Color magContainerColor = surfaceContainerHigh;
    Color magTextColor = onBackground;
    
    if (eq.mag >= 5.0) {
      magContainerColor = errorContainer;
      magTextColor = onErrorContainer;
    } else if (eq.mag >= 4.0) {
      magContainerColor = secondaryContainer;
      magTextColor = onSecondaryContainer;
    }

    final diff = DateTime.now().difference(eq.date);
    String timeAgo = diff.inMinutes < 60 ? "${diff.inMinutes}${isTr ? 'dk önce' : 'm ago'}" : "${diff.inHours}${isTr ? 'sa önce' : 'h ago'}";
    if (diff.inDays > 0) timeAgo = "${diff.inDays}${isTr ? 'g önce' : 'd ago'}";

    String depthLabel = isTr ? 'DERİNLİK' : 'DEPTH';
    String distLabel = isTr ? 'UZAKLIK' : 'DIST';

    return InkWell(
      onTap: () {
         _mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(eq.latitude, eq.longitude), 8.0));
         setState(() => _selectedIndex = 0);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: magContainerColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(eq.mag.toStringAsFixed(1), style: TextStyle(
                  color: magTextColor, fontSize: 16, fontWeight: FontWeight.bold
                )),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(eq.title, style: TextStyle(color: onBackground, fontSize: 15, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text('$depthLabel: ${eq.depth}KM', style: TextStyle(color: onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      Container(margin: const EdgeInsets.symmetric(horizontal: 8), width: 4, height: 4, decoration: BoxDecoration(color: onSurfaceVariant.withOpacity(0.5), shape: BoxShape.circle)),
                      Text('$distLabel: ${(eq.distance/1000).toStringAsFixed(0)}KM', style: TextStyle(color: onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(timeAgo, style: TextStyle(color: onSurfaceVariant, fontSize: 12)),
                const SizedBox(height: 4),
                Icon(Icons.location_on, color: onSurfaceVariant.withOpacity(0.5), size: 20),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMapTab(AppLocalizations l, bool isTr) {
     Set<Circle> circles = _earthquakes.map((eq) {
       Color cColor = eq.mag >= 5.0 ? const Color(0xFFBA1A1A) : (eq.mag >= 4.0 ? const Color(0xFFD97707) : const Color(0xFF0D47A1));
       return Circle(
         circleId: CircleId(eq.id),
         center: LatLng(eq.latitude, eq.longitude),
         radius: eq.mag * 5000, 
         fillColor: cColor.withOpacity(0.4),
         strokeColor: cColor,
         strokeWidth: 2,
       );
     }).toSet();

     return Stack(
       children: [
         GoogleMap(
           initialCameraPosition: CameraPosition(
             target: _initialCenter,
             zoom: 5.5,
           ),
           myLocationEnabled: true,
           zoomControlsEnabled: false,
           circles: circles,
           mapType: MapType.normal,
           onMapCreated: (GoogleMapController controller) {
             _mapController = controller;
             const String darkMapStyle = '''[
               {"elementType": "geometry","stylers": [{"color": "#242f3e"}]},
               {"elementType": "labels.text.fill","stylers": [{"color": "#746855"}]},
               {"elementType": "labels.text.stroke","stylers": [{"color": "#242f3e"}]},
               {"featureType": "water","elementType": "geometry","stylers": [{"color": "#17263c"}]}
             ]''';
             controller.setMapStyle(darkMapStyle);
           },
         ),
         Positioned(
           top: 16,
           left: 16,
           right: 16,
           child: Container(
             height: 52,
             decoration: BoxDecoration(
               color: bg.withOpacity(0.9),
               borderRadius: BorderRadius.circular(26),
               boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4))],
             ),
             child: TextField(
               controller: _mapSearchController,
               style: TextStyle(color: onBackground),
               decoration: InputDecoration(
                 hintText: isTr ? 'Konum ara...' : 'Search location...',
                 hintStyle: TextStyle(color: onSurfaceVariant.withOpacity(0.7)),
                 prefixIcon: Icon(Icons.search, color: secondary),
                 border: InputBorder.none,
                 contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
               ),
               onSubmitted: (val) => _searchMapAddress(val, isTr),
             ),
           ),
         ),
       ],
     );
  }

  Widget _buildNewsTab(AppLocalizations l, bool isTr) {
    return _isLoading 
      ? Center(child: CircularProgressIndicator(color: primary))
      : ListView.builder(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          itemCount: _newsList.length,
          itemBuilder: (context, i) {
             final news = _newsList[i];
             if (i == 0) return _buildFeaturedNewsCard(news, isTr);
             return _buildNewsCard(news, isTr);
          },
        );
  }

  Widget _buildFeaturedNewsCard(News news, bool isTr) {
     return Container(
       margin: const EdgeInsets.only(bottom: 16),
       decoration: BoxDecoration(
         color: surfaceContainerLow,
         borderRadius: BorderRadius.circular(16),
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Container(
             height: 180,
             decoration: BoxDecoration(
               color: surfaceContainerHigh,
               borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
             ),
             child: const Center(child: Icon(Icons.newspaper, color: Colors.white24, size: 48)),
           ),
           Padding(
             padding: const EdgeInsets.all(16),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Row(
                   children: [
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                       decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(4)),
                       child: Text(isTr ? 'HABER' : 'NEWS', style: TextStyle(color: onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold)),
                     ),
                     const SizedBox(width: 8),
                     Text(DateFormat('MMM dd, HH:mm').format(news.pubDate), style: TextStyle(color: onSurfaceVariant, fontSize: 11)),
                   ],
                 ),
                 const SizedBox(height: 8),
                 Text(news.title, style: TextStyle(color: onBackground, fontSize: 17, fontWeight: FontWeight.w600)),
                 const SizedBox(height: 4),
                 Text(news.description.replaceAll(RegExp(r'<[^>]*>'), ''), style: TextStyle(color: onSurfaceVariant, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
               ],
             ),
           )
         ],
       ),
     );
  }

  Widget _buildNewsCard(News news, bool isTr) {
    return Container(
       margin: const EdgeInsets.only(bottom: 16),
       decoration: BoxDecoration(
         color: surfaceContainerLow,
         borderRadius: BorderRadius.circular(16),
       ),
       padding: const EdgeInsets.all(12),
       child: Row(
         children: [
           Container(
             width: 80, height: 80,
             decoration: BoxDecoration(
               color: surfaceContainerHigh,
               borderRadius: BorderRadius.circular(8),
             ),
             child: const Center(child: Icon(Icons.newspaper, color: Colors.white24, size: 24)),
           ),
           const SizedBox(width: 12),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Row(
                   children: [
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                       decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(4)),
                       child: Text(isTr ? 'GÜNCELLEME' : 'UPDATE', style: TextStyle(color: onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold)),
                     ),
                     const SizedBox(width: 8),
                     Text(DateFormat('MMM dd, HH:mm').format(news.pubDate), style: TextStyle(color: onSurfaceVariant, fontSize: 11)),
                   ],
                 ),
                 const SizedBox(height: 6),
                 Text(news.title, style: TextStyle(color: onBackground, fontSize: 15, fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis),
               ],
             ),
           )
         ],
       ),
    );
  }

  Widget _buildGuideTab(AppLocalizations l, bool isTr) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l.guideTitle ?? (isTr ? 'Bilgi & Hazırlık' : 'Information & Guide'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: onBackground)),
        const SizedBox(height: 16),
        _buildGuideCard(l.guide1Title ?? (isTr ? "1. ÇÖK, KAPAN, TUTUN" : "1. DROP, COVER, HOLD ON"), l.guide1Desc ?? (isTr ? "Sarsıntı anında sağlam bir cismin yanına çökün." : "Take cover under sturdy furniture."), Icons.accessibility_new),
        _buildGuideCard(l.guide2Title ?? (isTr ? "2. İÇERİDE KALIN" : "2. STAY INDOORS"), l.guide2Desc ?? (isTr ? "Sarsıntı bitene kadar dışarı çıkmaya çalışmayın." : "Do not attempt to exit until shaking stops."), Icons.house),
        _buildGuideCard(l.guide3Title ?? (isTr ? "3. CAMLARDAN UZAK DURUN" : "3. AWAY FROM GLASS"), l.guide3Desc ?? (isTr ? "Düşebilecek ağır eşya ve cam kenarlarından uzaklaşın." : "Move away from windows and heavy objects."), Icons.dangerous),
        const SizedBox(height: 24),
        Text(isTr ? "Deprem Çantası (Hazırlık)" : "Earthquake Kit", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: onBackground)),
        const SizedBox(height: 12),
        ..._kitItems.keys.map((key) => _buildChecklistItem(key, _getKitLabel(key, isTr))),
      ],
    );
  }

  String _getKitLabel(String key, bool isTr) {
    Map<String, String> tr = {
      'kit1': 'Su ve uzun ömürlü gıda', 'kit2': 'İlk yardım çantası', 'kit3': 'El feneri ve yedek piller',
      'kit4': 'Düdük', 'kit5': 'Toz maskesi', 'kit6': 'Yerel haritalar', 'kit7': 'Önemli evrak kopyaları',
      'kit8': 'Çok amaçlı çakı', 'kit9': 'Konserve açacağı', 'kit10': 'İlaçlar (reçeteli)'
    };
    Map<String, String> en = {
      'kit1': 'Water and non-perishable food', 'kit2': 'First aid kit', 'kit3': 'Flashlight and batteries',
      'kit4': 'Whistle', 'kit5': 'Dust mask', 'kit6': 'Local maps', 'kit7': 'Copies of important documents',
      'kit8': 'Multi-tool knife', 'kit9': 'Can opener', 'kit10': 'Prescription meds'
    };
    return isTr ? (tr[key] ?? key) : (en[key] ?? key);
  }

  Widget _buildGuideCard(String title, String desc, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: errorContainer.withOpacity(0.8)),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: onBackground)),
              const SizedBox(height: 4),
              Text(desc, style: TextStyle(color: onSurfaceVariant, fontSize: 13)),
            ],
          ))
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String key, String title) {
    if (title == key) return const SizedBox.shrink(); // Ignore extra kits
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: surfaceContainerHigh, borderRadius: BorderRadius.circular(10)),
      child: CheckboxListTile(
        title: Text(title, style: TextStyle(color: onBackground, fontSize: 14)),
        value: _kitItems[key] ?? false,
        activeColor: secondary,
        checkColor: Colors.black,
        onChanged: (val) {
          setState(() => _kitItems[key] = val ?? false);
          _saveSettings();
        },
      ),
    );
  }

  Widget _buildProfileTab(AppLocalizations l, bool isTr) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l.filterMagnitudeTitle ?? "Notification Filter (Magnitude)", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: onBackground)),
        const SizedBox(height: 8),
        Text("${l.filterMagnitudeDesc ?? 'Show earthquakes above magnitude:'} ${_minMagnitude.toStringAsFixed(1)}", style: TextStyle(color: onSurfaceVariant)),
        Slider(
          value: _minMagnitude,
          min: 1.0, max: 8.0, divisions: 14,
          activeColor: secondary,
          inactiveColor: surfaceContainerHigh,
          onChanged: (val) => setState(() => _minMagnitude = val),
          onChangeEnd: (val) => _saveSettings(),
        ),
        const SizedBox(height: 24),
        
        Text(l.filterRadiusTitle ?? "Coverage Radius", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: onBackground)),
        const SizedBox(height: 8),
        Text("${l.filterRadiusDesc ?? 'Alert me for earthquakes within:'} ${_notificationRadius.toStringAsFixed(0)} km", style: TextStyle(color: onSurfaceVariant)),
        Slider(
          value: _notificationRadius,
          min: 50.0, max: 500.0, divisions: 9,
          activeColor: errorContainer,
          inactiveColor: surfaceContainerHigh,
          onChanged: (val) => setState(() => _notificationRadius = val),
          onChangeEnd: (val) => _saveSettings(),
        ),
        const SizedBox(height: 24),

        Text(l.preferencesTitle ?? "Preferences", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: onBackground)),
        const SizedBox(height: 8),

        SwitchListTile(
          title: Text(l.soundTitle ?? "Sound Notifications", style: TextStyle(color: onBackground, fontWeight: FontWeight.w600)),
          contentPadding: EdgeInsets.zero,
          activeColor: errorContainer,
          value: _soundEnabled,
          onChanged: (val) { setState(() => _soundEnabled = val); _saveSettings(); },
        ),
        const SizedBox(height: 24),

        Text(l.emergencyContactsTitle ?? "Emergency Contacts", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: onBackground)),
        const SizedBox(height: 8),
        Text(l.emergencyContactsDesc ?? "Phone numbers to notify during an SOS event", style: TextStyle(color: onSurfaceVariant, fontSize: 13)),
        const SizedBox(height: 12),
        ...List.generate(3, (idx) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextField(
            controller: _contactControllers[idx],
            style: TextStyle(color: onBackground),
            decoration: InputDecoration(
              hintText: "${l.contactHint ?? 'Contact Phone'} ${idx+1}",
              hintStyle: TextStyle(color: onSurfaceVariant.withOpacity(0.5)),
              filled: true,
              fillColor: surfaceContainerLow,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              prefixIcon: Icon(Icons.phone, color: onSurfaceVariant),
              suffixIcon: IconButton(
                icon: Icon(Icons.contacts, color: secondary),
                onPressed: () => _pickContactFromList(idx, isTr),
                tooltip: isTr ? 'Kişi Seç' : 'Select Contact',
              ),
            ),
            keyboardType: TextInputType.phone,
            onSubmitted: (_) => _saveSettings(),
          ),
        )),

        const SizedBox(height: 24),

        Text(isTr ? 'Kayıtlı Adresler' : 'Saved Addresses', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: onBackground)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _addressController,
                style: TextStyle(color: onBackground),
                decoration: InputDecoration(
                  hintText: isTr ? 'Adres Takip Et' : 'Track Address',
                  hintStyle: TextStyle(color: onSurfaceVariant.withOpacity(0.5)),
                  filled: true,
                  fillColor: surfaceContainerLow,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  prefixIcon: Icon(Icons.location_city, color: onSurfaceVariant)
                ),
                onSubmitted: (_) => _addNewLocation(isTr),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.add_circle, size: 44, color: secondary),
              onPressed: () => _addNewLocation(isTr),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._savedLocations.map((loc) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(color: surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.home, color: Colors.white),
            title: Text(loc.name.toUpperCase(), style: TextStyle(color: onBackground, fontWeight: FontWeight.bold)),
            subtitle: Text("${loc.latitude.toStringAsFixed(2)}, ${loc.longitude.toStringAsFixed(2)}", style: TextStyle(color: onSurfaceVariant, fontSize: 12)),
            trailing: IconButton(icon: Icon(Icons.delete, color: errorContainer), onPressed: () => _deleteLocation(loc.name)),
          ),
        )),

        const SizedBox(height: 24),

        Text(l.languageSettings ?? 'Language Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: onBackground)),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(color: surfaceContainerLow, borderRadius: BorderRadius.circular(10)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: ExpansionTile(
              title: Text(isTr ? 'Uygulama Dilini Seç' : 'Select App Language', style: TextStyle(fontWeight: FontWeight.bold, color: onBackground)),
              leading: Icon(Icons.language, color: secondary),
              iconColor: onBackground,
              collapsedIconColor: onBackground,
              backgroundColor: surfaceContainerLow,
              collapsedBackgroundColor: surfaceContainerLow,
              children: [
                _buildLanguageOption('Türkçe', '🇹🇷', 'tr'),
                _buildLanguageOption('English', '🇬🇧', 'en'),
                _buildLanguageOption('日本語 (Japanese)', '🇯🇵', 'ja'),
                _buildLanguageOption('Français (French)', '🇫🇷', 'fr'),
                _buildLanguageOption('Deutsch (German)', '🇩🇪', 'de'),
                _buildLanguageOption('Español (Spanish)', '🇪🇸', 'es'),
                _buildLanguageOption('Русский (Russian)', '🇷🇺', 'ru'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildLanguageOption(String name, String flag, String code) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, currentLocale, _) {
        bool isSelected = currentLocale.languageCode == code;
        return ListTile(
          leading: Text(flag, style: const TextStyle(fontSize: 24)),
          title: Text(name, style: TextStyle(color: onBackground, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          trailing: isSelected ? Icon(Icons.check, color: secondary) : null,
          onTap: () {
            localeNotifier.value = Locale(code);
            _saveSettings();
          },
        );
      },
    );
  }

  void _addNewLocation(bool isTr) {
    final text = _addressController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _savedLocations.add(SavedLocation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: text,
          latitude: LocationHelper.defaultLat + 0.1, // Simulated
          longitude: LocationHelper.defaultLng + 0.1,
        ));
        _addressController.clear();
      });
      _saveSettings();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isTr ? 'Adres Kaydedildi!' : 'Address Saved!')));
    }
  }

  void _deleteLocation(String name) {
    setState(() {
      _savedLocations.removeWhere((l) => l.name == name);
    });
    _saveSettings();
  }

  Future<void> _pickContactFromList(int index, bool isTr) async {
    var status = await Permission.contacts.request();
    if (status.isGranted) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      List<Contact> contacts = await FastContacts.getAllContacts();
      if (!mounted) return;
      Navigator.pop(context); // close dialog
      
      showModalBottomSheet(
        context: context,
        backgroundColor: bg,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (context) {
          return Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 16),
              Text(isTr ? 'Kişi Seç' : 'Select Contact', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, i) {
                    final c = contacts[i];
                    final phones = c.phones;
                    if (phones.isEmpty) return const SizedBox.shrink();
                    final displayName = c.displayName.isNotEmpty ? c.displayName : (isTr ? 'İsimsiz' : 'Unnamed');
                    final firstLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
                    final number = phones.first.number;
                    
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: errorContainer.withOpacity(0.3),
                        child: Text(firstLetter, style: TextStyle(color: onErrorContainer, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(displayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      subtitle: Text(number, style: const TextStyle(color: Colors.white70)),
                      onTap: () {
                        setState(() {
                          _contactControllers[index].text = number.replaceAll(" ", "");
                        });
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isTr ? 'Rehber izni reddedildi' : 'Contacts permission denied')));
    }
  }
}
