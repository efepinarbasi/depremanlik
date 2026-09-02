// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'SeismoAlert';

  @override
  String get live => 'Canlı';

  @override
  String get history => 'Geçmiş';

  @override
  String get news => 'Haberler';

  @override
  String get location => 'Konum';

  @override
  String get radius => 'Çap';

  @override
  String get lastYear => 'Son 1 Yıl';

  @override
  String get noData => 'Veri bulunamadı.';

  @override
  String get error => 'Bir hata oluştu.';

  @override
  String get selectLocation => 'Konum Seç';

  @override
  String get distance => 'Mesafe';

  @override
  String get depth => 'Derinlik';

  @override
  String get liveEarthquakes => 'Canlı Depremler';

  @override
  String newsCount(int count) {
    return '$count haber';
  }

  @override
  String records(int count) {
    return '$count kayıt - 100km çap';
  }

  @override
  String kmAway(String distance) {
    return '$distance km uzakta';
  }

  @override
  String get pastEarthquakes => 'Geçmiş Depremler';

  @override
  String get earthquakeNews => 'Deprem Haberleri';

  @override
  String get areaSafe => 'Bölge Güvenli';

  @override
  String get seismicAlert => 'Sismik Uyarı';

  @override
  String get noSeismicActivity =>
      'Çevrenizde önemli bir sismik aktivite algılanmadı.';

  @override
  String get significantActivity =>
      'Yakınınızda önemli sismik aktivite algılandı.';

  @override
  String get languageSettings => 'Dil Ayarları';

  @override
  String get mapTab => 'Harita';

  @override
  String get activityTab => 'Aktivite';

  @override
  String get savedTab => 'Kaydedilenler';

  @override
  String get settingsTab => 'Ayarlar';

  @override
  String get developmentInProgress => 'Geliştirme aşamasında';

  @override
  String get guideTitle => 'Acil Durum Hayatta Kalma Rehberi';

  @override
  String get guide1Title => '1. ÇÖK, KAPAN, TUTUN';

  @override
  String get guide1Desc =>
      'Ellerinizin ve dizlerinizin üzerine çökün. Başınızı ve boynunuzu kollarınızla koruyun. Sarsıntı geçene kadar sağlam bir mobilyaya tutunun.';

  @override
  String get guide2Title => '2. İÇERİDE KALIN';

  @override
  String get guide2Desc =>
      'Deprem sırasında dışarı koşmayın. Yaralanmaların çoğu insanlar panikle dışarı çıkmaya çalışırken olur.';

  @override
  String get guide3Title => '3. CAMLARDAN UZAK DURUN';

  @override
  String get guide3Desc =>
      'Pencerelerden, camlardan, dış kapı ve duvarlardan ile düşebilecek her şeyden uzak durun.';

  @override
  String get guide4Title => '4. ENKAZ ALTINDAYSANIZ';

  @override
  String get guide4Desc =>
      'Kibrit yakmayın. Ağzınızı bir giysiyle kapatın. Kurtarma ekiplerine yerinizi belli etmek için borulara veya duvara vurun. Varsa düdük kullanın.';

  @override
  String get filterMagnitudeTitle => 'Bildirim Filtresi';

  @override
  String get filterMagnitudeDesc => 'Şu şiddet ve üzeri depremleri göster:';

  @override
  String get filterRadiusTitle => 'Tarama Yarıçapı';

  @override
  String get filterRadiusDesc => 'Bana şu mesafedeki depremleri bildir:';

  @override
  String get preferencesTitle => 'Tercihler';

  @override
  String get darkModeTitle => 'Karanlık Mod (Lunar Tema)';

  @override
  String get soundTitle => 'Sesli Bildirimler';

  @override
  String get emergencyContactsTitle => 'Acil Durum Kişileri';

  @override
  String get emergencyContactsDesc => 'Acil durumda SMS gönderilecek numaralar';

  @override
  String get contactHint => 'Kişi Numarası';
}
