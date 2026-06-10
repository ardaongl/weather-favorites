import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  
  // OpenWeatherMap API Key
  static const String apiKey = 'd0dd473d09c4a30dfc4c3c87fb9e3973';

  /// Fetches current weather for the specified city.
  /// Uses units=metric for Celsius and lang=tr for Turkish descriptions.
  Future<WeatherModel> fetchWeather(String cityName) async {
    if (apiKey.isEmpty) {
      throw Exception(
        'Lütfen lib/services/weather_service.dart dosyasındaki API anahtarını (apiKey) geçerli bir OpenWeatherMap API anahtarı ile değiştirin.'
      );
    }

    final encodedCity = Uri.encodeComponent(cityName.trim());
    final url = Uri.parse('$_baseUrl?q=$encodedCity&appid=$apiKey&units=metric&lang=tr');
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return WeatherModel.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Şehir bulunamadı. Lütfen şehir ismini kontrol edip tekrar deneyin.');
      } else if (response.statusCode == 401) {
        throw Exception('Geçersiz API anahtarı. Lütfen OpenWeatherMap API anahtarınızı kontrol edin.');
      } else {
        throw Exception('Hava durumu bilgisi alınamadı. Hata kodu: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Bir bağlantı hatası oluştu: $e');
    }
  }
}
