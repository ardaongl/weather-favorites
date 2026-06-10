# ÖDEV RAPORU: Hava Durumu Favorileri Uygulaması (Apple UI & Firebase)

## Öğrenci Bilgileri
* **Adı Soyadı:** [Adınızı Buraya Yazın]
* **Öğrenci Numarası:** [Numaranızı Buraya Yazın]
* **Ders:** Mobil Uygulama Geliştirme / Yazılım Projesi

---

## Proje Tanımı ve Amacı
Bu proje; kullanıcıların dünya genelindeki şehirlerin anlık hava durumunu sorgulayabileceği, beğendiği şehirleri Firebase Firestore veri tabanına kaydederek favori listesi oluşturabileceği ve farklı şehirlerin hava şartlarını yan yana kıyaslayabileceği modern bir Flutter mobil uygulamasıdır. 

Uygulamanın arayüzü, **Apple Cupertino** tasarım yönergeleri (Apple UI) temel alınarak tasarlanmıştır. Bu sayede iOS işletim sisteminde çalışan uygulamaların sahip olduğu akıcı navigasyon, estetik gruplanmış listeler ve kaydırma hareketleriyle silme (Swipe-to-Delete) gibi üst düzey kullanıcı deneyimi ögeleri sunulmuştur.

---

## Kullanılan Teknolojiler & Kütüphaneler
* **Mobil Çatı (Framework):** Flutter & Dart SDK
* **Veri Tabanı (Backend):** Firebase Cloud Firestore (Favori şehirlerin senkronize ve gerçek zamanlı depolanması için)
* **Hava Durumu API:** OpenWeatherMap API (Anlık hava verisi, rüzgar hızı, nem oranı vb. çekimi için)
* **Arayüz Tasarımı:** Flutter Cupertino Widgets (Apple iOS Native Görünümü)

---

## Uygulama Sayfaları ve Temel Özellikler
1. **Hava Durumu Sekmesi:** Şehir ismi ile arama yapma, şık hava durumu kartları ve varsayılan şehir tanımlandığında açılışta otomatik veri getirme.
2. **Favoriler Sekmesi:** Firestore veri tabanından gerçek zamanlı (Stream) listeleme. iOS tarzı listeleme ve **sola kaydırarak silme (Swipe-to-Delete)** özelliği.
3. **Karşılaştırma Sekmesi:** İki farklı şehri yan yana kıyaslayarak sıcaklık, nem, rüzgar hızı ve gökyüzü durumunu karşılaştırmalı tablo şeklinde gösterme.
4. **Ayarlar Sekmesi:** Sıcaklık birimini Celsius (°C) ile Fahrenheit (°F) arasında anlık dönüştürme, varsayılan arama şehrini değiştirme ve Firebase bağlantı durumunu izleme.

---

## Proje GitHub Deposu (Repository)
Projenin kaynak kodlarına ve tüm geçmiş commit geçmişine aşağıdaki adresten ulaşabilirsiniz:
👉 **[Hava Durumu Favorileri GitHub Deposu](https://github.com/ardaongl/weather-favorites)**
*(Alternatif Açık Link: https://github.com/ardaongl/weather-favorites)*

---

## Kurulum ve Çalıştırma Adımları
1. **Depoyu Klonlayın:**
   ```bash
   git clone https://github.com/ardaongl/weather-favorites.git
   cd weather-favorites
   ```
2. **Bağımlılıkları Yükleyin:**
   ```bash
   flutter pub get
   ```
3. **Uygulamayı Çalıştırın:**
   ```bash
   flutter run
   ```
*(Not: Firestore özelliklerinin çalışması için Android/iOS platformlarına ait `google-services.json` ve `GoogleService-Info.plist` dosyalarının yapılandırılmış olması gerekmektedir.)*
