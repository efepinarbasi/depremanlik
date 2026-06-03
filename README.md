<div align="center">
  <h1>🌍 Deprem Anlık</h1>
  <p><b>Hayat Kurtaran Deprem Takip ve Acil Durum Hazırlık Uygulaması</b></p>
  
  [![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
  [![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
  [![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://www.android.com/)
  [![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)](https://www.apple.com/ios/)
  [![AdMob](https://img.shields.io/badge/AdMob-EA4335?style=for-the-badge&logo=google&logoColor=white)](https://admob.google.com/)
</div>

<br/>

## 📌 Uygulamanın Amacı
**Deprem Anlık**, sadece sismik hareketleri takip eden bir uygulama olmanın ötesinde, kullanıcıların olası bir deprem öncesinde, sırasında ve sonrasında ihtiyaç duyabileceği tüm hayati bilgileri tek bir merkezde toplar. 

Kullanıcıların **Bina Sağlık Durumlarını** takip etmelerine, detaylı **Tahliye Planları** oluşturmalarına ve acil durumlarda hızlıca sevdiklerine ulaşmalarına olanak tanır. Uygulamanın temel misyonu; farkındalık yaratmak, anlık doğru bilgi sağlamak ve afetlere karşı bireysel hazırlığı dijitalleştirmektir.

---

## 🚀 Öne Çıkan Özellikler
- **🗺️ Anlık Deprem Haritası & Listesi:** Türkiye ve çevresindeki sismik aktivitelerin harita üzerinde canlı ve detaylı gösterimi.
- **🏢 Etkileşimli Bina Sağlığı Raporu:** Kullanıcıların oturdukları binanın kolon durumunu, zemin analizini ve risk raporlarını kaydedebildiği özel bilgi kartları.
- **🏃‍♂️ Tahliye Planı Yönetimi:** Acil toplanma alanlarının, bina çıkış rotalarının ve buluşma noktalarının önceden planlanıp uygulamaya kaydedilmesi.
- **🌙 Siyah Tema (Karanlık Mod):** Göz yormayan, pil dostu ve modern, varsayılan karanlık tasarım.
- **💾 Çevrimdışı Veri Saklama:** İnternet olmasa bile kaydedilen acil durum kişileri ve bina raporlarına her an erişim sağlayan lokal veritabanı (SharedPreferences).
- **🔔 Anlık Sesli ve Görsel Bildirimler:** Belirlenen şiddetin üzerindeki depremler için kullanıcıyı uyaran gelişmiş bildirim altyapısı.

---

## 🛠️ Kullanılan Teknolojiler & Platformlar
Bu proje, modern yazılım prensipleri gözetilerek **Cross-Platform (Çoklu Platform)** olarak geliştirilmiştir:

* **Framework:** [Flutter](https://flutter.dev/)
* **Programlama Dili:** [Dart](https://dart.dev/)
* **Desteklenen Platformlar:** Android & iOS
* **Veri Kalıcılığı (Local Storage):** `shared_preferences`
* **Harita Altyapısı:** `flutter_map` ve `latlong2`
* **Konum Servisleri:** `geolocator` ve `geocoding`
* **Medya (Ses/Uyarı):** `audioplayers` ve `flutter_ringtone_player`

---

## 💰 Reklam ve Gelir Modeli (Google AdMob)
Projenin sürdürülebilirliğini sağlamak, sunucu maliyetlerini karşılamak ve uygulamanın tamamen **ücretsiz** kalmasını desteklemek amacıyla **Google Mobile Ads (AdMob)** entegrasyonu yapılmıştır.
- **Kullanıcı Deneyimi Odaklı Reklamlar:** Reklam yerleşimleri; kullanıcıların acil durum anında uygulamayı kullanmasını kesinlikle engellemeyecek şekilde, arayüzün (UI) bütünlüğünü bozmadan stratejik olarak konumlandırılmıştır.
- **Reklam Türleri:** Uygulama içerisinde akıcı deneyim sağlayan Banner ve uygun geçişlerde gösterilen Interstitial (Geçiş) reklamlar kullanılmaktadır.

---

## 📱 Kurulum ve Çalıştırma
Projeyi kendi ortamınızda çalıştırmak için aşağıdaki adımları izleyebilirsiniz:

1. Depoyu bilgisayarınıza klonlayın:
   ```bash
   git clone https://github.com/KullaniciAdiniz/depremanlik.git
   ```
2. Proje dizinine gidin ve bağımlılıkları yükleyin:
   ```bash
   cd depremanlik
   flutter pub get
   ```
3. Uygulamayı bağlı bir cihazda veya emülatörde çalıştırın:
   ```bash
   flutter run
   ```

---
*Bu proje, son kullanıcı güvenliğini artırmak ve yazılım dünyasının sunduğu imkanları afet yönetimiyle birleştirmek amacıyla bitirme projesi / final çalışması olarak hazırlanmıştır.*
