// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'SeismoAlert';

  @override
  String get live => 'В эфире';

  @override
  String get history => 'История';

  @override
  String get news => 'Новости';

  @override
  String get location => 'Локация';

  @override
  String get radius => 'Радиус';

  @override
  String get lastYear => 'Прошлый год';

  @override
  String get noData => 'Данные не найдены.';

  @override
  String get error => 'Произошла ошибка.';

  @override
  String get selectLocation => 'Выберите место';

  @override
  String get distance => 'Расстояние';

  @override
  String get depth => 'Глубина';

  @override
  String get liveEarthquakes => 'Землетрясения сейчас';

  @override
  String newsCount(int count) {
    return '$count новости';
  }

  @override
  String records(int count) {
    return '$count записей - радиус 100км';
  }

  @override
  String kmAway(String distance) {
    return '$distance км';
  }

  @override
  String get pastEarthquakes => 'Прошлые землетрясения';

  @override
  String get earthquakeNews => 'Новости о землетрясениях';

  @override
  String get areaSafe => 'Безопасная зона';

  @override
  String get seismicAlert => 'Сейсмическая тревога';

  @override
  String get noSeismicActivity =>
      'В вашем районе не обнаружено значительной сейсмической активности.';

  @override
  String get significantActivity =>
      'Поблизости обнаружена значительная сейсмическая активность.';

  @override
  String get languageSettings => 'Настройки языка';

  @override
  String get mapTab => 'Карта';

  @override
  String get activityTab => 'Трекер';

  @override
  String get savedTab => 'Сохраненные';

  @override
  String get settingsTab => 'Настройки';

  @override
  String get developmentInProgress => 'В разработке';

  @override
  String get guideTitle => 'Руководство по выживанию';

  @override
  String get guide1Title => '1. УПАСТЬ, УКРЫТЬСЯ, ДЕРЖАТЬСЯ';

  @override
  String get guide1Desc =>
      'Опуститесь на четвереньки. Прикройте голову и шею руками. Держитесь за прочную мебель, пока не прекратится тряска.';

  @override
  String get guide2Title => '2. ОСТАВАТЬСЯ ВНУТРИ';

  @override
  String get guide2Desc =>
      'Не выбегайте на улицу во время землетрясения. Большинство травм происходит из-за паники.';

  @override
  String get guide3Title => '3. ДЕРЖАТЬСЯ ПОДАЛЬШЕ ОТ СТЕКОЛ';

  @override
  String get guide3Desc =>
      'Держитесь подальше от окон, стекла, наружных дверей и стен, а также всего, что может упасть.';

  @override
  String get guide4Title => '4. ЕСЛИ ВЫ ЗАБЛОКИРОВАНЫ';

  @override
  String get guide4Desc =>
      'Не зажигайте спички. Прикройте рот одеждой. Стучите по трубе или стене, чтобы спасатели могли вас найти.';

  @override
  String get filterMagnitudeTitle => 'Фильтр Уведомлений';

  @override
  String get filterMagnitudeDesc => 'Показывать землетрясения от:';

  @override
  String get filterRadiusTitle => 'Радиус Охвата';

  @override
  String get filterRadiusDesc => 'Уведомлять в радиусе:';

  @override
  String get preferencesTitle => 'Настройки';

  @override
  String get darkModeTitle => 'Темный Режим';

  @override
  String get soundTitle => 'Звуковые Уведомления';

  @override
  String get emergencyContactsTitle => 'Экстренные Контакты';

  @override
  String get emergencyContactsDesc => 'Номера для уведомления при SOS';

  @override
  String get contactHint => 'Телефон Контакта';
}
