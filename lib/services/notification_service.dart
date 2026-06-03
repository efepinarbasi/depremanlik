import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

const String checkEarthquakesTask = "checkNewEarthquakes";

// Arka plan servislerinin çalıştır(ıl)ması için gerekli callback metodu (Static olmalı)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Burada ileride EarthquakeService nesnesini çağırıp verileri çekeceğiz 
    // ve LocationHelper ile uzaklığa bakacağız. 
    // Ancak isolate yapısında UI nesneleri kullanılamayacağı için temel logic kuracağız.
    
    // Şimdilik test amaçlı her çalıştığında log basalım.
    // print("Native WorkManager Task Executor çalıştı!");
    
    // İşlem başarıyla tamamlandığı için başarılı dönüyoruz.
    return Future.value(true);
  });
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _isInit = false;

  Future<void> init() async {
    if (_isInit || kIsWeb) return;
    
    try {
      // 1. Local Notifications Init
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS (Darwin) initialization settings
      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          // Bildirime tıklandığında yapılacak işlemler
        },
      );

      // Platforma özgü izin talepleri
      // Android 13+ izin kontrolü (Location izni ile çakışmaması için 3 sn gecikmeli)
      Future.delayed(const Duration(seconds: 3), () {
        if (defaultTargetPlatform == TargetPlatform.android) {
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission();
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              );
        }
      });

      // 2. WorkManager Init
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false, // Prod için false kalmalı
      );

      // Mevcut arkplan sürelerini iptal edip yeniden kuralım.
      await Workmanager().cancelAll();

      // 15 dakikada bir çalışacak arka plan görevi ekleyelim (Android limiti min 15dk'dır)
      await Workmanager().registerPeriodicTask(
        "1",
        checkEarthquakesTask,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );
    } catch (e) {
      debugPrint("NotificationService Init Hatası: $e");
    }

    _isInit = true;
  }

  // Anlık Android / iOS Test Local Bildirimi Gösterme
  Future<void> showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'deprem_channel_id',
      'Önemli Deprem Uyarıları',
      channelDescription: '4.0 ve üzeri depremlerde bildirim verir',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Deprem Uyarı',
      color: Color(0xFFFF1744), // Neon Red
      enableLights: true,
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
      payload: 'item x',
    );
  }

  // SnackBar simülasyonunu koruyoruz
  void triggerEarthquakeAlert(BuildContext context, String title, String body) {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(body),
            ],
          ),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }
    // Biz burada sadece arka planda çalışabilecek olan Local System Notification tetikleyeceğiz
    showLocalNotification(title, body);
  }
}
