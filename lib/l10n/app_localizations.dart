import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('ru'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SeismoAlert'**
  String get appTitle;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get live;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @news.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get news;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @radius.
  ///
  /// In en, this message translates to:
  /// **'Radius'**
  String get radius;

  /// No description provided for @lastYear.
  ///
  /// In en, this message translates to:
  /// **'Last Year'**
  String get lastYear;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data found.'**
  String get noData;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get error;

  /// No description provided for @selectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select Location'**
  String get selectLocation;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @depth.
  ///
  /// In en, this message translates to:
  /// **'Depth'**
  String get depth;

  /// No description provided for @liveEarthquakes.
  ///
  /// In en, this message translates to:
  /// **'Live Earthquakes'**
  String get liveEarthquakes;

  /// No description provided for @newsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} news'**
  String newsCount(int count);

  /// No description provided for @records.
  ///
  /// In en, this message translates to:
  /// **'{count} records - 100km radius'**
  String records(int count);

  /// No description provided for @kmAway.
  ///
  /// In en, this message translates to:
  /// **'{distance} km away'**
  String kmAway(String distance);

  /// No description provided for @pastEarthquakes.
  ///
  /// In en, this message translates to:
  /// **'Past Earthquakes'**
  String get pastEarthquakes;

  /// No description provided for @earthquakeNews.
  ///
  /// In en, this message translates to:
  /// **'Earthquake News'**
  String get earthquakeNews;

  /// No description provided for @areaSafe.
  ///
  /// In en, this message translates to:
  /// **'Area Safe'**
  String get areaSafe;

  /// No description provided for @seismicAlert.
  ///
  /// In en, this message translates to:
  /// **'Seismic Alert'**
  String get seismicAlert;

  /// No description provided for @noSeismicActivity.
  ///
  /// In en, this message translates to:
  /// **'No significant seismic activity detected in your vicinity.'**
  String get noSeismicActivity;

  /// No description provided for @significantActivity.
  ///
  /// In en, this message translates to:
  /// **'Significant seismic activity detected nearby.'**
  String get significantActivity;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @mapTab.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapTab;

  /// No description provided for @activityTab.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityTab;

  /// No description provided for @savedTab.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedTab;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// No description provided for @developmentInProgress.
  ///
  /// In en, this message translates to:
  /// **'Development in progress'**
  String get developmentInProgress;

  /// No description provided for @guideTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency Survival Guide'**
  String get guideTitle;

  /// No description provided for @guide1Title.
  ///
  /// In en, this message translates to:
  /// **'1. DROP, COVER, HOLD ON'**
  String get guide1Title;

  /// No description provided for @guide1Desc.
  ///
  /// In en, this message translates to:
  /// **'Drop to your hands and knees. Cover your head and neck with your arms. Hold on to any sturdy furniture until the shaking stops.'**
  String get guide1Desc;

  /// No description provided for @guide2Title.
  ///
  /// In en, this message translates to:
  /// **'2. STAY INDOORS'**
  String get guide2Title;

  /// No description provided for @guide2Desc.
  ///
  /// In en, this message translates to:
  /// **'Do not run outside during the earthquake. Most injuries occur when people try to rush out.'**
  String get guide2Desc;

  /// No description provided for @guide3Title.
  ///
  /// In en, this message translates to:
  /// **'3. STAY AWAY FROM GLASS'**
  String get guide3Title;

  /// No description provided for @guide3Desc.
  ///
  /// In en, this message translates to:
  /// **'Keep away from windows, glass, outside doors and walls, and anything that could fall.'**
  String get guide3Desc;

  /// No description provided for @guide4Title.
  ///
  /// In en, this message translates to:
  /// **'4. IF TRAPPED'**
  String get guide4Title;

  /// No description provided for @guide4Desc.
  ///
  /// In en, this message translates to:
  /// **'Do not light a match. Cover your mouth with clothing. Tap on a pipe or wall so rescuers can locate you. Use a whistle if available.'**
  String get guide4Desc;

  /// No description provided for @filterMagnitudeTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Filter'**
  String get filterMagnitudeTitle;

  /// No description provided for @filterMagnitudeDesc.
  ///
  /// In en, this message translates to:
  /// **'Show earthquakes above magnitude:'**
  String get filterMagnitudeDesc;

  /// No description provided for @filterRadiusTitle.
  ///
  /// In en, this message translates to:
  /// **'Coverage Radius'**
  String get filterRadiusTitle;

  /// No description provided for @filterRadiusDesc.
  ///
  /// In en, this message translates to:
  /// **'Alert me for earthquakes within:'**
  String get filterRadiusDesc;

  /// No description provided for @preferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferencesTitle;

  /// No description provided for @darkModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode (Lunar Theme)'**
  String get darkModeTitle;

  /// No description provided for @soundTitle.
  ///
  /// In en, this message translates to:
  /// **'Sound Notifications'**
  String get soundTitle;

  /// No description provided for @emergencyContactsTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contacts'**
  String get emergencyContactsTitle;

  /// No description provided for @emergencyContactsDesc.
  ///
  /// In en, this message translates to:
  /// **'Phone numbers to notify during an SOS event'**
  String get emergencyContactsDesc;

  /// No description provided for @contactHint.
  ///
  /// In en, this message translates to:
  /// **'Contact Phone'**
  String get contactHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'ja',
    'ru',
    'tr',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
