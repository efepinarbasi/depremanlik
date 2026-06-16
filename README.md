# Deprem Anlık - Canlı Deprem Takip Sistemi

**Öğrenci Adı ve Soyadı:** Rıdvan Efe Pınarbaşı  
**Öğrenci Numarası:** 24010509100  

## Projenin Amacı ve Kısa Açıklaması
Bu projenin amacı, Türkiye'deki (AFAD ve Kandilli Rasathanesi kaynaklı) sismik hareketliliği ve depremleri anlık olarak takip edip kullanıcıları bilgilendiren bir mobil uygulama geliştirmektir. Uygulama, kullanıcının konumuna göre gerçekleşen depremin mesafesini hesaplar, belirlenen şiddet eşiklerine göre anlık bildirimler gönderir ve acil durumlarda önceden belirlenmiş kişilere kolay erişim sağlar. Ayrıca arka plan servisleriyle uygulama kapalıyken bile uyarılar üretmeyi hedefler.

## Kullanılan Teknolojiler / Kütüphaneler
* **Mobil Geliştirme Çerçevesi:** Flutter (Dart)
* **Harita ve Konum Servisleri:** `flutter_map`, `latlong2`, `geolocator`, `geocoding`
* **Ağ ve Veri İşleme:** `http`, `xml` (Kandilli/AFAD verilerini parse etmek için)
* **Arka Plan Servisleri:** `workmanager`, `flutter_local_notifications`
* **Medya ve Uyarılar:** `flutter_ringtone_player`, `audioplayers`
* **Yerel Depolama:** `shared_preferences`
* **Diğer Entegrasyonlar:** `fast_contacts`, `permission_handler`, `google_mobile_ads`

## Proje Klasör Yapısı
```text
deprem_anlik_app/
├── android/                         # Android native dosyaları
├── ios/                             # iOS native dosyaları
├── lib/                             # Flutter kodlarının ana dizini
│   ├── l10n/                        # Dil/yerelleştirme dosyaları
│   ├── models/                      # Veri modelleri
│   ├── providers/                   # State yönetimi (State Management)
│   ├── screens/                     # Arayüz ve sayfalar
│   ├── services/                    # API servisleri ve bildirimler
│   ├── utils/                       # Yardımcı fonksiyonlar
│   ├── widgets/                     # Tekrar kullanılabilir UI bileşenleri
│   └── main.dart                    # Uygulamanın başlangıç noktası
├── test/                            # Birim (Unit) testleri
├── assets/                          # Uygulama içi resim, ikon ve fontlar
└── pubspec.yaml                     # Bağımlılık (Dependency) yönetim dosyası
```

## Kurulum Adımları
1. Projeyi yerel bilgisayarınıza indirin (clone):
   ```bash
   git clone https://github.com/efepinarbasi/depremanlik.git
   ```
2. Proje dizinine gidin:
   ```bash
   cd depremanlik
   ```
3. Flutter bağımlılıklarını yükleyin:
   ```bash
   flutter pub get
   ```

## Çalıştırma / Kullanım Talimatları
1. Bilgisayarınıza bağlı bir Android/iOS cihaz ya da açık bir emülatör olduğundan emin olun.
2. Uygulamayı derlemek ve çalıştırmak için aşağıdaki komutu kullanın:
   ```bash
   flutter run
   ```
3. Uygulama açıldığında istenen **Konum** ve **Bildirim** izinlerini onaylayarak harita tabanlı anlık bildirimleri kullanmaya başlayabilirsiniz.

## Varsa Ekran Görüntüleri
*(Geliştirme aşamasındadır, buraya daha sonra ekran görüntüleri eklenecektir.)*

## GitHub Proje Bağlantısı
* [Deprem Anlık GitHub Repo](https://github.com/efepinarbasi/depremanlik)

## Kaynakça veya Yararlanılan Bağlantılar
* [Flutter Resmi Dökümantasyonu](https://flutter.dev/docs)
* [Kandilli Rasathanesi Son Depremler](http://www.koeri.boun.edu.tr/scripts/lst4.asp)
* [AFAD Son Depremler Verisi](https://deprem.afad.gov.tr/)
* [Pub.dev](https://pub.dev/) (Kullanılan paketlerin resmi dökümanları)
