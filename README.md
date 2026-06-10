# Weather Favorites Flutter Application

Bu proje, OpenWeather API'sini kullanarak anlık hava durumu bilgilerini çeken ve Firebase Firestore entegrasyonu ile favori şehirleri kaydedip listeleyen modern bir Flutter mobil uygulamasıdır.

Bu uygulama **Material 3** tasarım standartlarına uygun, sade state yönetimi (`setState` ile) kullanan ve kullanıcı dostu bir arayüze sahip olacak şekilde geliştirilmiştir.

---

## 🚀 Özellikler

- **Anlık Hava Durumu Sorgulama:** OpenWeatherMap API aracılığıyla girilen şehre ait sıcaklık, nem, rüzgar hızı, minimum/maksimum sıcaklık değerlerini ve hava durumu açıklamasını Türkçe getirir.
- **Favorilere Ekleme & Çıkarma:** İstediğiniz şehirleri Firestore veri tabanına kaydedebilir ve dilediğinizde tek tuşla favorilerden kaldırabilirsiniz.
- **Gerçek Zamanlı Favori Listesi:** Firestore Stream entegrasyonu sayesinde eklenen veya silinen şehirler anında favoriler ekranına yansır.
- **Modern Tema Desteği:** Material 3 ve sistem ayarlarına göre otomatik değişen (Koyu/Açık) tema desteği mevcuttur.

---

## 🛠️ Kurulum Adımları

Projeyi çalıştırmadan önce **OpenWeather API Anahtarı** ve **Firebase** yapılandırmasını tamamlamanız gerekmektedir.

### 1. OpenWeather API Anahtarı Tanımlama
1. [OpenWeatherMap](https://openweathermap.org/) sitesine ücretsiz üye olun.
2. Hesabınızdan bir **API Key** (API Anahtarı) edinin.
3. [lib/services/weather_service.dart](file:///c:/Users/ardao/Desktop/Mobile/weather_favorites/lib/services/weather_service.dart) dosyasını açın.
4. `apiKey` değişkenindeki placeholder değeri kendi API anahtarınız ile değiştirin:
   ```dart
   static const String apiKey = 'BURAYA_API_ANAHTARINIZI_YAZIN';
   ```

### 2. Firebase Kurulumu
Projenin favori ekleme özelliklerinin çalışabilmesi için Firestore veri tabanını yapılandırmanız gerekir.

#### Kolay Yöntem: FlutterFire CLI (Önerilen)
1. Terminalde proje dizinine gidin ve aşağıdaki komutu çalıştırarak Firebase CLI'ı yapılandırın:
   ```bash
   flutterfire configure
   ```
2. Çıkan talimatları izleyerek Firebase projenizi seçin. Bu komut otomatik olarak platform dosyalarını güncelleyecek ve `lib/firebase_options.dart` dosyasını oluşturacaktır.
3. [lib/main.dart](file:///c:/Users/ardao/Desktop/Mobile/weather_favorites/lib/main.dart) dosyasında `Firebase.initializeApp()` satırını şu şekilde güncelleyin:
   ```dart
   import 'firebase_options.dart'; // import edin
   
   // main metodu içinde:
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```

#### Manuel Yöntem
1. [Firebase Console](https://console.firebase.google.com/) üzerinden yeni bir proje oluşturun.
2. Firebase projenizde **Firestore Database** servisini aktif edin ve kurallarını (rules) test modunda başlatın veya okuma/yazma izinlerini düzenleyin.
3. Uygulamanızı Firebase projenize kaydedin:
   - **Android için:** `google-services.json` dosyasını indirin ve `android/app/` dizinine yerleştirin.
   - **iOS için:** `GoogleService-Info.plist` dosyasını indirin ve `ios/Runner/` dizinine Xcode kullanarak ekleyin.

---

## 💻 Çalıştırma Komutları

Gereksinimler tamamlandıktan sonra uygulamayı çalıştırmak için terminalden aşağıdaki komutları uygulayabilirsiniz:

1. Bağımlılıkları indirin:
   ```bash
   flutter pub get
   ```

2. Kodları düzenleyin / formatlayın:
   ```bash
   flutter format .
   ```

3. Uygulamayı cihazınızda veya emülatörde çalıştırın:
   ```bash
   flutter run
   ```

---

## 📂 Dosya Yapısı

```
weather_favorites/
├── pubspec.yaml            # Bağımlılıklar (http, firebase_core, cloud_firestore)
├── README.md               # Kurulum ve açıklama kılavuzu
└── lib/
    ├── main.dart           # Firebase init, Material 3 tema ve yönlendirmeler
    ├── models/
    │   └── weather_model.dart       # OpenWeather API ve Firestore veri modelleri
    ├── services/
    │   ├── weather_service.dart     # OpenWeather API çağrısı
    │   └── firestore_service.dart   # Firestore CRUD işlemleri
    └── screens/
        ├── home_screen.dart         # Şehir arama ekranı
        ├── weather_detail_screen.dart # Hava durumu detay ve favori ekleme ekranı
        └── favorites_screen.dart    # Favori şehirler listesi
```
