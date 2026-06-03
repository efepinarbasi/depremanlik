import 'package:flutter/material.dart';

// Dil değişimi için global notifier
final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('tr'));

class LocaleProvider {
  static void changeLocale(String languageCode) {
    localeNotifier.value = Locale(languageCode);
  }

  static String get currentLanguage => localeNotifier.value.languageCode;
}
