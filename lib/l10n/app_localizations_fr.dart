// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'SeismoAlert';

  @override
  String get live => 'En direct';

  @override
  String get history => 'Historique';

  @override
  String get news => 'Actualités';

  @override
  String get location => 'Localisation';

  @override
  String get radius => 'Rayon';

  @override
  String get lastYear => 'L\'année dernière';

  @override
  String get noData => 'Aucune donnée trouvée.';

  @override
  String get error => 'Une erreur s\'est produite.';

  @override
  String get selectLocation => 'Sélectionner l\'emplacement';

  @override
  String get distance => 'Distance';

  @override
  String get depth => 'Profondeur';

  @override
  String get liveEarthquakes => 'Tremblements de terre en direct';

  @override
  String newsCount(int count) {
    return '$count actualités';
  }

  @override
  String records(int count) {
    return '$count enregistrements - rayon 100km';
  }

  @override
  String kmAway(String distance) {
    return 'à $distance km';
  }

  @override
  String get pastEarthquakes => 'Séismes passés';

  @override
  String get earthquakeNews => 'Actualités sismiques';

  @override
  String get areaSafe => 'Zone sûre';

  @override
  String get seismicAlert => 'Alerte sismique';

  @override
  String get noSeismicActivity =>
      'Aucune activité sismique significative détectée dans votre région.';

  @override
  String get significantActivity =>
      'Activité sismique significative détectée à proximité.';

  @override
  String get languageSettings => 'Paramètres de langue';

  @override
  String get mapTab => 'Carte';

  @override
  String get activityTab => 'Activité';

  @override
  String get savedTab => 'Enregistré';

  @override
  String get settingsTab => 'Paramètres';

  @override
  String get developmentInProgress => 'En cours de développement';

  @override
  String get guideTitle => 'Guide de survie';

  @override
  String get guide1Title => '1. SE BAISSER, SE COUVRIR, S\'ACCROCHER';

  @override
  String get guide1Desc =>
      'Mettez-vous à quatre pattes. Couvrez votre tête et votre cou avec vos bras. Accrochez-vous à un meuble solide jusqu\'à ce que les secousses s\'arrêtent.';

  @override
  String get guide2Title => '2. RESTER À L\'INTÉRIEUR';

  @override
  String get guide2Desc =>
      'Ne courez pas dehors pendant le tremblement de terre. La plupart des blessures surviennent lorsque les gens essaient de se précipiter dehors.';

  @override
  String get guide3Title => '3. RESTER LOIN DU VERRE';

  @override
  String get guide3Desc =>
      'Éloignez-vous des fenêtres, du verre, des portes extérieures et des murs, et de tout ce qui pourrait tomber.';

  @override
  String get guide4Title => '4. SI PIÉGÉ';

  @override
  String get guide4Desc =>
      'N\'allumez pas d\'allumette. Couvrez votre bouche avec des vêtements. Tapez sur un tuyau ou un mur pour que les secouristes puissent vous localiser.';

  @override
  String get filterMagnitudeTitle => 'Filtre de Notification';

  @override
  String get filterMagnitudeDesc => 'Afficher les séismes supérieurs à:';

  @override
  String get filterRadiusTitle => 'Rayon de Couverture';

  @override
  String get filterRadiusDesc => 'M\'alerter dans un rayon de:';

  @override
  String get preferencesTitle => 'Préférences';

  @override
  String get darkModeTitle => 'Mode Sombre';

  @override
  String get soundTitle => 'Notifications Sonores';

  @override
  String get emergencyContactsTitle => 'Contacts d\'Urgence';

  @override
  String get emergencyContactsDesc => 'Numéros à notifier en cas de SOS';

  @override
  String get contactHint => 'Téléphone de Contact';
}
