class WeatherModel {
  final String cityName;
  final double temperature;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final String description;
  final String iconCode;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.iconCode,
  });

  /// Factory constructor to create a WeatherModel from OpenWeather API JSON
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final weatherList = json['weather'] as List?;
    final weatherObj = weatherList != null && weatherList.isNotEmpty ? weatherList[0] : null;
    final mainObj = json['main'] as Map<String, dynamic>?;
    final windObj = json['wind'] as Map<String, dynamic>?;

    return WeatherModel(
      cityName: json['name'] ?? '',
      temperature: (mainObj?['temp'] as num?)?.toDouble() ?? 0.0,
      tempMin: (mainObj?['temp_min'] as num?)?.toDouble() ?? 0.0,
      tempMax: (mainObj?['temp_max'] as num?)?.toDouble() ?? 0.0,
      humidity: (mainObj?['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (windObj?['speed'] as num?)?.toDouble() ?? 0.0,
      description: weatherObj?['description'] ?? 'No description',
      iconCode: weatherObj?['icon'] ?? '',
    );
  }

  /// Converts the WeatherModel to a Map for saving to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'cityName': cityName,
      'temperature': temperature,
      'tempMin': tempMin,
      'tempMax': tempMax,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'description': description,
      'iconCode': iconCode,
      'savedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Factory constructor to create a WeatherModel from a Firestore document snapshot map
  factory WeatherModel.fromFirestore(Map<String, dynamic> data) {
    return WeatherModel(
      cityName: data['cityName'] ?? '',
      temperature: (data['temperature'] as num?)?.toDouble() ?? 0.0,
      tempMin: (data['tempMin'] as num?)?.toDouble() ?? 0.0,
      tempMax: (data['tempMax'] as num?)?.toDouble() ?? 0.0,
      humidity: (data['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (data['windSpeed'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] ?? '',
      iconCode: data['iconCode'] ?? '',
    );
  }
}
