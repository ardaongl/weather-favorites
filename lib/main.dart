import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // In a standard Flutter + Firebase project, this will initialize Firebase using 
    // the platform configurations (google-services.json for Android, GoogleService-Info.plist for iOS).
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
    debugPrint('Not: Firebase konfigürasyon dosyaları (google-services.json veya GoogleService-Info.plist) '
        'henüz eklenmemiş olabilir. Firestore özelliklerini kullanabilmek için lütfen projenize Firebase ekleyin.');
  }

  runApp(const WeatherFavoritesApp());
}

class WeatherFavoritesApp extends StatefulWidget {
  const WeatherFavoritesApp({super.key});

  @override
  State<WeatherFavoritesApp> createState() => _WeatherFavoritesAppState();
}

class _WeatherFavoritesAppState extends State<WeatherFavoritesApp> {
  bool _isCelsius = true;
  String _defaultCity = 'İstanbul'; // Varsayılan başlangıç şehri

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Weather Favorites',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
        primaryColor: CupertinoColors.activeBlue,
      ),
      home: HomeScreen(
        isCelsius: _isCelsius,
        onUnitChanged: (value) {
          setState(() {
            _isCelsius = value;
          });
        },
        defaultCity: _defaultCity,
        onDefaultCityChanged: (value) {
          setState(() {
            _defaultCity = value;
          });
        },
      ),
    );
  }
}
