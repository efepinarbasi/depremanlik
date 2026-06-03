// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'SeismoAlert';

  @override
  String get live => 'ライブ';

  @override
  String get history => '履歴';

  @override
  String get news => 'ニュース';

  @override
  String get location => '場所';

  @override
  String get radius => '半径';

  @override
  String get lastYear => '昨年';

  @override
  String get noData => 'データが見つかりません。';

  @override
  String get error => 'エラーが発生しました。';

  @override
  String get selectLocation => '場所を選択';

  @override
  String get distance => '距離';

  @override
  String get depth => '深さ';

  @override
  String get liveEarthquakes => 'ライブ地震';

  @override
  String newsCount(int count) {
    return '$count ニュース';
  }

  @override
  String records(int count) {
    return '$count レコード - 半径100km';
  }

  @override
  String kmAway(String distance) {
    return '$distance km';
  }

  @override
  String get pastEarthquakes => '過去の地震';

  @override
  String get earthquakeNews => '地震ニュース';

  @override
  String get areaSafe => '安全なエリア';

  @override
  String get seismicAlert => '地震注意報';

  @override
  String get noSeismicActivity => 'あなたの周辺で大きな地震活動は検出されていません。';

  @override
  String get significantActivity => '近くで大きな地震活動が検出されました。';

  @override
  String get languageSettings => '言語設定';

  @override
  String get mapTab => 'マップ';

  @override
  String get activityTab => 'アクティビティ';

  @override
  String get savedTab => '保存済み';

  @override
  String get settingsTab => '設定';

  @override
  String get developmentInProgress => '開発中';

  @override
  String get guideTitle => '緊急サバイバルガイド';

  @override
  String get guide1Title => '1. ドロップ、カバー、ホールドオン';

  @override
  String get guide1Desc => '手と膝をついて身を低くします。腕で頭と首を覆います。揺れが収まるまで頑丈な家具につかまります。';

  @override
  String get guide2Title => '2. 室内に留まる';

  @override
  String get guide2Desc => '地震の最中に外に走らないでください。多くの負傷は人々が急いで外に出ようとする時に発生します。';

  @override
  String get guide3Title => '3. ガラスから離れる';

  @override
  String get guide3Desc => '窓、ガラス、外側のドアや壁、落ちてくる可能性のあるものから離れてください。';

  @override
  String get guide4Title => '4. 閉じ込められた場合';

  @override
  String get guide4Desc =>
      'マッチで火をつけないでください。衣類で口を覆います。パイプや壁を叩いて救助隊に場所を知らせます。可能であればホイッスルを使用してください。';

  @override
  String get filterMagnitudeTitle => '通知フィルター';

  @override
  String get filterMagnitudeDesc => '表示する最小マグニチュード:';

  @override
  String get filterRadiusTitle => '対象範囲 (半径)';

  @override
  String get filterRadiusDesc => '通知する距離:';

  @override
  String get preferencesTitle => '設定';

  @override
  String get darkModeTitle => 'ダークモード';

  @override
  String get soundTitle => 'サウンド通知';

  @override
  String get emergencyContactsTitle => '緊急連絡先';

  @override
  String get emergencyContactsDesc => '緊急時に通知する電話番号';

  @override
  String get contactHint => '連絡先電話番号';
}
