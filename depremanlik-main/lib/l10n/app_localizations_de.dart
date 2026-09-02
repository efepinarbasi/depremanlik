// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'SeismoAlert';

  @override
  String get live => 'Live';

  @override
  String get history => 'Verlauf';

  @override
  String get news => 'Nachrichten';

  @override
  String get location => 'Ort';

  @override
  String get radius => 'Radius';

  @override
  String get lastYear => 'Letztes Jahr';

  @override
  String get noData => 'Keine Daten gefunden.';

  @override
  String get error => 'Ein Fehler ist aufgetreten.';

  @override
  String get selectLocation => 'Ort auswählen';

  @override
  String get distance => 'Entfernung';

  @override
  String get depth => 'Tiefe';

  @override
  String get liveEarthquakes => 'Live Erdbeben';

  @override
  String newsCount(int count) {
    return '$count Nachrichten';
  }

  @override
  String records(int count) {
    return '$count Aufzeichnungen - 100km Radius';
  }

  @override
  String kmAway(String distance) {
    return '$distance km entfernt';
  }

  @override
  String get pastEarthquakes => 'Vergangene Erdbeben';

  @override
  String get earthquakeNews => 'Erdbeben-Nachrichten';

  @override
  String get areaSafe => 'Sicheres Gebiet';

  @override
  String get seismicAlert => 'Seismische Warnung';

  @override
  String get noSeismicActivity =>
      'Keine signifikante seismische Aktivität in Ihrer Nähe entdeckt.';

  @override
  String get significantActivity =>
      'Signifikante seismische Aktivität in der Nähe entdeckt.';

  @override
  String get languageSettings => 'Spracheinstellungen';

  @override
  String get mapTab => 'Karte';

  @override
  String get activityTab => 'Aktivität';

  @override
  String get savedTab => 'Gespeichert';

  @override
  String get settingsTab => 'Einstellungen';

  @override
  String get developmentInProgress => 'In Entwicklung';

  @override
  String get guideTitle => 'Überlebensleitfaden';

  @override
  String get guide1Title => '1. DUCKEN, SCHÜTZEN, FESTHALTEN';

  @override
  String get guide1Desc =>
      'Gehen Sie auf Hände und Knie. Schützen Sie Kopf und Nacken mit Ihren Armen. Halten Sie sich an einem stabilen Möbelstück fest, bis das Beben aufhört.';

  @override
  String get guide2Title => '2. DRINNEN BLEIBEN';

  @override
  String get guide2Desc =>
      'Rennen Sie während des Erdbebens nicht nach draußen. Die meisten Verletzungen passieren, wenn Menschen panisch fliehen.';

  @override
  String get guide3Title => '3. FERN VON GLAS BLEIBEN';

  @override
  String get guide3Desc =>
      'Bleiben Sie von Fenstern, Glas, Außentüren und -wänden sowie allem, was fallen könnte, fern.';

  @override
  String get guide4Title => '4. WENN EINGESPERRT';

  @override
  String get guide4Desc =>
      'Zünden Sie kein Streichholz an. Bedecken Sie Ihren Mund mit Kleidung. Klopfen Sie an eine Leitung oder Wand, um Helfer zu alarmieren.';

  @override
  String get filterMagnitudeTitle => 'Benachrichtigungsfilter';

  @override
  String get filterMagnitudeDesc => 'Zeige Erdbeben ab Magnitude:';

  @override
  String get filterRadiusTitle => 'Erfassungsradius';

  @override
  String get filterRadiusDesc => 'Benachrichtigen bei Erdbeben innerhalb:';

  @override
  String get preferencesTitle => 'Präferenzen';

  @override
  String get darkModeTitle => 'Dunkelmodus';

  @override
  String get soundTitle => 'Tonbenachrichtigungen';

  @override
  String get emergencyContactsTitle => 'Notfallkontakte';

  @override
  String get emergencyContactsDesc => 'Telefonnummern für SOS-Ereignisse';

  @override
  String get contactHint => 'Kontakt Telefon';
}
