// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SeismoAlert';

  @override
  String get live => 'Live';

  @override
  String get history => 'History';

  @override
  String get news => 'News';

  @override
  String get location => 'Location';

  @override
  String get radius => 'Radius';

  @override
  String get lastYear => 'Last Year';

  @override
  String get noData => 'No data found.';

  @override
  String get error => 'An error occurred.';

  @override
  String get selectLocation => 'Select Location';

  @override
  String get distance => 'Distance';

  @override
  String get depth => 'Depth';

  @override
  String get liveEarthquakes => 'Live Earthquakes';

  @override
  String newsCount(int count) {
    return '$count news';
  }

  @override
  String records(int count) {
    return '$count records - 100km radius';
  }

  @override
  String kmAway(String distance) {
    return '$distance km away';
  }

  @override
  String get pastEarthquakes => 'Past Earthquakes';

  @override
  String get earthquakeNews => 'Earthquake News';

  @override
  String get areaSafe => 'Area Safe';

  @override
  String get seismicAlert => 'Seismic Alert';

  @override
  String get noSeismicActivity =>
      'No significant seismic activity detected in your vicinity.';

  @override
  String get significantActivity =>
      'Significant seismic activity detected nearby.';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get mapTab => 'Map';

  @override
  String get activityTab => 'Activity';

  @override
  String get savedTab => 'Saved';

  @override
  String get settingsTab => 'Settings';

  @override
  String get developmentInProgress => 'Development in progress';

  @override
  String get guideTitle => 'Emergency Survival Guide';

  @override
  String get guide1Title => '1. DROP, COVER, HOLD ON';

  @override
  String get guide1Desc =>
      'Drop to your hands and knees. Cover your head and neck with your arms. Hold on to any sturdy furniture until the shaking stops.';

  @override
  String get guide2Title => '2. STAY INDOORS';

  @override
  String get guide2Desc =>
      'Do not run outside during the earthquake. Most injuries occur when people try to rush out.';

  @override
  String get guide3Title => '3. STAY AWAY FROM GLASS';

  @override
  String get guide3Desc =>
      'Keep away from windows, glass, outside doors and walls, and anything that could fall.';

  @override
  String get guide4Title => '4. IF TRAPPED';

  @override
  String get guide4Desc =>
      'Do not light a match. Cover your mouth with clothing. Tap on a pipe or wall so rescuers can locate you. Use a whistle if available.';

  @override
  String get filterMagnitudeTitle => 'Notification Filter';

  @override
  String get filterMagnitudeDesc => 'Show earthquakes above magnitude:';

  @override
  String get filterRadiusTitle => 'Coverage Radius';

  @override
  String get filterRadiusDesc => 'Alert me for earthquakes within:';

  @override
  String get preferencesTitle => 'Preferences';

  @override
  String get darkModeTitle => 'Dark Mode (Lunar Theme)';

  @override
  String get soundTitle => 'Sound Notifications';

  @override
  String get emergencyContactsTitle => 'Emergency Contacts';

  @override
  String get emergencyContactsDesc =>
      'Phone numbers to notify during an SOS event';

  @override
  String get contactHint => 'Contact Phone';
}
